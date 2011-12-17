#include <avr/io.h>

#define md5_Info_buf 	md5_Info+0
#define md5_Info_bits 	md5_Info+(4*4)
#define md5_Info_in 	md5_Info+(4*4)+(2*4)
#define md5_Info_inlong md5_Info_in

	.text			; switches to the .text section (code )
	.global	MD5Init
	.global	MD5Transform	
	.global MD5Final
	.extern memcpy_P
	.extern memset

	.data			; switches to the .data section (Ram )
	.global Md5_Digest	
	.global md5_Info	; Needed for the MD5_update
Md5_Digest:
md5_Info:
	.space	(4*4)+(2*4)+64

;unsigned long MD5InfoBuffer[4];
MD5InfoBuffer:
	.space	(4*4)
;unsigned long *PtrWMd5InfoBuf;
PtrWMd5InfoBuf:
	.space 2
;unsigned long *PtrXMd5InfoBuf;
PtrXMd5InfoBuf:
	.space 2
;unsigned long *PtrYMd5InfoBuf;
PtrYMd5InfoBuf:
	.space 2
;unsigned long *PtrZMd5InfoBuf;
PtrZMd5InfoBuf:
	.space 2
;unsigned char MD5TransN;
MD5TransN:
	.space 1

	.section .progmem.data	; switches to the .progmem.data section ( ROM constants as this will be loaded first in rom )
MD5_InitConst:
	.long 0x67452301,0xefcdab89,0x98badcfe,0x10325476; 

MD5DataTransform:
	.long	0xd76aa478 , 0xe8c7b756 , 0x242070db , 0xc1bdceee , 0xf57c0faf , 0x4787c62a , 0xa8304613 , 0xfd469501  
	.long	0x698098d8 , 0x8b44f7af , 0xffff5bb1 , 0x895cd7be , 0x6b901122 , 0xfd987193 , 0xa679438e , 0x49b40821 
	.long	0xf61e2562 , 0xc040b340 , 0x265e5a51 , 0xe9b6c7aa , 0xd62f105d , 0x02441453 , 0xd8a1e681 , 0xe7d3fbc8 
	.long	0x21e1cde6 , 0xc33707d6 , 0xf4d50d87 , 0x455a14ed , 0xa9e3e905 , 0xfcefa3f8 , 0x676f02d9 , 0x8d2a4c8a 
	.long	0xfffa3942 , 0x8771f681 , 0x6d9d6122 , 0xfde5380c , 0xa4beea44 , 0x4bdecfa9 , 0xf6bb4b60 , 0xbebfbc70 
	.long	0x289b7ec6 , 0xeaa127fa , 0xd4ef3085 , 0x04881d05 , 0xd9d4d039 , 0xe6db99e5 , 0x1fa27cf8 , 0xc4ac5665 
	.long	0xf4292244 , 0x432aff97 , 0xab9423a7 , 0xfc93a039 , 0x655b59c3 , 0x8f0ccc92 , 0xffeff47d , 0x85845dd1 
	.long	0x6fa87e4f , 0xfe2ce6e0 , 0xa3014314 , 0x4e0811a1 , 0xf7537e82 , 0xbd3af235 , 0x2ad7d2bb , 0xeb86d391 

MD5RolTransform:
	.byte	7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22
	.byte	5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20
	.byte	4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23
	.byte	6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21

MD5IndexTransform:

	.byte	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
	.byte	1, 6,11, 0, 5,10,15, 4, 9,14, 3, 8,13, 2, 7,12
	.byte	5, 8,11,14, 1, 4, 7,10,13, 0, 3, 6, 9,12,15, 2
	.byte	0, 7,14, 5,12, 3,10, 1, 8,15, 6,13, 4,11, 2, 9

	.text			; switches to the .text section (Code )	
MD5Init:
;    memcpy_P(md5_Info.buf,MD5_InitConst,sizeof(MD5_InitConstante));
    ldi	r20, 0x10	; 16 Len of MD5_InitConst in Bytes 
    ldi	r21, 0x00	; 0
    ldi	r22, lo8(MD5_InitConst)
    ldi	r23, hi8(MD5_InitConst)
    ldi	r24, lo8(md5_Info_buf)
    ldi	r25, hi8(md5_Info_buf)
	call	memcpy_P
;	memset(md5_Info.bits,0,sizeof(md5_Info.bits));
    ldi	r20, 0x08	; Len of md5_Info.bits in Bytes
    ldi	r21, 0x00	; 0
    ldi	r22, 0x00	; 0
    ldi	r24, lo8(md5_Info_bits)
    ldi	r25, hi8(md5_Info_bits)
	jmp	memset

