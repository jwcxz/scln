#ifndef _MD5_H_
#define _MD5_H_
#include <avr/pgmspace.h>

extern unsigned char Md5_Digest[16];

void MD5Init(void);
void MD5Update(unsigned char *,unsigned int );
void MD5Update_P(UPGM_P ,unsigned int );
void MD5Final(void);
void MD5Transform(void);

#endif // _MD5_H_
