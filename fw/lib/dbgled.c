#include "dbgled.h"

void dbg_set(uint8_t val) {
    DBGLED_PRT = val;
}

void dbg_on(uint8_t val) {
    _ON(DBGLED_PRT, val);
}

void dbg_off(uint8_t val) {
    _OFF(DBGLED_PRT, val);
}

void dbg_init(void) {
    // this requires the debug bank to be the bottom 4 bits of a bank
    // TODO: make it more advanced
    DBGLED_DDR |= 0xFF;
}
