###############################################################################
# Makefile for the project AVRCrypto
###############################################################################

## General Flags
PROJECT = AVRCrypto
MCU = atmega640
TARGET = AVRCrypto.elf
CC = avr-gcc

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2     -O3  -funsigned-char  -funsigned-bitfields  -fpack-struct  -fshort-enums 
CFLAGS += -Wp,-M,-MP,-MT,$(*F).o,-MF,dep/$(@F).d

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=AVRCrypto.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0


## Objects that must be built in order to link
OBJECTS = main.o des_test.o rsa_test.o sha_test.o md5_test.o SkipJack_test.o AES_test.o


AVRCRYPTOOBJECTS =	memeor.o \
				 	rsa_encrypt.o rsa_decrypt.o rsa_encrypt_P.o rsa_decrypt_P.o rsa_mul.o rsa_modulo.o rsa_modulo_P.o rsa_dec.o rsa_enc.o\
					des_commen.o des_dec.o des_enc.o des_decrypt.o des_encrypt.o des_triple_decrypt.o des_triple_encrypt.o\
					sha_commen.o sha_update.o sha_update_P.o\
					md5.o md5_commen.o md5_update.o md5_update_P.o\
					SkipJack_Enc.o SkipJack_Dec.o SkipJack_commen.o\
					AES_Sbox.o AES_InvSbox.o AES_XORBytes.o\
					AES_CalInvSbox.o AES_CalSbox.o\
					AES_SF_SubBytes.o AES_SR_SubBytes.o\
					AES_SF_InvSubBytesAndXOR.o AES_SR_InvSubBytesAndXOR.o\
					AES_Enc_commen.o AES_Dec_commen.o\
					AES_expandedKey.o\
					AES_SF_128_commen.o AES_SF_192_commen.o AES_SF_256_commen.o\
					AES_SR_128_commen.o AES_SR_192_commen.o AES_SR_256_commen.o\
					AES_SF_128_dec.o AES_SF_128_enc.o\
					AES_SF_192_dec.o AES_SF_192_enc.o\
					AES_SF_256_dec.o AES_SF_256_enc.o\
					AES_SR_128_dec.o AES_SR_128_enc.o\
					AES_SR_192_dec.o AES_SR_192_enc.o\
					AES_SR_256_dec.o AES_SR_256_enc.o					

## Build
all: $(TARGET) $(AVRCRYPTOOBJECTS) AVRCrypto.hex AVRCrypto.eep AVRCrypto.lss size


LIBS = AvrCrypto.a

AvrCrypto.a: $(AVRCRYPTOOBJECTS) 
	avr-ar -cr $@ $(AVRCRYPTOOBJECTS)
	avr-ranlib $@

## Compile

memeor.o: ../memeor.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

main.o: ../main.c
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

rsa_test.o: ../rsa_test.c
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

des_test.o: ../des_test.c
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

SkipJack_test.o: ../SkipJack_test.c
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

SkipJack_Enc.o: ../SkipJack_Enc.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

SkipJack_Dec.o: ../SkipJack_Dec.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

SkipJack_commen.o: ../SkipJack_commen.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

memcmp_P.o: ../memcmp_P.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

sha_test.o: ../sha_test.c ../sha.h 
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

sha_commen.o: ../sha_commen.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

sha_update.o: ../sha_update.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

sha_update_P.o: ../sha_update_P.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

md5.o: ../md5.c ../md5.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

md5_commen.o: ../md5_commen.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

md5_update.o: ../md5_update.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

md5_update_P.o: ../md5_update_P.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

md5_test.o: ../md5_test.c ../md5.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

AES_SR_128_dec.o: ../AES_SR_128_dec.S ../AES_Dec_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_192_dec.o: ../AES_SR_192_dec.S ../AES_Dec_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_256_dec.o: ../AES_SR_256_dec.S ../AES_Dec_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_128_dec.o: ../AES_SF_128_dec.S ../AES_Dec_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_192_dec.o: ../AES_SF_192_dec.S ../AES_Dec_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_256_dec.o: ../AES_SF_256_dec.S ../AES_Dec_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_128_enc.o: ../AES_SR_128_enc.S ../AES_Enc_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_192_enc.o: ../AES_SR_192_enc.S ../AES_Enc_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_256_enc.o: ../AES_SR_256_enc.S ../AES_Enc_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_128_enc.o: ../AES_SF_128_enc.S ../AES_Enc_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_192_enc.o: ../AES_SF_192_enc.S ../AES_Enc_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_256_enc.o: ../AES_SF_256_enc.S ../AES_Enc_Key_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_Commen.o: ../AES_Commen.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_InvSbox.o: ../AES_InvSbox.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_Sbox.o: ../AES_Sbox.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_CalInvSbox.o: ../AES_CalInvSbox.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_CalSbox.o: ../AES_CalSbox.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_XORBytes.o: ../AES_XORBytes.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_InvSubBytesAndXOR.o: ../AES_SF_InvSubBytesAndXOR.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_InvSubBytesAndXOR.o: ../AES_SR_InvSubBytesAndXOR.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_SubBytes.o: ../AES_SF_SubBytes.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_SubBytes.o: ../AES_SR_SubBytes.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_expandedKey.o: ../AES_expandedKey.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_Enc_commen.o: ../AES_Enc_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_Dec_commen.o: ../AES_Dec_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_128_commen.o: ../AES_SF_128_commen.S ../AES_KEY_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_192_commen.o: ../AES_SF_192_commen.S ../AES_KEY_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SF_256_commen.o: ../AES_SF_256_commen.S ../AES_KEY_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_128_commen.o: ../AES_SR_128_commen.S ../AES_KEY_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_192_commen.o: ../AES_SR_192_commen.S ../AES_KEY_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

AES_SR_256_commen.o: ../AES_SR_256_commen.S ../AES_KEY_commen.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

aes_test.o: ../aes_test.c ../aes.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

rsa_mul.o: ../rsa_mul.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

rsa_modulo.o: ../rsa_modulo.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

rsa_modulo_P.o: ../rsa_modulo_P.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

rsa_dec.o: ../rsa_dec.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

rsa_enc.o: ../rsa_enc.S
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

rsa_decrypt.o: ../rsa_decrypt.c ../rsa.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

rsa_encrypt.o: ../rsa_encrypt.c ../rsa.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

rsa_decrypt_P.o: ../rsa_decrypt_P.c ../rsa.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

rsa_encrypt_P.o: ../rsa_encrypt_P.c ../rsa.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

des_commen.o: ../des_commen.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

des_dec.o: ../des_dec.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

des_enc.o: ../des_enc.S 
	$(CC) $(INCLUDES) $(ASMFLAGS) -c   $< -o $@

des_decrypt.o: ../des_decrypt.c ../des.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

des_encrypt.o: ../des_encrypt.c ../des.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

des_triple_decrypt.o: ../des_triple_decrypt.c ../des.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@

des_triple_encrypt.o: ../des_triple_encrypt.c ../des.h
	$(CC) $(INCLUDES) $(CFLAGS) -c   $< -o $@



##Link
$(TARGET): $(OBJECTS) $(LIBS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

%.eep: $(TARGET)
	avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}


## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) $(AVRCRYPTOOBJECTS) $(AESCRYPTOOBJECTS) $(LIBS) AVRCrypto.elf dep/ AVRCrypto.hex AVRCrypto.eep AVRCrypto.lss AVRCrypto.map


## Other dependencies
-include $(shell mkdir dep 2>/dev/null) $(wildcard dep/*)

