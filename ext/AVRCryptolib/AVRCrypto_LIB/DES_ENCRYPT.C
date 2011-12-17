#include "des.h"
#include <avr/pgmspace.h>
#include <string.h>

/*----------------------------------------------------------------
  D E S ANSI X3.92-1981  
  By Emile van der Laan
-----------------------------------------------------------------*/

void Des_Encrypt(unsigned char *binput, unsigned char *boutput, unsigned char *bkey)
{
	memcpy(Des_Key,bkey,8);
	memcpy(Des_Input,binput,8);

	DesKeyScheduleCalculation();
	Des_Enc();

	memcpy(boutput,Des_Input,8);

}
