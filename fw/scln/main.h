#ifndef _MAIN_H
#define _MAIN_H

#include "config.h"
#include "macros.h"

#include <inttypes.h>
#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

/* UART BUFFERS */
extern volatile uint8_t uart_rxbuf[UART_RX_BUFSZ];
extern volatile uint8_t *uart_rxbuf_iptr;
extern volatile uint8_t *uart_rxbuf_optr;
extern volatile uint8_t uart_rxbuf_count;
extern volatile uint8_t rxen;

extern volatile uint8_t uart_txbuf[UART_TX_BUFSZ];
extern volatile uint8_t *uart_txbuf_iptr;
extern volatile uint8_t *uart_txbuf_optr;
extern volatile uint8_t uart_txbuf_count;

/* GLOBAL VARIABLES */
extern uint8_t instaddr;    // instrument address

/* STRUCTS */
struct Circuit {
    // TODO: needs to be generalized into some kind of array
    uint8_t firstaddr;
    uint8_t firstkey;

    uint8_t secndaddr;
    uint8_t secndkey;
    
    uint8_t thirdaddr;
    uint8_t thirdkey;
};

int main(void);
void scln_transmitter(void);
void scln_node(void);
void scln_receiver(void);
uint8_t makecircuit(struct Circuit *ckt);
uint8_t makeonion(struct Circuit *ckt, uint8_t *buf, uint8_t *onion, uint8_t *tmp);
uint8_t peelonion(uint8_t rxsz, uint8_t *rx, uint8_t *tx, uint8_t *destaddr);

void encrypt(uint8_t *pubkey, uint8_t *plain, uint8_t plainsz, uint8_t *cipher, uint8_t *ciphersz);
void decrypt(uint8_t *prvkey, uint8_t *cipher, uint8_t ciphersz, uint8_t *plain, uint8_t *plainsz);

#endif
