#ifndef _RSA_ASM_H_
#define _RSA_ASM_H_

unsigned char 	rsa_ror    (unsigned int  al,unsigned char	*a);
unsigned char	rsa_memtst (unsigned int al,unsigned char	*a);
void  			rsa_modulo (unsigned int keysize,unsigned char   *a,unsigned char   *b,unsigned char   *c);
void  			rsa_modulo_P (unsigned int keysize,unsigned char   *a,UPGM_P b,unsigned char   *c);
void  			rsa_mull   (unsigned int keySize,unsigned char   *a,unsigned char *b,unsigned char *c);

#endif _RSA_ASM_H_
