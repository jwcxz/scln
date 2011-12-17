; This is part of the AES
; by Emile van der Laan
; www.emsign.nl

#define	AES_KEY_LENGTH (AES_KEY_SIZE/8) //!< Key length in number of bytes.
#define	AES_ROUNDS (6+(AES_KEY_LENGTH/4))//10 //!< Number of rounds.
#define AES_BLOCKSIZE 16 //
#define	AES_EXPANDED_KEY_SIZE (AES_BLOCKSIZE * (AES_ROUNDS+1)) //!< 176, 208 or 240 bytes.

	.data
	.extern	AES_expandedKey

	.text
	.extern	AES_CalcSBox
	.extern	AES_CalcSBoxInv
	.extern AES_XORBytes
	.extern AES_SF_SubBytes
	.extern AES_SR_SubBytes

#ifdef AES_SMALL_FLASH 
#if AES_KEY_SIZE == 128
	.global AES_128_SF_Encrypt
AES_128_SF_Encrypt:
#elif AES_KEY_SIZE == 192
	.global AES_192_SF_Encrypt
AES_192_SF_Encrypt:
#elif AES_KEY_SIZE == 256
	.global AES_256_SF_Encrypt
AES_256_SF_Encrypt:
#endif
#endif

#ifdef AES_SMALL_RAM 
#if AES_KEY_SIZE == 128
	.global AES_128_SR_Encrypt
AES_128_SR_Encrypt:
#elif AES_KEY_SIZE == 192
	.global AES_192_SR_Encrypt
AES_192_SR_Encrypt:
#elif AES_KEY_SIZE == 256
	.global AES_256_SR_Encrypt
AES_256_SR_Encrypt:
#endif
#endif

;void AESEncrypt( unsigned char * block )
;{
;	unsigned char round = ROUNDS-1;
;	unsigned char * ex_Key = AES_expandedKey;
;
;	AES_XORBytes( block, ex_Key, 16 );
;	ex_Key += BLOCKSIZE;
;
;	do {
;		AES_SubBytes( block, 16 );
;		AES_ShiftRows( block );
;		AES_MixColumns( block );
;		AES_XORBytes( block, ex_Key, 16 );
;		ex_Key += BLOCKSIZE;
;	} while( --round );
;
;	AES_SubBytes( block, 16 );
;	AES_ShiftRows( block );
;	AES_XORBytes( block, ex_Key, 16 );
;}

;void AESEncrypt( unsigned char * block )
; unsigned char * block R25/R24 (Hi/low)
	push	r16
	push	r17
    push	r28
    push	r29
    in	r28, 0x3d
    in	r29, 0x3e
    sbiw	r28, 0x05
    in	r0, 0x3f
    cli
    out	0x3e, r29
    out	0x3f, r0
    out	0x3d, r28

    std	Y+5, r25
    std	Y+4, r24
;	unsigned char round = ROUNDS-1;
;	unsigned char * ex_Key = AES_expandedKey;
    ldi	r22, AES_ROUNDS-1	
    std	Y+3, r22	
    lds	r22, AES_expandedKey  
    lds	r23, AES_expandedKey+1
;	AES_XORBytes( block, ex_Key, 16 );
;	ex_Key += BLOCKSIZE;
	movw r26,r22
    adiw r26, 0x10	; 16
    std	Y+2, r27
    std	Y+1, r26
    ldi	r20, 0x10
    call	AES_XORBytes
;	do {
AESEncrypt1:
;		AES_SubBytes( block, 16 );
    ldd	r24, Y+4	; 0x04
    ldd	r25, Y+5	; 0x05
    ldi	r22, 0x10	; 16
#ifdef AES_SMALL_RAM 
	call	AES_SR_SubBytes
#endif
#ifdef AES_SMALL_FLASH 
	call	AES_SF_SubBytes
#endif
;		AES_ShiftRows( block );
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    call	AES_ShiftRows
;		AES_MixColumns( block );
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    call	AES_MixColumns
;		AES_XORBytes( block, ex_Key, 16 );
    ldd	r22, Y+1
    ldd	r23, Y+2
;		ex_Key += BLOCKSIZE;
	movw r24,r22
    adiw	r24, 0x10
    std	Y+2, r25
    std	Y+1, r24
    ldd	r24, Y+4
    ldd	r25, Y+5
    ldi	r20, 0x10
    call	AES_XORBytes
;	} while( --round );
    ldd	r24, Y+3
    subi	r24, 0x01
    std	Y+3, r24
    brne	AESEncrypt1
;	AES_SubBytes( block, 16 );
    ldd	r24, Y+4
    ldd	r25, Y+5
    ldi	r22, 0x10
#ifdef AES_SMALL_RAM 
	call	AES_SR_SubBytes
#endif
#ifdef AES_SMALL_FLASH 
	call	AES_SF_SubBytes
#endif
;	AES_ShiftRows( block );
    ldd	r24, Y+4
    ldd	r25, Y+5
    call	AES_ShiftRows
;	AES_XORBytes( block, ex_Key, 16 );
    ldd	r22, Y+1	
    ldd	r23, Y+2	
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    ldi	r20, 0x10	
    call	AES_XORBytes	 
    adiw	r28, 0x05
    in	r0, 0x3f	
    cli
    out	0x3e, r29	
    out	0x3f, r0	
    out	0x3d, r28	
    pop	r29
    pop	r28
	pop r17
	pop r16
    ret
