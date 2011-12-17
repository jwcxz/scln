
// This is a RSA implementation for the Mega or AVR4 core that is a at90s8515 
// By Emile van der Laan.
// www.emsign.nl

#include "AVRCrytolib.h"
#include "rsa_asm.h"


void rsa_encrypt(unsigned int uiKeySize,unsigned char *pucRsa_data ,unsigned char *pucExponent,unsigned char  *pucModulo,unsigned char *pucRsa_s,unsigned char *pucRsa_tmp)
{
unsigned char flag=1;
/* s = 1 */
/* a = a^e%d */
while(rsa_memtst(uiKeySize,pucExponent))
  {
	if(!flag)
	{
	/* a=(a*a)%d   */
	  rsa_mull(uiKeySize,pucRsa_data,pucRsa_data,pucRsa_tmp); /* TMP = A * A    */
	  rsa_modulo(uiKeySize,pucRsa_tmp,pucModulo,pucRsa_data); /* A   = TMP % D  */
	}
	if((unsigned char) (pucExponent[uiKeySize-1] & 1))
	  {/*   s=(s*a)%d; */
	   if(flag)
		  { flag=0;
		  memcpy(pucRsa_s,pucRsa_data,uiKeySize);
		  }
		else
		  {
		  rsa_mull(uiKeySize,pucRsa_data,pucRsa_s,pucRsa_tmp); /* TMP = A*S   */
		  rsa_modulo(uiKeySize,pucRsa_tmp,pucModulo,pucRsa_s); /* S = TMP % D */
		  }
	  }
	rsa_ror(uiKeySize,pucExponent);
  }
memcpy(pucRsa_data,pucRsa_s,uiKeySize);
}
