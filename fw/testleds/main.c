#include "main.h"

#include "dbgled.h"
#include "eeprom.h"
#include "uart.h"

volatile uint8_t uart_rxbuf[UART_RX_BUFSZ];
volatile uint8_t *uart_rxbuf_iptr = uart_rxbuf;
volatile uint8_t *uart_rxbuf_optr = uart_rxbuf;
volatile uint8_t uart_rxbuf_count = 0;
volatile uint8_t rxen = 0;

uint8_t instaddr = 0;

volatile uint8_t tlc[3][24];

uint8_t action;         // current action
uint8_t numargs;        // number of arguments to expect
uint8_t args[15];       // array to store arguments
uint8_t* argptr = args; //   ... associated pointer

int main(void) {
    // initialize debug LEDs
    dbg_init();

    // get the address of the device
    instaddr = get_addr();

    // set up uart for 9600 baud communication with no parity
	UBRR0H = (uint8_t) (BAUD_PRESCALE>>8);
	UBRR0L = (uint8_t) BAUD_PRESCALE;
    UCSR0A = ( BAUD_DOUBLE<<U2X0 );
	UCSR0B = ( _BV(RXCIE0) | _BV(RXEN0) );
	UCSR0C = ( _BV(UCSZ01) | _BV(UCSZ00) );

    // reset the pointers and buffer count
	uart_rxbuf_iptr = uart_rxbuf;
	uart_rxbuf_optr = uart_rxbuf;
    uart_rxbuf_count = 0;

    dbg_set(0xE7);

    // enable interrupts
    sei();
    rxen = 1;

    while (1) {
        if ( uart_data_rdy() ) receive_data();
    }

	return 0;
}

void receive_data(void) {
    unsigned char inbyte;

    inbyte = uart_rx();

    //*
    switch (inbyte) {
        case 'a':
        case 'A':
            dbg_set(0xAA);
            break;
        case 'b':
        case 'B':
            dbg_set(0xBB);
            break;
        case '1':
            dbg_set(0x11);
            break;

        default:
            dbg_set(0x3);
            break;
    }
    // */
}
