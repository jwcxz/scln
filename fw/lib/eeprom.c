#include "eeprom.h"
#include <avr/eeprom.h>

uint8_t get_addr(void) {
    return get_eeprom_data(EEPROM_ADDR);
}

uint8_t get_eeprom_data(uint8_t *addr) {
    eeprom_busy_wait();
    return eeprom_read_byte(addr);
}
