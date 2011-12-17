#ifndef __RSA_H__
#define __RSA_H__
#include <avr/pgmspace.h>
void rsa_decrypt(unsigned int uiKeySize,unsigned char *pucRsa_data ,unsigned int    uiExponent,unsigned char  *pucModulo,unsigned char *pucRsa_s,unsigned char *pucRsa_tmp);
void rsa_encrypt(unsigned int uiKeySize,unsigned char *pucRsa_data ,unsigned char *pucExponent,unsigned char  *pucModulo,unsigned char *pucRsa_s,unsigned char *pucRsa_tmp);

void rsa_decrypt_P(unsigned int uiKeySize,unsigned char *pucRsa_data ,unsigned int uiExponent,UPGM_P pucModulo,unsigned char *pucRsa_s,unsigned char *pucRsa_tmp);
void rsa_encrypt_P(unsigned int uiKeySize,unsigned char *pucRsa_data ,UPGM_P pucExponent,UPGM_P pucModulo,unsigned char *pucRsa_s,unsigned char *pucRsa_tmp);

#endif // __RSA_H__

