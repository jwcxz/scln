#include "i2c.h"

// provides functions to send and receive over the I2C bus

static void i2c_wait() {
    while ( !(TWCR & _BV(TWINT)) );
}

static uint8_t i2c_check(uint8_t mask) {
    // check TWSR against a mask
    uint8_t x;
    if ( (x = (TWSR & TW_STATUS_MASK)) != mask ) return x;
    else return 0;
    
    // TODO: this should also work
    //return (TWSR & TW_STATUS_MASK) ^ mask;
}

void i2c_setup(uint8_t addr) {
    // this implementation doesn't use interrupts because they're not necessary
    // and interrupts can be hard sometimes :(
    
    // no internal pullup
    SCL_DDR |= _BV(SCL_PIN) | _BV(SDA_PIN);

    // set up bit rate
    TWBR = I2C_BR;  // bit rate
    TWSR = I2C_PS;  // prescaler

    // set device address with no general call
    TWAR = (addr&0x7F) << 1;
    TWAMR = 0;  // compare all bits;
}


uint8_t i2c_send_byte(uint8_t addr, uint8_t byte) {
    uint8_t r;
    
    // send START
    TWCR = _BV(TWINT) | _BV(TWSTA) | _BV(TWEN);
    
    // wait for completion and check for error
    i2c_wait();
    //r = i2c_check(TW_START); if (r) return r;

    // send ADDR, W
    TWDR = ((addr&0x7F)<<1) | TW_WRITE;
    TWCR = _BV(TWINT) | _BV(TWEN);
    i2c_wait();
    r = i2c_check(TW_MT_SLA_ACK); if (r) return r;
    
    // send data
    TWDR = byte;
    TWCR = _BV(TWINT) | _BV(TWEN);
    i2c_wait();
    r = i2c_check(TW_MT_DATA_ACK); if (r) return r;

    // send STOP
    TWCR = _BV(TWINT) | _BV(TWSTO) | _BV(TWEN);
    //i2c_wait();
    
    return 0;
}


uint8_t i2c_recv_byte(uint8_t *byte) {
    // receive a byte into byte
    uint8_t r;

    // enable slave mode
    TWCR = _BV(TWEA) | _BV(TWEN);

    // wait for a bite (lol, pun) and ACK address
    i2c_wait();
    r = i2c_check(TW_SR_SLA_ACK); if (r) return r;
    TWCR = _BV(TWINT) | _BV(TWEA) | _BV(TWEN);
    
    // wait again and read data
    i2c_wait();
    r = i2c_check(TW_SR_DATA_ACK); if (r) return r;
    *byte = TWDR;
    TWCR = _BV(TWINT) | _BV(TWEA) | _BV(TWEN);
    
    // wait for stop condition and reset bus
    i2c_wait();
    r = i2c_check(TW_SR_STOP); if (r) return r;
    TWCR = _BV(TWINT) | _BV(TWEN);
    
    return 0;
}

uint8_t i2c_send_packet(uint8_t addr, uint8_t *buf, uint8_t len) {
    // send a stream of bytes using repeated start

    return 0;
}

uint8_t i2c_recv_packet(uint8_t *buf, uint8_t len) {
    // receive a stream of bytes using repeated start
    
    return 0;
}

