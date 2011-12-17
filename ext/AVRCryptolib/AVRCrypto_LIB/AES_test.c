#include "AVRCrytolib.h"


unsigned char PROGMEM AES_Test_Data_1[] ={ 
    0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d,0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34,
    0x4a, 0x40, 0x93, 0x82, 0x22, 0x99, 0xf3, 0x1d,0x00, 0x82, 0xef, 0xa9, 0x8e, 0xc4, 0xe6, 0xc8
};
unsigned char PROGMEM AES_Test_Key_1[] ={
    0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6,0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c,
    0x76, 0x2e, 0x71, 0x60, 0xf3, 0x8b, 0x4d, 0xa5,0x6a, 0x78, 0x4d, 0x90, 0x45, 0x19, 0x0c, 0xfe
};
unsigned char PROGMEM AES_Test_Result_128_1[] ={ 0x39,0x25,0x84,0x1d,0x02,0xdc,0x09,0xfb,0xdc,0x11,0x85,0x97,0x19,0x6a,0x0b,0x32 };
unsigned char PROGMEM AES_Test_Result_192_1[] ={ 0xf9,0xfb,0x29,0xae,0xfc,0x38,0x4a,0x25,0x03,0x40,0xd8,0x33,0xb8,0x7e,0xbc,0x00 };
unsigned char PROGMEM AES_Test_Result_256_1[] ={ 0x1a,0x6e,0x6c,0x2c,0x66,0x2e,0x7d,0xa6,0x50,0x1f,0xfb,0x62,0xbc,0x9e,0x93,0xf3 };


unsigned char PROGMEM AES_Test_Key_2[] ={
	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
};
unsigned char PROGMEM AES_Test_Data_2[] ={ 
	0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff
};

unsigned char PROGMEM AES_Test_Result_128_2[] ={ 0x69,0xc4,0xe0,0xd8,0x6a,0x7b,0x04,0x30,0xd8,0xcd,0xb7,0x80,0x70,0xb4,0xc5,0x5a };
unsigned char PROGMEM AES_Test_Result_192_2[] ={ 0xdd,0xa9,0x7c,0xa4,0x86,0x4c,0xdf,0xe0,0x6e,0xaf,0x70,0xa0,0xec,0x0d,0x71,0x91 };
unsigned char PROGMEM AES_Test_Result_256_2[] ={ 0x8e,0xa2,0xb7,0xca,0x51,0x67,0x45,0xbf,0xea,0xfc,0x49,0x90,0x4b,0x49,0x60,0x89 };

unsigned char tempbuf[256];
unsigned char tempbuf1[ 256 ]; //!< Workspace 1.
unsigned char tempbuf2[ 256 ]; //!< Worksapce 2.


unsigned char AES_Key[256/8];
unsigned char AES_Data[256/8];

unsigned char AES_SF_test(void)
{
	unsigned char ret = 0;
	unsigned char Key_len = 0;
	unsigned char Plain_len = 0;

// length:  block = 16 bytes, key = 16 bytes
// key     = 2b7e151628aed2a6abf7158809cf4f3c
// input   = 3243f6a8885a308d313198a2e0370734
// encrypt = 3925841d02dc09fbdc118597196a0b32
	Key_len=16;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_128_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );	
	AES_128_SF_Encrypt(AES_Data);
	AES_128_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=0x10;

	Key_len=16;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	AES_128_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_128_SF_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_128_1,Plain_len))	ret|=1;
	AES_128_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 24 bytes
// key     = 2b7e151628aed2a6abf7158809cf4f3c762e7160f38b4da5
// input   = 3243f6a8885a308d313198a2e0370734
// encrypt = f9fb29aefc384a250340d833b87ebc00
	Key_len=24;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	AES_192_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_192_SF_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_192_1,Plain_len))	ret|=1;
	AES_192_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 32 bytes
// key     = 2b7e151628aed2a6abf7158809cf4f3c762e7160f38b4da56a784d9045190cfe
// input   = 3243f6a8885a308d313198a2e0370734
// encrypt = 1a6e6c2c662e7da6501ffb62bc9e93f3

	Key_len=32;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	AES_256_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_256_SF_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_256_1,Plain_len))	ret|=1;
	AES_256_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=1;


// length:  block = 16 bytes, key = 16 bytes
// key     = 000102030405060708090a0b0c0d0e0f
// input   = 00112233445566778899aabbccddeeff
// encrypt = 69c4e0d86a7b0430d8cdb78070b4c55a

	Key_len=16;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_2,Key_len);
	AES_128_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_2,Plain_len);
	AES_128_SF_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_128_2,Plain_len))	ret|=1;
	AES_128_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_2,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 24 bytes
