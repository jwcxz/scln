#include "dbgled.h"
#include "eeprom.h"

void uart_init(void) {
	UBRR0H = (unsigned char) (BAUD_PRESCALE>>8);
	UBRR0L = (unsigned char) BAUD_PRESCALE;

    UCSR0A = ( BAUD_DOUBLE << U2X0 );
    // XXX: TXEN0 is disabled
	UCSR0B = ( _BV(RXCIE0) | _BV(RXEN0) );
	UCSR0C = ( _BV(UCSZ01) | _BV(UCSZ00) );

    // enable even parity
    UCSR0C |= _BV(UPM01);

    // reset the pointers and buffer count
	uart_rxbuf_iptr = uart_rxbuf;
	uart_rxbuf_optr = uart_rxbuf;
    uart_rxbuf_count = 0;
    /* XXX: enable with TX
	uart_txbuf_iptr = uart_txbuf;
	uart_txbuf_optr = uart_txbuf;
    */
}

uint8_t uart_rx(void) {
	unsigned char tmp;
    cli();

    // now that interrupts are shut off before reading, don't wait for the
    // rxbuf to get filled
	//while ( uart_rxbuf_count == 0 );

	tmp = *uart_rxbuf_optr;
	uart_rxbuf_count--;

	uart_rxbuf_optr++;
	if ( uart_rxbuf_optr >= uart_rxbuf + UART_RX_BUFSZ )
		uart_rxbuf_optr = uart_rxbuf;

    sei();
	return tmp;
}

uint8_t uart_data_rdy(void) {
	return ( uart_rxbuf_count );
}

void uart_tx(uint8_t data) {
	while ( uart_txbuf_count >= UART_TX_BUFSZ );

	*uart_txbuf_iptr = data;
	uart_txbuf_count++;

	uart_txbuf_iptr++;
	if ( uart_txbuf_iptr >= uart_txbuf + UART_TX_BUFSZ )
		uart_txbuf_iptr = uart_txbuf;

	_ON(UCSR0B,UDRIE0);
}

/* INTERRUPT VECTORS */
ISR(USART_RX_vect) {
	unsigned char data;

    if( UCSR0A & _BV(UPE0) ) {
        // parity error
        dbg_on(DBG_PRITY);
        // XXX: check frame errors and data overrun errors (FE0 and DOR0)
    } else {
        data = UDR0;

        if ( uart_rxbuf_count <= UART_RX_BUFSZ ) {
            *uart_rxbuf_iptr = data;
            uart_rxbuf_count++;

            uart_rxbuf_iptr++;
            if ( uart_rxbuf_iptr >= uart_rxbuf + UART_RX_BUFSZ )
                uart_rxbuf_iptr = uart_rxbuf;
        } else {
            // buffer overflow!
            // shut interrupts off until we can deplete the buffer a bit
            cli();
            rxen = 0;

            dbg_on(DBG_OVFLW);
        }
    }
}

ISR(USART_TX_vect) {
	if ( uart_txbuf_count > 0 ) {
		UDR0 = *uart_txbuf_optr;
		uart_txbuf_count--;

		uart_txbuf_optr++;
		if ( uart_txbuf_optr >= uart_txbuf + UART_TX_BUFSZ )
			uart_txbuf_optr = uart_txbuf;
	} else {
		_OFF(UCSR0B, UDRIE0);
	}
}
