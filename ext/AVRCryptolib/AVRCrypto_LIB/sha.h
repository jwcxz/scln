#ifndef _SHA_H_
#define _SHA_H_

/* Secure Hash Algorithm */
/* Useful defines & typedefs */
#include <avr/pgmspace.h>

#define SHA_BLOCKSIZE		64
#define SHA_DIGESTSIZE		20

typedef struct {
	unsigned long Data[16];		/* SHA data buffer */
	unsigned long Digest[5];		/* message digest */
	unsigned long Count_lo, Count_hi;	/* 64-bit bit count */
	int Local;			/* unprocessed amount in data */
} SHA_INFO;

extern SHA_INFO Sha_Info;

void Sha_Init();
void Sha_Update(unsigned char *, unsigned int);
void Sha_Update_P(UPGM_P , unsigned int);
void Sha_Final();

#endif /* _SHA_H_ */
