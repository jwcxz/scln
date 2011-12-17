#ifndef __DES_H__
#define __DES_H__

extern unsigned char Des_Kns[122]; 	// This buffer you can use if you do not do any des
extern unsigned char Des_Key[8];	// This is also in the Des_Kns buffer 
extern unsigned char Des_Input[8];	// This is also in the Des_Kns buffer

extern void DesKeyScheduleCalculation(void);
extern void Des_Enc(void);
extern void Des_Dec(void);

void Des_Encrypt(unsigned char *pucInput, unsigned char *pucOutput, unsigned char *pucKey);
void Des_Decrypt(unsigned char *pucInput, unsigned char *pucOutput, unsigned char *pucKey);

void Triple_Des_Encrypt(unsigned char *pucInput, unsigned char *pucOutput, unsigned char *pucKey);
void Triple_Des_Decrypt(unsigned char *pucInput, unsigned char *pucOutput, unsigned char *pucKey);

#endif // __DES_H__
