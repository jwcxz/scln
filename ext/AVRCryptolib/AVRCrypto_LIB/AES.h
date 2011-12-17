#ifndef __AES_H_
#define __AES_H_

extern void AES_128_SF_Init( unsigned char * tempbuf,unsigned char *tempbuf1,unsigned char *tempbuf2,unsigned char *AES_Key  );
extern void AES_128_SF_Encrypt( unsigned char * block );
extern void AES_128_SF_Decrypt( unsigned char * block );

extern void AES_192_SF_Init( unsigned char * tempbuf,unsigned char *tempbuf1,unsigned char *tempbuf2,unsigned char *AES_Key  );
extern void AES_192_SF_Encrypt( unsigned char * block );
extern void AES_192_SF_Decrypt( unsigned char * block );

extern void AES_256_SF_Init( unsigned char * tempbuf,unsigned char *tempbuf1,unsigned char *tempbuf2,unsigned char *AES_Key  );
extern void AES_256_SF_Encrypt( unsigned char * block );
extern void AES_256_SF_Decrypt( unsigned char * block );

extern void AES_128_SR_Init( unsigned char * tempbuf,unsigned char *AES_Key  );
extern void AES_128_SR_Encrypt( unsigned char * block );
extern void AES_128_SR_Decrypt( unsigned char * block );

extern void AES_192_SR_Init( unsigned char * tempbuf,unsigned char *AES_Key  );
extern void AES_192_SR_Encrypt( unsigned char * block );
extern void AES_192_SR_Decrypt( unsigned char * block );

extern void AES_256_SR_Init( unsigned char * tempbuf,unsigned char *AES_Key  );
extern void AES_256_SR_Encrypt( unsigned char * block );
extern void AES_256_SR_Decrypt( unsigned char * block );

#endif /* _AES_H_ */