// key     = 000102030405060708090a0b0c0d0e0f1011121314151617
// input   = 00112233445566778899aabbccddeeff
// encrypt = dda97ca4864cdfe06eaf70a0ec0d7191
	Key_len=24;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_2,Key_len);
	AES_192_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_2,Plain_len);
	AES_192_SF_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_192_2,Plain_len))	ret|=1;
	AES_192_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_2,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 32 bytes
// key     = 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
// input   = 00112233445566778899aabbccddeeff
// encrypt = 8ea2b7ca516745bfeafc49904b496089

	Key_len=32;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_2,Key_len);
	AES_256_SF_Init( tempbuf,tempbuf1,tempbuf2 ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_2,Plain_len);
	AES_256_SF_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_256_2,Plain_len))	ret|=1;
	AES_256_SF_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_2,Plain_len))	ret|=1;
	return ret;
}

unsigned char AES_SR_test(void)
{
	unsigned char ret = 0;
	unsigned char Key_len = 0;
	unsigned char Plain_len = 0;

	Key_len=16;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_128_SR_Init( tempbuf ,AES_Key );
	AES_128_SR_Encrypt(AES_Data);
	AES_128_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=0x10;


// length:  block = 16 bytes, key = 16 bytes
// key     = 2b7e151628aed2a6abf7158809cf4f3c
// input   = 3243f6a8885a308d313198a2e0370734
// encrypt = 3925841d02dc09fbdc118597196a0b32
	Key_len=16;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	AES_128_SR_Init( tempbuf ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_128_SR_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_128_1,Plain_len))	ret|=1;


	memcpy_P(AES_Data,AES_Test_Result_128_1,Plain_len);
	AES_128_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=1;


// length:  block = 16 bytes, key = 24 bytes
// key     = 2b7e151628aed2a6abf7158809cf4f3c762e7160f38b4da5
// input   = 3243f6a8885a308d313198a2e0370734
// encrypt = f9fb29aefc384a250340d833b87ebc00
	Key_len=24;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	AES_192_SR_Init( tempbuf ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_192_SR_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_192_1,Plain_len))	ret|=1;
	AES_192_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 32 bytes
// key     = 2b7e151628aed2a6abf7158809cf4f3c762e7160f38b4da56a784d9045190cfe
// input   = 3243f6a8885a308d313198a2e0370734
// encrypt = 1a6e6c2c662e7da6501ffb62bc9e93f3

	Key_len=32;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_1,Key_len);
	AES_256_SR_Init( tempbuf ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_1,Plain_len);
	AES_256_SR_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_256_1,Plain_len))	ret|=1;
	AES_256_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_1,Plain_len))	ret|=1;


// length:  block = 16 bytes, key = 16 bytes
// key     = 000102030405060708090a0b0c0d0e0f
// input   = 00112233445566778899aabbccddeeff
// encrypt = 69c4e0d86a7b0430d8cdb78070b4c55a

	Key_len=16;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_2,Key_len);
	AES_128_SR_Init( tempbuf ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_2,Plain_len);
	AES_128_SR_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_128_2,Plain_len))	ret|=1;
	AES_128_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_2,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 24 bytes
// key     = 000102030405060708090a0b0c0d0e0f1011121314151617
// input   = 00112233445566778899aabbccddeeff
// encrypt = dda97ca4864cdfe06eaf70a0ec0d7191
	Key_len=24;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_2,Key_len);
	AES_192_SR_Init( tempbuf ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_2,Plain_len);
	AES_192_SR_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_192_2,Plain_len))	ret|=1;
	AES_192_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_2,Plain_len))	ret|=1;

// length:  block = 16 bytes, key = 32 bytes
// key     = 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
// input   = 00112233445566778899aabbccddeeff
// encrypt = 8ea2b7ca516745bfeafc49904b496089

	Key_len=32;
	Plain_len=16;
	memcpy_P(AES_Key,AES_Test_Key_2,Key_len);
	AES_256_SR_Init( tempbuf ,AES_Key );
	memcpy_P(AES_Data,AES_Test_Data_2,Plain_len);
	AES_256_SR_Encrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Result_256_2,Plain_len))	ret|=1;
	AES_256_SR_Decrypt(AES_Data);
	if(memcmp_P(AES_Data,AES_Test_Data_2,Plain_len))	ret|=1;
	return ret;
}

unsigned char AES_test(void)
{
unsigned char ret = 0;

	if(AES_SF_test())ret|=1; // This will test the Small Flash version of the AES 
	if(AES_SR_test())ret|=2; // This will test the Small Ram  version of the AES 

return ret;
}
