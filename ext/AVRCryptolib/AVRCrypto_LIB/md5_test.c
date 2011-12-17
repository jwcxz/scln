#include "AVRCrytolib.h"



/* 0383E285 55C6B2D2 AE6F8F7A 6DF9B307 */
unsigned char PROGMEM test_md5_cmp[]={0x03,0x83,0xE2,0x85,0x55,0xC6,0xB2,0xD2,0xAE,0x6F,0x8F,0x7A,0x6D,0xF9,0xB3,0x07} ;

unsigned char test_md5_1(void)
{

unsigned char c[]={"000000800000001F00000000"};

MD5Init();
MD5Update(c,strlen((char *)c));
MD5Final();
return ( (unsigned char)memcmp_P(Md5_Digest,test_md5_cmp,sizeof(test_md5_cmp)) );
}



/* 8215EF0796A20BCAAAE116D3876C664A */
unsigned char PROGMEM test_md5_2_cmp[]={0x82,0x15,0xEF,0x07,0x96,0xA2,0x0B,0xCA,0xAA,0xE1,0x16,0xD3,0x87,0x6C,0x66,0x4A };
unsigned char  test_md5_2(void)
{
unsigned char a[]={"abcdbcdecdefdefgefghfg"};
unsigned char b[]={"highijhijkijkljklmklmnlmnomnopnopq"};

MD5Init();
MD5Update(a,strlen((char *)a));
MD5Update(b,strlen((char *)b));

MD5Final();

return ((unsigned char) memcmp_P(Md5_Digest,test_md5_2_cmp,sizeof(test_md5_2_cmp)) );

}


// adeb47ec979f9f74a06bd1c9283fb840 
// abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqmd5TestFectorsJustFortesting:md5TestFectorsJustFortesting:md5TestFectorsJustFortesting
unsigned char PROGMEM test_md5_3_cmp[]={0xad,0xeb,0x47,0xec,0x97,0x9f,0x9f,0x74,0xa0,0x6b,0xd1,0xc9,0x28,0x3f,0xb8,0x40};
unsigned char  test_md5_3(void)
{
unsigned char a[]={"abcdbcdecdefdefgefghfg"};
unsigned char b[]={"highijhijkijkljklmklmnlmnomnopnopq"};
unsigned char c[]={"md5TestFectorsJustFortesting:md5TestFectorsJustFortesting:md5TestFectorsJustFortesting"};

MD5Init();
MD5Update(a,strlen((char *)a));
MD5Update(b,strlen((char *)b));
MD5Update(a,strlen((char *)a));
MD5Update(b,strlen((char *)b));
MD5Update(c,strlen((char *)c));
MD5Final();
/*  */

return ( (unsigned char)memcmp_P(Md5_Digest,test_md5_3_cmp,sizeof(test_md5_3_cmp)) );
}

// 9E107D9D372BB6826BD81D3542A419D6
unsigned char PROGMEM test_md5_4_cmp[]={0x9E,0x10,0x7D,0x9D,0x37,0x2B,0xB6,0x82,0x6B,0xD8,0x1D,0x35,0x42,0xA4,0x19,0xD6};
unsigned char  test_md5_4(void)
{
unsigned char a[]={"The quick brown fox jumps over the lazy dog"};

MD5Init();
MD5Update(a,strlen((char *)a));
MD5Final();
/*  */
return ( (unsigned char)memcmp_P(Md5_Digest,test_md5_4_cmp,sizeof(test_md5_4_cmp) ));
}

// This is a test for data from Flash
// adeb47ec979f9f74a06bd1c9283fb840 
unsigned char PROGMEM test_md5_5_cmp[]={0xad,0xeb,0x47,0xec,0x97,0x9f,0x9f,0x74,0xa0,0x6b,0xd1,0xc9,0x28,0x3f,0xb8,0x40};
// abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqmd5TestFectorsJustFortesting:md5TestFectorsJustFortesting:md5TestFectorsJustFortesting
unsigned char PROGMEM a_md5[]={"abcdbcdecdefdefgefghfg"};
unsigned char PROGMEM b_md5[]={"highijhijkijkljklmklmnlmnomnopnopq"};
unsigned char PROGMEM c_md5[]={"md5TestFectorsJustFortesting:md5TestFectorsJustFortesting:md5TestFectorsJustFortesting"};

unsigned char  test_md5_5(void)
{
MD5Init();
MD5Update_P(a_md5,sizeof(a_md5)-1);
MD5Update_P(b_md5,sizeof(b_md5)-1);
MD5Update_P(a_md5,sizeof(a_md5)-1);
MD5Update_P(b_md5,sizeof(b_md5)-1);
MD5Update_P(c_md5,sizeof(c_md5)-1);
MD5Final();
/*  */

return ( (unsigned char)memcmp_P(Md5_Digest,test_md5_5_cmp,sizeof(test_md5_5_cmp) ));
}

unsigned char md5_test(void)
{
unsigned char Ret=0;
if(test_md5_1()) Ret|=0x01;
if(test_md5_2()) Ret|=0x02;
if(test_md5_3()) Ret|=0x04;
if(test_md5_4()) Ret|=0x08;
if(test_md5_5()) Ret|=0x10;
return Ret;
}
