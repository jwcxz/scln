#include "main.h"

#include "dbgled.h"
#include "eeprom.h"
#include "uart.h"
#include "i2c.h"

volatile uint8_t uart_rxbuf[UART_RX_BUFSZ];
volatile uint8_t *uart_rxbuf_iptr = uart_rxbuf;
volatile uint8_t *uart_rxbuf_optr = uart_rxbuf;
volatile uint8_t uart_rxbuf_count = 0;
volatile uint8_t rxen = 0;

volatile uint8_t uart_txbuf[UART_TX_BUFSZ];
volatile uint8_t *uart_txbuf_iptr = uart_txbuf;
volatile uint8_t *uart_txbuf_optr = uart_txbuf;
volatile uint8_t uart_txbuf_count = 0;

uint8_t instaddr = 0;

uint8_t  databuf[PKTLEN];
uint8_t  dataidx = 0;

uint8_t rxonion[MAXONION], txonion[MAXONION];

struct Circuit *ckt;

uint8_t prvkey;

int main(void) {
    // initialize debug LEDs
    dbg_init();

    // get the address of the device
    instaddr = get_addr();

    // set up uart for 9600 baud communication with no parity
	UBRR0H = (uint8_t) (BAUD_PRESCALE>>8);
	UBRR0L = (uint8_t) BAUD_PRESCALE;
    UCSR0A = ( BAUD_DOUBLE<<U2X0 );
    if ( instaddr == DEV_TX ) UCSR0B = ( _BV(RXCIE0) | _BV(RXEN0) );
    else if (instaddr == DEV_RX) UCSR0B = ( _BV(TXCIE0) | _BV(TXEN0) );
	UCSR0C = ( _BV(UCSZ01) | _BV(UCSZ00) );

    // reset the pointers and buffer count
	uart_rxbuf_iptr = uart_rxbuf;
	uart_rxbuf_optr = uart_rxbuf;
    uart_rxbuf_count = 0;
	uart_txbuf_iptr = uart_txbuf;
	uart_txbuf_optr = uart_txbuf;
    uart_txbuf_count = 0;

    // setup i2c
    i2c_setup(instaddr);

    // enable interrupts
    rxen = 1;

    // set private key
    // TODO: this should happen from EEPROM
    switch (instaddr) {
        case DEV_N0:
            prvkey = KEY_N0;
            break;
        case DEV_N1:
            prvkey = KEY_N1;
            break;
        case DEV_N2:
            prvkey = KEY_N2;
            break;
        default:
            break;
    }
    
    dbg_set(instaddr);

    // main loop (depending on device type)
    switch (instaddr) {
        case DEV_TX:
            sei();
            scln_transmitter();
            break;
           
        case DEV_N0:
        case DEV_N1:
        case DEV_N2:
            dbg_on(7);
            scln_node();
            break;
            
        case DEV_RX:
            dbg_on(6);
            sei();
            scln_receiver();
            break;
            
        default:
            while(1);
            break;
    }

	return 0;
}

void scln_transmitter(void) {
    uint8_t destaddr, r, i;
    uint8_t onionsz;
    
    while (1) {
        for ( dataidx=0 ; dataidx<PKTLEN ; dataidx++ ) {
            while (!uart_data_rdy());

            // read data from UART into data buffer
            databuf[dataidx] = uart_rx();
        }
        
        // buffer is full -- make and send an onion!
            
        // form a circuit
        destaddr = makecircuit(ckt);
        if (!destaddr) {
            dbg_set(DBG_CIRCT);
            continue;
        }
        
        // create onion
        onionsz = makeonion(ckt, databuf, txonion, rxonion);
        if (!onionsz) {
            dbg_set(DBG_ONION);
            continue;
        }
        
        // send onion size
        r = i2c_send_byte(destaddr, onionsz);
        if (r) { dbg_set(r); continue; }
        /*
        r = i2c_send_byte(destaddr, (uint8_t) (onionsz >> 8));
        if (r) { dbg_set(r); continue; }
        r = i2c_send_byte(destaddr, (uint8_t) (onionsz & 0xFF));
        if (r) { dbg_set(r); continue; }
        */

        // send onion
        for ( i=0 ; i<onionsz ; i++ ) {
            dbg_set(0xA0 | i);
            r = i2c_send_byte(destaddr, txonion[i]);
            if (r) { dbg_set(r); goto stupid; }
        }
        
        continue;
stupid:
        dbg_set(0xFF);
    }
}

