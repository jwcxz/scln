#include "AVRCrytolib.h"

unsigned char rsa_test(void);
unsigned char des_test(void);
unsigned char sha_test(void);
unsigned char md5_test(void);
unsigned char SkipJack_test(void); 
unsigned char AES_test(void); 
int main(void )
{
unsigned char ret=0;
	if(md5_test()) ret|=0x01;
	if(SkipJack_test())ret|=0x10;
	if(AES_test())ret|=0x20;
	if(sha_test()) ret|=0x02;	
	if(des_test()) ret|=0x04;
	if(rsa_test()) ret|=0x08;
	
	return ret;
}
