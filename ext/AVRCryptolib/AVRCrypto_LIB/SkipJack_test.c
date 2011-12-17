// By Emile van der Laan
// www.emsign.nl
//
// This is the test container of the skipjack algridem
// It is not part of the AVRCrypto lib 
// It is for an example and for my testing

//"SKIPJACK and KEA Algorithm Specifications", "version 2.0", "29 May 1998"
// http://jya.com/skipjack-spec.htm

// 11.543 ms @ 16mc for the test in C And 2114 bytes
//  1.521 ms @ 16mc for the asamber version and 790 bytes of code
// 360 us / skipJack

#include "AVRCrytolib.h"

unsigned char SkipJack_Test_Key[10];
unsigned char SkipJack_Test_Plain[8];
unsigned char SkipJack_Test_Cipher[8];

// Test vector input
//Key 00998877665544332211
//Bin input 33221100ddccbbaa 
//Bin   out 2587cae27a12d300

unsigned char PROGMEM SkipJack_Test1_Key[10] ={0x00,0x99,0x88,0x77,0x66,0x55,0x44,0x33,0x22,0x11};
unsigned char PROGMEM SkipJack_Test1_Plain[] ={0x33,0x22,0x11,0x00,0xdd,0xcc,0xbb,0xaa};
unsigned char PROGMEM SkipJack_Test1_Cipher[]={0x25,0x87,0xca,0xe2,0x7a,0x12,0xd3,0x00};

unsigned char PROGMEM SkipJack_Test2_Key[10] ={0xe7,0x49,0x6e,0x99,0xe4,0x62,0x8b,0x7f,0x9f,0xfb};
unsigned char PROGMEM SkipJack_Test2_Plain[] ={0x99,0xcc,0xfe,0x2b,0x90,0xfd,0x55,0x0b};
unsigned char PROGMEM SkipJack_Test2_Cipher[]={0x60,0xa7,0x3d,0x38,0x7b,0x51,0x7f,0xca};

// 11223344556677889900   AABBCCDD00112233   00D3127AE2CA8725


unsigned char SkipJack_test(void)
{
unsigned char ret=0;

	memcpy_P(SkipJack_Test_Key,SkipJack_Test1_Key,sizeof(SkipJack_Test1_Key));
	memcpy_P(SkipJack_Test_Plain,SkipJack_Test1_Plain,sizeof(SkipJack_Test1_Plain));
	SkipJack_Enc(SkipJack_Test_Plain, SkipJack_Test_Key);
	if(memcmp_P(SkipJack_Test_Plain,SkipJack_Test1_Cipher,sizeof(SkipJack_Test1_Cipher)))
	{
		ret|=1;
	}

	memcpy_P(SkipJack_Test_Key,SkipJack_Test1_Key,sizeof(SkipJack_Test1_Key));
	memcpy_P(SkipJack_Test_Plain,SkipJack_Test1_Cipher,sizeof(SkipJack_Test1_Cipher));
	SkipJack_Dec(SkipJack_Test_Plain, SkipJack_Test_Key);
	if(memcmp_P(SkipJack_Test_Plain,SkipJack_Test1_Plain,sizeof(SkipJack_Test1_Plain)))
	{
		ret|=2;
	}

	memcpy_P(SkipJack_Test_Key,SkipJack_Test2_Key,sizeof(SkipJack_Test2_Key));
	memcpy_P(SkipJack_Test_Plain,SkipJack_Test2_Plain,sizeof(SkipJack_Test2_Plain));
	SkipJack_Enc(SkipJack_Test_Plain, SkipJack_Test_Key);
	if(memcmp_P(SkipJack_Test_Plain,SkipJack_Test2_Cipher,sizeof(SkipJack_Test2_Cipher)))
	{
		ret|=4;
	}

	memcpy_P(SkipJack_Test_Key,SkipJack_Test2_Key,sizeof(SkipJack_Test2_Key));
	memcpy_P(SkipJack_Test_Plain,SkipJack_Test2_Cipher,sizeof(SkipJack_Test2_Cipher));
	SkipJack_Dec(SkipJack_Test_Plain, SkipJack_Test_Key);
	if(memcmp_P(SkipJack_Test_Plain,SkipJack_Test2_Plain,sizeof(SkipJack_Test2_Plain)))
	{
		ret|=8;
	}


return ret;
}
