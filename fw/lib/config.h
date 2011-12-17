#ifndef _CONFIG_H
#define _CONFIG_H

#define SYSCLK 8000000UL
#define F_CPU  8000000UL

#define EEPROM_ADDR (uint8_t*) 1

// uart baud rate prescale
#define BAUD_PRESCALE 103    // 9600
#define BAUD_DOUBLE   1

#define I2C_BR      32
#define I2C_PS      0

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
#define UART_RX_BUFSZ   32
#define UART_TX_BUFSZ   32

/* DEBUG LIGHTING */
#define DBG_PRITY   0x1
#define DBG_OVFLW   0x2
#define DBG_CIRCT   0xE1
#define DBG_ONION   0xE2

/* DEVICES */
#define DEV_TX 0x1
#define DEV_RX 0x2
#define DEV_N0 0x11
#define DEV_N1 0x12
#define DEV_N2 0x13

#define KEY_N0 0x00 //0xF7
#define KEY_N1 0x00 //0xE8
#define KEY_N2 0x00 //0xD9

/* PACKET CONFIGURATION */
#define PKTLEN 16
#define MAXONION PKTLEN+1+1+1

#endif
