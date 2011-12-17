#ifndef _I2C_H
#define _I2C_H

#include "main.h"
#include <util/twi.h>

enum {
    I2C_MT = 0,
    I2C_MR = 1,
    I2C_ST = 2,
    I2C_SR = 3
};

void i2c_setup(uint8_t addr);

uint8_t i2c_send_byte(uint8_t addr, uint8_t byte);
uint8_t i2c_recv_byte(uint8_t *byte);
uint8_t i2c_send_packet(uint8_t addr, uint8_t *buf, uint8_t len);
uint8_t i2c_recv_packet(uint8_t *buf, uint8_t len);

#endif
