/* **********************************
 * Bootloader                       *
 *                                  *
 * J. Colosimo -- http://jwcxz.com/ *
 *                                  *
 * Main bootloader source file      *
 ************************************/

/*
 * This bootloader provides the following features:
 *  1. fast startup time (i.e. bootloader->application time)
 *  2. downloading of program to device
 *  3. set address of instrument (eeprom 
 *  6. view the instrument address on the debug LEDs
 *  7. program verification
 *
 *  Transmission is done through a serial protocol:
 *  Fn  Args    Description
 *  ___ _______ ____________________________________________________
 *  170 0       SYNC - start of a packet
 *
 *  N   0       NOP  - sent to wake bootloader up (or you can use SYNC)
 *
 *  A   1       ADDR - [Addr] Set 1-byte address of the device in EEPROM
 *
 *  D   0       DISP - Display the instrument on the debug LEDs
 *
 *  E   2       ESET - [Addr][Data] Set a byte of EEPROM
 *  
 *  G   1       EGET - [Addr] Read a byte of EEPROM
 *
 *  M   1       MASK - [Addr] Address to work with for all following commands
 *                  0xFF - all instruments
 *                  0xF0-0xFE - blocks of 16
 *
 *  P   2       PROG - [Addr][Page...] - Send program one page at a time
 *                  To simplify the bootloader, it does NOT take an Intel HEX
 *                  file as an input.  Rather, a special "program" script reads
 *                  the HEX file and outputs the following format:
 *                      [Starting Address][Page][Checksum]
 *                  The checksum is the one's complement of the sum of the
 *                  page stream.
 *
 *                  Note: this means that the stream length depends on the page
 *                  size (whereas Intel HEX files have known lengths).
 *                  Furthermore, it requires that unused bytes be 0-filled or
 *                  something.  I'm lazy.  Deal with it.
 *
 *  R   0       BOOT - boot the application
 */

#include "main.h"
#include "eeprom.h"
#include "dbgled.h"
#include "uart.h"

// uart buffer
volatile uint8_t uart_rxbuf[UART_RX_BUFSZ];
volatile uint8_t *uart_rxbuf_iptr = uart_rxbuf;
volatile uint8_t *uart_rxbuf_optr = uart_rxbuf;
volatile uint8_t uart_rxbuf_count = 0;
volatile uint8_t rxen = 1;

// current command state
static uint8_t curstate = CST_IDLE;

// page buffer
static uint8_t page_buf[PAGESIZE];
static uint8_t *page_buf_ptr;
static uint16_t page_addr;

// device address
static uint8_t addr = 0xFF;

// device address mask
static uint8_t mask = AM_ALL;

// eeprom address to set
static uint8_t *eset_addr = 0;

/* Main Loop */
int main(void) {
    MCUCR = (1<<IVCE);
    MCUCR = (1<<IVSEL);

    dbg_init();
    dbg_set(0x9);

    addr = get_addr();

    // set up uart for 9600 baud communication with even parity
    uart_init();

    sei();

    // wait just a bit to get some data
    _delay_ms(1000);

    // switch to application mode if there's no data on the UART
    if ( !uart_data_rdy() ) {
        cli();
        MCUCR = (1<<IVCE);
        MCUCR = 0;
        asm("jmp 0000");
    } else if ( uart_rx() != CMD_NOP ) {
        cli();
        MCUCR = (1<<IVCE);
        MCUCR = 0;
        asm("jmp 0000");
    } else {
        // otherwise, go into receive data loop
        receive_data();
    }

    return 0;
}

/* Loop, waiting for data */
void receive_data(void) {
    while (1) {
        if ( uart_data_rdy() ) process_rx();
    }
}

