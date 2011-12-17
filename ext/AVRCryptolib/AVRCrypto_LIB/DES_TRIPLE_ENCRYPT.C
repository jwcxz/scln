#include "des.h"
#include <avr/pgmspace.h>
#include <string.h>

/*----------------------------------------------------------------
  Triple D E S 
  By Emile van der Laan
-----------------------------------------------------------------*/
void Triple_Des_Encrypt(unsigned char *binput, unsigned char *boutput, unsigned char *bkey)
{
 	memcpy(Des_Key,&bkey[0],8);
	DesKeyScheduleCalculation();
	memcpy(Des_Input,binput,8);
	Des_Enc();
 	memcpy(Des_Key,&bkey[8],8);
	DesKeyScheduleCalculation();
	Des_Dec();
 	memcpy(Des_Key,&bkey[0],8);
	DesKeyScheduleCalculation();
	Des_Enc();
	memcpy(boutput,Des_Input,8);

//unsigned char temp[8];
//des_encrypt	(binput,temp,&bkey[0]);
//des_decrypt	(temp,temp,&bkey[8]);
//des_encrypt	(temp,boutput,&bkey[0]);
}
