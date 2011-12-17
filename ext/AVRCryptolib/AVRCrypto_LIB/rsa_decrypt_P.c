// By Emile van der Laan
// www.emsign.nl

#include "AVRCrytolib.h"
#include "rsa_asm.h"

void rsa_decrypt_P(unsigned int uiKeySize,unsigned char *pucRsa_data ,unsigned int uiExponent,UPGM_P pucModulo,unsigned char *pucRsa_s,unsigned char *pucRsa_tmp)
{
unsigned char flag;
flag=1;
/* s = 1 */
/* a = a^e%d */
while(uiExponent)
  {
	if(uiExponent&1)
	  {/*   s=(s*a)%d; */
	   if(flag)
		  { 
	  		flag=0;
			memcpy(pucRsa_s,pucRsa_data,uiKeySize);
             /*  modulo(tmp,d,s,A_LEN,D_LEN,S_LEN);*/ /* S = A % D */
		  }
		else
		  {
		  	rsa_mull(uiKeySize,pucRsa_data,pucRsa_s,pucRsa_tmp); /* TMP = A*S   */                  
		  	rsa_modulo_P(uiKeySize,pucRsa_tmp,pucModulo,pucRsa_s); /* S = TMP % D */
		  }
	  }
	uiExponent>>=1;
	/* a=(a*a)%d   */
	if(uiExponent) /* A is not used is e == 0 */
	{
	  rsa_mull(uiKeySize,pucRsa_data,pucRsa_data,pucRsa_tmp); /* TMP = A * A    */
	  rsa_modulo_P(uiKeySize,pucRsa_tmp,pucModulo,pucRsa_data); /* A   = TMP % D  */
    }
  }
memcpy(pucRsa_data,pucRsa_s,uiKeySize);
}
