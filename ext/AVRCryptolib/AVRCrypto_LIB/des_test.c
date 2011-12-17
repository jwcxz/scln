#include "AVRCrytolib.h"

//unsigned char PROGMEM DesCryptographicKey[] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef }; 
//unsigned char PROGMEM DesPLAINTEXT[]  = 		{0x4e,0x6,0xf77,0x20,0x69,0x73,0x20,0x74 };
//unsigned char PROGMEM DesCIPHERTEXT[] = 		{0x3f,0xa4,0x0e,0x8a,0x98,0x4d,0x43,0x15 }; 

unsigned char PROGMEM DesCryptographicKey[]	={ 0x12,0x34,0x56,0x67,0x89,0xab,0xcd,0xef };
unsigned char PROGMEM DesPLAINTEXT[]		={ 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08 };
unsigned char PROGMEM DesCIPHERTEXT[]		={ 0xf2,0xac,0x1b,0xc6,0xbf,0x00,0x61,0xd3 };


unsigned char DesKey[8];
unsigned char DesPlain[8];
unsigned char DesCipher[8];

unsigned char PROGMEM Triple_DesCryptographicKey[]	={ 0x12,0x34,0x56,0x67,0x89,0xab,0xcd,0xef,0x22,0x44,0x66,0x88,0xAA,0xBB,0xCC,0xDD };
unsigned char PROGMEM Triple_DesPLAINTEXT[]			={ 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08 };
unsigned char PROGMEM Triple_DesCIPHERTEXT[]		={ 0x1A,0x54,0xE3,0x87,0x44,0x34,0x86,0xBC };

unsigned char Triple_DesKey[16];
unsigned char Triple_DesPlain[8];
unsigned char Triple_DesCipher[8];


unsigned char des_test(void)
{
unsigned char ret=0;

	memcpy_P(DesKey,DesCryptographicKey, sizeof(DesKey));
	memcpy_P(DesPlain,DesPLAINTEXT, sizeof(DesPlain));
	memset(DesCipher,0,sizeof(DesCipher));

	Des_Encrypt(DesPlain,DesCipher,DesKey);
	if(memcmp_P(DesCipher,DesCIPHERTEXT,sizeof(DesCipher)))
		{
			ret|=0x01; // return the error 
		}
	memset(DesPlain,0,sizeof(DesPlain));
	Des_Decrypt(DesCipher,DesPlain,DesKey);
	if(memcmp_P(DesPlain,DesPLAINTEXT,sizeof(DesPlain)))
		{
			ret|=0x02; // return the error 
		}
	memcpy_P(Triple_DesKey,Triple_DesCryptographicKey, sizeof(Triple_DesKey));
	memcpy_P(Triple_DesPlain,Triple_DesPLAINTEXT, sizeof(Triple_DesPlain));
	memset(Triple_DesCipher,0,sizeof(Triple_DesCipher));
	Triple_Des_Encrypt(Triple_DesPlain,Triple_DesCipher,Triple_DesKey);
	if(memcmp_P(Triple_DesCipher,Triple_DesCIPHERTEXT,sizeof(Triple_DesCipher)))
		{
			ret|=0x04; // return the error 
		}
	memset(Triple_DesPlain,0,sizeof(Triple_DesPlain));
	Triple_Des_Decrypt(Triple_DesCipher,Triple_DesPlain,Triple_DesKey);
	if(memcmp_P(Triple_DesPlain,Triple_DesPLAINTEXT,sizeof(Triple_DesPlain)))
		{
			ret|=0x08; // return the error 
		}
	return ret;
}