/* Processed a received byte */
void process_rx(void) {
    uint8_t data, i;
    uint8_t csum = 0;
    data = uart_rx();

    switch (curstate) {
        case CST_IDLE:
            if ( data == CMD_SYNC ) curstate = CST_SYNC;
            else curstate = CST_IDLE;
            break;
        case CST_SYNC:
            if ( data == CMD_NOP ) curstate = CST_IDLE;
            else if ( data == CMD_SYNC ) curstate = CST_SYNC;
                // if we get a mask request, then always honor it
            else if ( data == CMD_MASK ) curstate = CST_MASK;
            else if ( applies_to_me() ) {
                switch (data) {
                    case CMD_BOOT:
                        cli();
                        boot_rww_enable_safe();
                        MCUCR = (1<<IVCE);
                        MCUCR = 0;
                        asm("jmp 0000");
                        curstate = CST_IDLE;
                        break;
                        
                    case CMD_DISP:
                        dbg_set(addr);
                        curstate = CST_IDLE;
                        break;

                    case CMD_ADDR:
                        //curstate = CST_ADDR;
                        // force the address to EEPROM_ADDR and move on to
                        // capturing the data
                        eset_addr = EEPROM_ADDR;
                        curstate = CST_ESET_DATA;
                        break;

                    case CMD_ESET:
                        curstate = CST_ESET_ADDR;
                        break;
                        
                    case CMD_EGET:
                        curstate = CST_EGET_ADDR;
                        break;

                    case CMD_PROG:
                        curstate = CST_PROG_A_H;
                        break;

                    case CMD_FNSH:
                        boot_rww_enable_safe();
                        curstate = CST_IDLE;
                        break;

                    default:
                        curstate = CST_IDLE;
                        break;
                }
            } 
            // otherwise, no action applied to me, so wait for the next
            // packet (maybe it'll be a new mask)
            else curstate = CST_IDLE;
            break;

        case CST_MASK:
            mask = data;
            curstate = CST_IDLE;
            break;

        case CST_ESET_ADDR:
            eset_addr = (uint8_t *) data;
            curstate = CST_ESET_DATA;
            break;
        case CST_ESET_DATA:
            eeprom_busy_wait();
            eeprom_write_byte(eset_addr, data);
            // reset device address to new value if it changed
            if (eset_addr == EEPROM_ADDR) addr = data;
            curstate = CST_IDLE;
            break;
            
        case CST_EGET_ADDR:
            dbg_set(get_eeprom_data((uint8_t *) data));
            curstate = CST_IDLE;
            break;

        case CST_PROG_A_H:
            dbg_set(data);
            page_addr = data << 8;
            // reset page buffer pointer
            page_buf_ptr = page_buf;
            curstate = CST_PROG_A_L;
            break;
        case CST_PROG_A_L:
            //dbg_set(data);    // not useful
            page_addr |= data;
            curstate = CST_PROG_D;
            break;
        case CST_PROG_D:
            *(page_buf_ptr++) = data;
            if ( page_buf_ptr - page_buf == PAGESIZE ) {
                // we hit the last byte of the page, so the next byte is the
                // checksum
                curstate = CST_PROG_V;
            } else {
                curstate = CST_PROG_D;
            }
            break;
        case CST_PROG_V:
            curstate = CST_IDLE;

            for ( i=0 ; i<PAGESIZE ; i++ ) {
                csum += page_buf[i];
            }
            csum = ~csum;

            if ( csum == data ) {
                // checksum verifies, so write the page
                write_page();
            } else {
                // damnit...
                // TODO: we can be slightly smarter (if it's the first address,
                // we technically haven't corrupted anything yet)
                give_up(1);
            }
            dbg_on(0x3);
            break;

        default:
            curstate = CST_IDLE;
            break;
    }
}

/* Reached an unrecoverable error, so:
 *  - Light up the LEDs indicating an error
 *  - If corrupted, then write 0xFF to the first page in order to prevent the
 *    bootloader from trying to run the application at the beginning.
 *  - Go back and wait for new data.
 */
void give_up(uint8_t corrupted) {
    uint16_t i;
    if (corrupted) {
        // set LEDs to "shit really hit the fan"
        dbg_set(0xAA);

        // fill the first page with 0xFF
        for ( i=0 ; i<PAGESIZE ; i+=2 ) {
            boot_page_fill_safe(i, 0xFFFF);
        }
        boot_page_write_safe(0);
        boot_spm_busy_wait();

        // halt
        while(1);
    } else {
        // set LEDs to "shit slightly hit the fan"
        dbg_set(0x55);
    }

    // return to waiting for data
    curstate = CST_IDLE;    // reset state machine
    receive_data();
}

/* Write a page of data from the page buffer */
void write_page(void) {
    uint16_t i,w;
    uint8_t sreg;

    // disable interrupts
    sreg = SREG;
    cli();

    boot_page_erase_safe(page_addr);
    boot_spm_busy_wait();

    page_buf_ptr = page_buf;
    for ( i=0 ; i<PAGESIZE ; i+=2 ) {
        // make word
        w = *page_buf_ptr++;
        w |= (*page_buf_ptr++)<<8;

        boot_page_fill_safe(page_addr+i, w);
    }

    boot_page_write_safe(page_addr);
    boot_spm_busy_wait();

    // re-enable interrupts
    SREG = sreg;
}

/* Check to see if the mask applies to this instrument */
uint8_t applies_to_me(void) {
    if ( addr == 0xFF ) {
        // eeprom address hasn't been set yet, so listen to everything
        return 1;
    } else if ( mask == AM_ALL ) {
        // 0xFF = all addresses
        return 1;
    } else if ( addr == mask ) {
        // we specifically targeted this device
        return 1;
    } else if ( mask >= 0xF0 && ( addr >= (mask&0x0F)*16 && 
                addr <= (mask&0x0F)*16+15 ) ) {
        // the devices matches in block mode
        return 1;
    } else {
        return 0;
    }
}