void scln_node(void) {
    // receive an onion, unwrap a layer, send to next node
    
    uint8_t destaddr, r;
    uint8_t i, onionsz;
    
    while (1) {
        // get onion size
        r = i2c_recv_byte(&onionsz);
        if (r) { dbg_set(r); continue; }
        /*
        r = i2c_recv_byte(&i);
        if (r) { dbg_set(r); continue; }
        onionsz = (i<<8);
        r = i2c_recv_byte(&i);
        if (r) { dbg_set(r); continue; }
        onionsz |= (i);
        */

        // receive onion
        for ( i=0 ; i<onionsz ; i++ ) {
            r = i2c_recv_byte(&rxonion[i]);
            if (r) { dbg_set(r); goto stupid; }
        }
        
        // peel a layer into txonion
        onionsz = peelonion(onionsz, rxonion, txonion, &destaddr);
        if (!onionsz) {
            dbg_set(DBG_CIRCT);
            continue;
        }
        
        // send new onion size
        r = i2c_send_byte(destaddr, onionsz);
        if (r) { dbg_set(r); continue; }
        /*
        r = i2c_send_byte(destaddr, (uint8_t) (onionsz >> 8));
        if (r) { dbg_set(r); continue; }
        r = i2c_send_byte(destaddr, (uint8_t) (onionsz & 0xFF));
        if (r) { dbg_set(r); continue; }
        */

        // send new onion
        for ( i=0 ; i<onionsz ; i++ ) {
            r = i2c_send_byte(destaddr, txonion[i]);
            if (r) { goto stupid; }
        }
        
        continue;
stupid:
        dbg_set(0xFF);
    }
}

void scln_receiver(void) {
    // receive the final packet, send it over UART
    uint8_t r;
    uint8_t i, onionsz;
    
    while (1) {
        // get onion size
        // (onion size should be PKTLEN)
        // get onion size
        r = i2c_recv_byte(&onionsz);
        if (r) { dbg_set(r); continue; }
        /*
        r = i2c_recv_byte(&i);
        if (r) { dbg_set(r); continue; }
        onionsz = (i<<8);
        r = i2c_recv_byte(&i);
        if (r) { dbg_set(r); continue; }
        onionsz |= (i);
        */

        // receive onion
        for ( i=0 ; i<onionsz ; i++ ) {
            r = i2c_recv_byte(&rxonion[i]);
            if (r) { dbg_set(r); continue; }
        }
        
        // send it over UART
        for ( i=0 ; i<onionsz ; i++ ) {
            uart_tx(rxonion[i]);
        }
        
        // display 
        dbg_set(rxonion[0]);
    }

}

uint8_t makecircuit(struct Circuit *ckt) {
    // TODO: read low bit of ADC a few times and build a 3-node circuit
    ckt->firstaddr = DEV_N0;
    ckt->firstkey = KEY_N0;
    
    ckt->secndaddr = DEV_N1;
    ckt->secndkey = KEY_N1;

    ckt->thirdaddr = DEV_N2;
    ckt->thirdkey = KEY_N2;
    
    return ckt->firstaddr;
}

uint8_t makeonion(struct Circuit *ckt, uint8_t *buf, uint8_t *onion, uint8_t *tmp) {
    // onion depth fixed at 3
    // enc(first, [secnd]enc(secnd, [third]enc(third, [rxaddr][databuf]));
    // TODO: generalize
    uint8_t txsz;
    uint8_t i;
    
    //memcpy(&tmp[1], buf, PKTLEN);
    for ( i=0 ; i<PKTLEN ; i++ ) {
        tmp[i+1] = buf[i];
    }
    tmp[0] = DEV_RX;

    encrypt(&ckt->thirdkey, tmp, PKTLEN+1, &onion[1], &txsz);
    onion[0] = ckt->thirdaddr;

    encrypt(&ckt->secndkey, onion, txsz+1, &tmp[1], &txsz);
    tmp[0] = ckt->secndaddr;
    
    encrypt(&ckt->firstkey, tmp, txsz+1, onion, &txsz);
    return txsz;
}

uint8_t peelonion(uint8_t rxsz, uint8_t *rx, uint8_t *tx, uint8_t *destaddr) {
    uint8_t i, txsz;
    
    // decrypt one layer, get destaddr from it and update size
    decrypt(&prvkey, rx, rxsz, tx, &txsz);
    
    *destaddr = tx[0];
    txsz--;
    for ( i=0 ; i<txsz ; i++ ) {
        tx[i] = tx[i+1];
    }
   
    return txsz;
}

void encrypt(uint8_t *pubkey, uint8_t *plain, uint8_t plainsz, uint8_t *cipher, uint8_t *ciphersz) {
    // TODO: replace with RSA
    uint8_t i;
    for ( i=0 ; i<plainsz ; i++ ) {
        cipher[i] = plain[i] ^ *pubkey;
    }
    
    *ciphersz = plainsz;
}

void decrypt(uint8_t *prvkey, uint8_t *cipher, uint8_t ciphersz, uint8_t *plain, uint8_t *plainsz) {
    // TODO: replace with RSA
    uint8_t i;
    for ( i=0 ; i<ciphersz ; i++ ) {
        plain[i] = cipher[i] ^ *prvkey;
    }
    
    *plainsz = ciphersz;
}
