#ifndef _BTLDR_MAIN_H
#define _BTLDR_MAIN_H

#include "config.h"
#include "macros.h"

#include <inttypes.h>
#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/boot.h>
#include <avr/eeprom.h>

#define PAGESIZE 128
#define AM_ALL 255
#define CMD_NOP 'N'
//#define CMD_SYNC 170
#define CMD_ADDR 'A'
#define CMD_BAUD 'B'
#define CMD_BOOT 'R'
#define CMD_DISP 'D'
#define CMD_ESET 'E'
#define CMD_EGET 'G'
#define CMD_MASK 'M'
#define CMD_PROG 'P'
#define CMD_FNSH 'F'

enum {
    CST_IDLE = 0,
    CST_SYNC,
    CST_MASK,
    CST_ESET_ADDR,
    CST_ESET_DATA,
    CST_EGET_ADDR,
    CST_PROG_A_H,
    CST_PROG_A_L,
    CST_PROG_D,
    CST_PROG_V
};

/* UART BUFFERS */
extern volatile uint8_t uart_rxbuf[UART_RX_BUFSZ];
extern volatile uint8_t *uart_rxbuf_iptr;
extern volatile uint8_t *uart_rxbuf_optr;
extern volatile uint8_t uart_rxbuf_count;
extern volatile uint8_t rxen;

int main(void);
void receive_data(void);
void process_rx(void);
void give_up(uint8_t);
void write_page(void);
void verify_flash(uint8_t);
uint8_t applies_to_me(void);

#endif