/*
 * The core of the MD5 algorithm, this alters an existing MD5 hash to
 * reflect the addition of 16 longwords of new data.  MD5Update blocks
 * the data and converts bytes into longwords for this routine.
 */


;unsigned long MD5InfoBuffer[4];
;unsigned long *PtrWMd5InfoBuf;
;unsigned long *PtrXMd5InfoBuf;
;unsigned long *PtrYMd5InfoBuf;
;unsigned long *PtrZMd5InfoBuf;
;unsigned char MD5TransN;
;void MD5Transform(void)
;{
MD5Transform:
;    	push	r16
;    	push	r17
; memcpy(MD5InfoBuffer,md5_Info.buf,sizeof(MD5InfoBuffer));
    	ldi	r20, 0x10	; lo8(sizeof(MD5InfoBuffer)); 16
    	ldi	r21, 0x00	; hi8(sizeof(MD5InfoBuffer)); 0
    	ldi	r22, lo8(md5_Info_buf) 
    	ldi	r23, hi8(md5_Info_buf) 
    	ldi	r24, lo8(MD5InfoBuffer) 
    	ldi	r25, hi8(MD5InfoBuffer) 
    	call	memcpy 
;	for(MD5TransN=0;MD5TransN<64;MD5TransN++)
    	sts	MD5TransN,r1
MD5Tran18:
    	lds	r24, MD5TransN
    	cpi	r24, 0x40	; 64
    	brcs	MD5Tran1
    	rjmp	MD5Tran2
;	{
;		  PtrWMd5InfoBuf=&md5_Info.buf[(64-MD5TransN)%4];
;		  PtrXMd5InfoBuf=&md5_Info.buf[(65-MD5TransN)%4];
;		  PtrYMd5InfoBuf=&md5_Info.buf[(66-MD5TransN)%4];
;		  PtrZMd5InfoBuf=&md5_Info.buf[(67-MD5TransN)%4];
MD5Tran1:
    	lds		r17, MD5TransN ;0x0B48
    	ldi		r26, 0x40	; 64
    	ldi		r27, 0x00	; 0
    	sub		r26, r17
		andi 	r26, 3
		add		r26, r26
		add		r26, r26
    	subi	r26, lo8(-(md5_Info_buf)) ;
    	sbci	r27, hi8(-(md5_Info_buf)) ;
    	sts		PtrWMd5InfoBuf+1,R27 ; 
    	sts		PtrWMd5InfoBuf,R26 ; 
    	lds		r17, MD5TransN 
    	ldi		r26, 0x41	; 64
    	ldi		r27, 0x00	; 0
    	sub		r26, r17
		andi 	r26, 3
		add		r26, r26
		add		r26, r26
    	subi	r26, lo8(-(md5_Info_buf)) ;
    	sbci	r27, hi8(-(md5_Info_buf)) ;
    	sts		PtrXMd5InfoBuf+1,R27 ; 
    	sts		PtrXMd5InfoBuf,R26 ; 
    	lds		r17, MD5TransN 
    	ldi		r26, 0x42	; 64
    	ldi		r27, 0x00	; 0
    	sub		r26, r17
		andi 	r26, 3
		add		r26, r26
		add		r26, r26
    	subi	r26, lo8(-(md5_Info_buf)) ;
    	sbci	r27, hi8(-(md5_Info_buf)) ;
    	sts		PtrYMd5InfoBuf+1,R27 ; 
    	sts		PtrYMd5InfoBuf,R26 ; 
    	lds		r17, MD5TransN 
    	ldi		r26, 0x43	; 64
    	ldi		r27, 0x00	; 0
    	sub		r26, r17
		andi 	r26, 3
		add		r26, r26
		add		r26, r26
    	subi	r26, lo8(-(md5_Info_buf)) ;
    	sbci	r27, hi8(-(md5_Info_buf)) ;
    	sts		PtrZMd5InfoBuf+1,R27 ; 
    	sts		PtrZMd5InfoBuf,R26 ; 
;		  switch (MD5TransN/16)
    	lds		r24, MD5TransN 
    	swap	r24
    	andi	r24, 0x0F
    	breq	MD5Tran10
    	cpi		r24, 0x01
    	breq	MD5Tran8 
    	cpi		r24, 0x02
    	brne	MD5Tran7C 
    	rjmp	MD5Tran12 
MD5Tran7C:
    	rjmp	MD5Tran15 
;		  {
;		   case 0:
;		   // (z ^ (x & (y ^ z)))
;			*PtrWMd5InfoBuf += (*PtrZMd5InfoBuf ^ (*PtrXMd5InfoBuf & (*PtrYMd5InfoBuf ^ *PtrZMd5InfoBuf)));
MD5Tran10:
    	lds	r30, PtrZMd5InfoBuf
    	lds	r31, PtrZMd5InfoBuf+1
    	ld	r18, Z
    	ldd	r19, Z+1
    	ldd	r20, Z+2
    	ldd	r21, Z+3
		movw R22,r18
		movw R24,r20
    	lds	r30, PtrYMd5InfoBuf
    	lds	r31, PtrYMd5InfoBuf+1
    	ld	r17, Z
    	eor	r18, r17
    	ldd	r17, Z+1
    	eor	r19, r17
    	ldd	r17, Z+2
    	eor	r20, r17
    	ldd	r17, Z+3
    	eor	r21, r17
    	lds	r30, PtrXMd5InfoBuf
    	lds	r31, PtrXMd5InfoBuf+1
    	ld	r17, Z
    	and	r18, r17
    	ldd	r17, Z+1
    	and	r19, r17
    	ldd	r17, Z+2
    	and	r20, r17
    	ldd	r17, Z+3
    	and	r21, r17
    	eor	r18, r22
    	eor	r19, r23
    	eor	r20, r24
   	 	eor	r21, r25
		rjmp MD5AddPtrWmd5InfoBuf
;		   break;
;		   case 1:
;		   // (y ^ (z & (x ^ y)))
;		   *PtrWMd5InfoBuf +=  (*PtrYMd5InfoBuf ^ ( *PtrZMd5InfoBuf & (*PtrXMd5InfoBuf ^ *PtrYMd5InfoBuf)));
MD5Tran8:
    	lds	r30, PtrYMd5InfoBuf
    	lds	r31, PtrYMd5InfoBuf+1
    	ld	r18, Z
    	ldd	r19, Z+1
    	ldd	r20, Z+2
    	ldd	r21, Z+3
		movw R22,r18
		movw R24,r20
    	lds	r30, PtrXMd5InfoBuf
    	lds	r31, PtrXMd5InfoBuf+1
    	ld	r17, Z
    	eor	r18, r17
    	ldd	r17, Z+1
    	eor	r19, r17
    	ldd	r17, Z+2
    	eor	r20, r17
    	ldd	r17, Z+3
    	eor	r21, r17
    	lds	r30, PtrZMd5InfoBuf
    	lds	r31, PtrZMd5InfoBuf+1
    	ld	r17, Z
    	and	r18, r17
    	ldd	r17, Z+1
    	and	r19, r17
    	ldd	r17, Z+2
    	and	r20, r17
    	ldd	r17, Z+3
    	and	r21, r17
    	eor	r18, r22
    	eor	r19, r23
    	eor	r20, r24
    	eor	r21, r25
		rjmp MD5AddPtrWmd5InfoBuf
;		   case 2:
;		   // (x ^ y ^ z)
;		   *PtrWMd5InfoBuf += (*PtrXMd5InfoBuf ^ *PtrYMd5InfoBuf ^  *PtrZMd5InfoBuf );
MD5Tran12:
    	lds	r30, PtrZMd5InfoBuf
    	lds	r31, PtrZMd5InfoBuf+1
    	ld	r18, Z
    	ldd	r19, Z+1
    	ldd	r20, Z+2
    	ldd	r21, Z+3
    	lds	r30, PtrYMd5InfoBuf
    	lds	r31, PtrYMd5InfoBuf+1
    	ld	r17, Z
    	eor	r18, r17
    	ldd	r17, Z+1
    	eor	r19, r17
    	ldd	r17, Z+2
    	eor	r20, r17
    	ldd	r17, Z+3
    	eor	r21, r17
    	lds	r30, PtrXMd5InfoBuf
    	lds	r31, PtrXMd5InfoBuf+1 
    	ld	r17, Z
    	eor	r18, r17
    	ldd	r17, Z+1
    	eor	r19, r17
    	ldd	r17, Z+2
    	eor	r20, r17
    	ldd	r17, Z+3
    	eor	r21, r17
		rjmp MD5AddPtrWmd5InfoBuf
;		   case 3:
;		   // (y ^ (x | ~z))
;		   *PtrWMd5InfoBuf += (*PtrYMd5InfoBuf ^ ( *PtrXMd5InfoBuf | ~ *PtrZMd5InfoBuf));
MD5Tran15:
    	lds	r30, PtrZMd5InfoBuf
    	lds	r31, PtrZMd5InfoBuf+1
    	ld	r18, Z
    	ldd	r19, Z+1
    	ldd	r20, Z+2
    	ldd	r21, Z+3
    	com	r18
    	com	r19
    	com	r20
    	com	r21
    	lds	r30, PtrXMd5InfoBuf
    	lds	r31, PtrXMd5InfoBuf+1
    	ld	r17, Z
    	or	r18, r17
    	ldd	r17, Z+1
    	or	r19, r17
    	ldd	r17, Z+2
    	or	r20, r17
    	ldd	r17, Z+3
    	or	r21, r17
    	lds	r30, PtrYMd5InfoBuf
    	lds	r31, PtrYMd5InfoBuf+1
    	ld	r17, Z
    	eor	r18, r17
    	ldd	r17, Z+1
    	eor	r19, r17
    	ldd	r17, Z+2
    	eor	r20, r17
    	ldd	r17, Z+3
    	eor	r21, r17
;		  }
MD5AddPtrWmd5InfoBuf:
;		  *PtrWMd5InfoBuf +=  md5_Info.inlong[ __LPM( &MD5IndexTransform[MD5TransN])] 
;         +__LPM_dword( &MD5DataTransform[MD5TransN]);
MD5Tran13:
    	lds		r30, MD5TransN  ; 0x0B48
    	eor		r31, r31
    	subi	r30, lo8(-(MD5IndexTransform)) ;0xE6	; 230
    	sbci	r31, hi8(-(MD5IndexTransform)) ;0xF4	; 244
    	lpm		r17, Z					; The result of LPM R30,z is undefind
		mov		r30, r17
		eor 	r31, r31
    	add		r30, r30
    	add		r30, r30
    	subi	r30, lo8(-(md5_Info_inlong)) 
    	sbci	r31, hi8(-(md5_Info_inlong))
    	ld		r17, Z
    	add		r18, r17
    	ldd		r17, Z+1
    	adc		r19, r17
    	ldd		r17, Z+2
    	adc		r20, r17
    	ldd		r17, Z+3
    	adc		r21, r17
    	lds		r30, MD5TransN
    	eor		r31, r31
    	add		r30, r30
    	add		r30, r30
    	subi	r30, lo8(-(MD5DataTransform))
    	sbci	r31, hi8(-(MD5DataTransform))
    	lpm		r17, Z+
    	add		r18, r17
    	lpm		r17, Z+
    	adc		r19, r17
    	lpm		r17, Z+
    	adc		r20, r17
    	lpm		r17, Z+
    	adc		r21, r17

    	lds		r30, PtrWMd5InfoBuf
    	lds		r31, PtrWMd5InfoBuf+1
    	ldd		r17, Z+0
    	add		r18, r17
    	ldd		r17, Z+1
    	adc		r19, r17
    	ldd		r17, Z+2
    	adc		r20, r17
    	ldd		r17, Z+3
    	adc		r21, r17
;		  {
		ldi R30,lo8(MD5RolTransform)
		ldi R31,hi8(MD5RolTransform)
		lds R24,MD5TransN
		eor	R25,R25
		add R30,R24
		adc R31,R25
		lpm	r17,Z
		eor	R25,R25
More8BitsLeft:
		cpi R17,8
		brcs No8BitsLeft
		subi R17,8
		mov R16,R21
		mov R21,R20
		mov R20,R19
		mov R19,R18
		mov R18,R16
		rjmp More8BitsLeft
No8BitsLeft:
		tst R17
		breq StoreRol
		dec R17								
		add R18,R18
		adc R19,R19
		adc R20,R20
		adc R21,R21
		adc R18,R25
		rjmp No8BitsLeft
StoreRol:
;		  }
;		  *PtrWMd5InfoBuf += *PtrXMd5InfoBuf;
	    lds	r26, PtrXMd5InfoBuf   ;0x0B42
    	lds	r27, PtrXMd5InfoBuf+1 ;0x0B43
	    ld	r17, X+
    	add	r18, r17
	   	ld	r17, X+
    	adc	r19, r17
    	ld	r17, X+
    	adc	r20, r17
    	ld	r17, X+
    	adc	r21, r17

		lds R30,PtrWMd5InfoBuf
		lds R31,PtrWMd5InfoBuf+1
    	std		Z+0, r18
    	std		Z+1, r19	; 0x01
    	std		Z+2, r20	; 0x02
    	std		Z+3, r21	; 0x03
    	lds		r24, MD5TransN ; 0x0B48
    	subi	r24, 0xFF	; 255
    	sts		MD5TransN,R24 ; 0x0B48, r24
    	rjmp	MD5Tran18; 	
;	}

;for(MD5TransN=0;MD5TransN<4;MD5TransN++)
MD5Tran2:
	    sts	MD5TransN,r1 ; 
    	ldi	r26, lo8(md5_Info_buf); 
    	ldi r27, hi8(md5_Info_buf); 
    	ldi r30, lo8(MD5InfoBuffer);
    	ldi r31, hi8(MD5InfoBuffer);
MD5Tran19B:
;	md5_Info.buf[MD5TransN] += MD5InfoBuffer[MD5TransN];
		ld r17,X
		ld R18,Z+
		add R17,r18
		st x+,R17
		ld r17,X
		ld R18,Z+
		adc R17,r18
		st x+,R17
		ld r17,X
		ld R18,Z+
		adc R17,r18
		st x+,R17
		ld r17,X
		ld R18,Z+
		adc R17,r18
		st x+,R17
    	lds	r24, MD5TransN 
    	subi	r24, 0xFF	; 255
    	sts	MD5TransN,r24 
    	cpi	r24, 0x04	; 4
    	brcs	MD5Tran19B 
MD5Tran17:
;    	pop	r17
;    	pop	r16
    	ret

MD5Final:
; * Final wrapup - pad to 64-byte boundary with the bit pattern 
; * 1 0* (64-bit count of bits processed, MSB-first)
; */
;void MD5Final(void)
;{
;    unsigned count;
;    unsigned char *p;
;    /* Compute number of bytes mod 64 */
;    count = (md5_Info.bits[0] >> 3) & 0x3F;
	push r16
	push r17
	lds	r30, md5_Info_bits+0;0x0434
	lds	r31, md5_Info_bits+1;0x0435
	set
	bld	r1, 2
MD5Final1:
	lsr r31
	ror	r30
	lsr	r1
	brne	MD5Final1
	andi	r30, 0x3F
	andi	r31, 0x00
	movw r18,r30
;    /* Set the first char of padding to 0x80.  This is safe since there is
;       always at least one byte free */
;    p = md5_Info.in + count;
	subi	r30, lo8(-(md5_Info_in))
	sbci	r31, hi8(-(md5_Info_in))	
;	movw r16,R30
;    *p++ = 0x80;
	ldi	r24, 0x80
	st	Z+, r24
	movw R16,r30
;    /* Bytes of padding needed to make 64 bytes */
;    count = 64 - 1 - count;
	ldi	r20, 0x3F
	ldi	r21, 0x00
	movw R24,R18
	sub	r20, r24
	sbc	r21, r25
	movw R18,r20
;    /* Pad out to 56 mod 64 */
;    if (count < 8) 
	cpi	r20, 0x08
	cpc	r21, r1
	brcc	MD5Final2
;	{
;		/* Two lots of padding:  Pad the first block to 64 bytes */
;		memset(p, 0, count);	
	movw R24,r16
	ldi	r22, 0x00
	ldi	r23, 0x00
	call	memset
;		MD5Transform();
	call	MD5Transform
;		/* Now fill the next block with 56 bytes */
;		memset(md5_Info.in, 0, 56);
	ldi	r20, 0x38	; 56
	ldi	r26, lo8(md5_Info_in)
	ldi	r27, hi8(md5_Info_in)
MD5Final3:
	st	X+, r1
	dec	r20
	brne	MD5Final3
	rjmp	MD5Final4
;   } else 
;	{
;	/* Pad block to 56 bytes */
;		memset(p, 0, count - 8);
MD5Final2:
	subi	r20, 0x08
	sbci	r21, 0x00
	movw r24,r16
	ldi	r22, 0x00
	ldi	r23, 0x00
	call	memset
;    }
;    /* Append length in bits and transform */
;    ((unsigned long *) md5_Info.in)[14] = md5_Info.bits[0];
MD5Final4:
	ldi	r30, lo8(md5_Info_in+(4*14))
	ldi	r31, hi8(md5_Info_in+(4*14))
	ldi	r26, lo8(md5_Info_bits)
	ldi	r27, hi8(md5_Info_bits)
	ldi	r20, 8
MD5Final4B:
	ld	r21,X+
	st  Z+,r21
	dec r20
	brne MD5Final4B
;    MD5Transform();    
	call	MD5Transform
	pop 	r17
	pop 	r16
	ret 
