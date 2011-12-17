#include "AVRCrytolib.h"
// By Emile van der Laan
// www.emsign.nl
//
/* 5557599a 1083edf6 e848193d dca0024a db696871 */
unsigned char test_sha(void)
{

unsigned char c[]={"000000800000001F00000000"};

Sha_Init();
Sha_Update(c,strlen((char *)c));
Sha_Final();
return (  Sha_Info.Digest[0]!= 0x5557599a ||
		  Sha_Info.Digest[1]!= 0x1083edf6 ||
		  Sha_Info.Digest[2]!= 0xe848193d ||
		  Sha_Info.Digest[3]!= 0xdca0024a ||
		  Sha_Info.Digest[4]!= 0xdb696871 );

}



/* 84983e44 1c3bd26e baae4aa1 f95129e5 e54670f1 */
unsigned char  test_sha2(void)
{
unsigned char a[]={"abcdbcdecdefdefgefghfg"};
unsigned char b[]={"highijhijkijkljklmklmnlmnomnopnopq"};

Sha_Init();
Sha_Update(a,strlen((char *)a));
Sha_Update(b,strlen((char *)b));

Sha_Final();

return (  Sha_Info.Digest[0]!= 0x84983e44 ||
		  Sha_Info.Digest[1]!= 0x1c3bd26e ||
		  Sha_Info.Digest[2]!= 0xbaae4aa1 ||
		  Sha_Info.Digest[3]!= 0xf95129e5 ||
		  Sha_Info.Digest[4]!= 0xe54670f1 );

}

/* fe855cb3869613d69b086d7fa27d0e643f98436d */
// abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqSHATestFectorsJustFortesting:SHATestFectorsJustFortesting:SHATestFectorsJustFortesting

unsigned char  test_sha3(void)
{
unsigned char a[]={"abcdbcdecdefdefgefghfg"};
unsigned char b[]={"highijhijkijkljklmklmnlmnomnopnopq"};
unsigned char c[]={"SHATestFectorsJustFortesting:SHATestFectorsJustFortesting:SHATestFectorsJustFortesting"};

Sha_Init();
Sha_Update(a,strlen((char *)a));
Sha_Update(b,strlen((char *)b));
Sha_Update(a,strlen((char *)a));
Sha_Update(b,strlen((char *)b));
Sha_Update(c,strlen((char *)c));
Sha_Final();
/*  */

return (  Sha_Info.Digest[0]!= 0xfe855cb3 ||
		  Sha_Info.Digest[1]!= 0x869613d6 ||
		  Sha_Info.Digest[2]!= 0x9b086d7f ||
		  Sha_Info.Digest[3]!= 0xa27d0e64 ||
		  Sha_Info.Digest[4]!= 0x3f98436d );
}


unsigned char  test_sha4(void)
{
unsigned char a[]={"The quick brown fox jumps over the lazy dog"};

Sha_Init();
Sha_Update(a,strlen((char *)a));
Sha_Final();
/*  */
return (  Sha_Info.Digest[0]!= 0x2fd4e1c6 ||
		  Sha_Info.Digest[1]!= 0x7a2d28fc ||
		  Sha_Info.Digest[2]!= 0xed849ee1 ||
		  Sha_Info.Digest[3]!= 0xbb76e739 ||
		  Sha_Info.Digest[4]!= 0x1b93eb12 );
}

// This is a test for data from Flash
/* fe855cb3869613d69b086d7fa27d0e643f98436d */
// abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqSHATestFectorsJustFortesting:SHATestFectorsJustFortesting:SHATestFectorsJustFortesting

unsigned char PROGMEM a_sha[]={"abcdbcdecdefdefgefghfg"};
unsigned char PROGMEM b_sha[]={"highijhijkijkljklmklmnlmnomnopnopq"};
unsigned char PROGMEM c_sha[]={"SHATestFectorsJustFortesting:SHATestFectorsJustFortesting:SHATestFectorsJustFortesting"};

unsigned char  test_sha5(void)
{
Sha_Init();
Sha_Update_P(a_sha,sizeof(a_sha)-1);
Sha_Update_P(b_sha,sizeof(b_sha)-1);
Sha_Update_P(a_sha,sizeof(a_sha)-1);
Sha_Update_P(b_sha,sizeof(b_sha)-1);
Sha_Update_P(c_sha,sizeof(c_sha)-1);
Sha_Final();
/*  */

return (  Sha_Info.Digest[0]!= 0xfe855cb3 ||
		  Sha_Info.Digest[1]!= 0x869613d6 ||
		  Sha_Info.Digest[2]!= 0x9b086d7f ||
		  Sha_Info.Digest[3]!= 0xa27d0e64 ||
		  Sha_Info.Digest[4]!= 0x3f98436d );
}

unsigned char sha_test(void)
{
unsigned char Ret=0;
if(test_sha()) Ret|=0x01;
if(test_sha2()) Ret|=0x02;
if(test_sha3()) Ret|=0x04;
if(test_sha4()) Ret|=0x08;
if(test_sha5()) Ret|=0x10;
return Ret;
}
