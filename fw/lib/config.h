#ifndef _CONFIG_H
#define _CONFIG_H

#define SYSCLK 8000000UL
#define F_CPU  8000000UL

#define EEPROM_ADDR (uint8_t*) 1

// uart baud rate prescale
#define BAUD_PRESCALE 103    // 9600
#define BAUD_DOUBLE   1

/* PINS */                  // AVR
#define SCL_PIN     PC5     //  28
#define SCL_PRT     PORTC
#define SCL_DDR     DDRC

#define SDA_PIN     PC4     //  27
#define SDA_PRT     PORTC
#define SDA_DDR     DDRC

#define DBGLED_PRT  PORTB   //  [0:7] -> 14 15 16 17 18 19 9 10
#define DBGLED_DDR  DDRB

/* UART BUFFER DATA */
#define UART_RX_BUFSZ   128
//#define UART_TX_BUFSZ   128

/* SERIAL COMMANDS */
#define CMD_SYNC    0xAA
#define CMD_DOALL   255

/* DEBUG LIGHTING */
#define DBG_PRITY   0x1
#define DBG_OVFLW   0x2

#endif
