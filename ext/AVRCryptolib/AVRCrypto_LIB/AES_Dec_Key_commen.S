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
	.global AES_128_SF_Decrypt
AES_128_SF_Decrypt:
#elif AES_KEY_SIZE == 192
	.global AES_192_SF_Decrypt
AES_192_SF_Decrypt:
#elif AES_KEY_SIZE == 256
	.global AES_256_SF_Decrypt
AES_256_SF_Decrypt:
#endif
#endif

#ifdef AES_SMALL_RAM 
#if AES_KEY_SIZE == 128
	.global AES_128_SR_Decrypt
AES_128_SR_Decrypt:
#elif AES_KEY_SIZE == 192
	.global AES_192_SR_Decrypt
AES_192_SR_Decrypt:
#elif AES_KEY_SIZE == 256
	.global AES_256_SR_Decrypt
AES_256_SR_Decrypt:
#endif
#endif

;void AESDecrypt( unsigned char * block)
;{
	push	r17
	push 	r16
	push	r15
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
    ldi	r26,AES_ROUNDS-1
    std	Y+3, r26
;	unsigned char * ex_Key = AES_expandedKey;
    lds	r22, AES_expandedKey   
    lds	r23, AES_expandedKey+1 
;	ex_Key += AES_BLOCKSIZE * AES_ROUNDS;
    subi	r22, lo8(-(AES_BLOCKSIZE * AES_ROUNDS)); 0x60	; 96
    sbci	r23, hi8(-(AES_BLOCKSIZE * AES_ROUNDS)); 0xFF	; 255
 	movw r26,r22
	;	ex_Key -= AES_BLOCKSIZE;
	sbiw	r26, AES_BLOCKSIZE
    std	Y+2, r27	
    std	Y+1, r26
;	AES_XORBytes( block, ex_Key, 16 );
    ldi	r20, 16 
    call	AES_XORBytes 
;	do {
AES_Decrypt1:
;		AES_InvShiftRows( block );
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    call	AES_InvShiftRows
;		AES_InvSubBytesAndXOR( block, ex_Key, 16 );
    ldd	r22, Y+1	
    ldd	r23, Y+2	
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    ldi	r20, 16
#ifdef AES_SMALL_FLASH 
	call	AES_SF_InvSubBytesAndXOR
#endif
#ifdef AES_SMALL_RAM
	call	AES_SR_InvSubBytesAndXOR
#endif
;		ex_Key -= AES_BLOCKSIZE;
    ldd	r24, Y+1
    ldd	r25, Y+2
    sbiw	r24, AES_BLOCKSIZE
    std	Y+2, r25	
    std	Y+1, r24	
;		AES_InvMixColumns( block );
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    call	AES_InvMixColumns
;	} while( --round );
    ldd	r24, Y+3	
    subi	r24, 0x01
    std	Y+3, r24	
    brne	AES_Decrypt1
;	AES_InvShiftRows( block );
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    call	AES_InvShiftRows
;	AES_InvSubBytesAndXOR( block, ex_Key, 16 );
    ldd	r22, Y+1	
    ldd	r23, Y+2	
    ldd	r24, Y+4	
    ldd	r25, Y+5	
    ldi	r20, 16
#ifdef AES_SMALL_FLASH 
	call	AES_SF_InvSubBytesAndXOR
#endif
#ifdef AES_SMALL_RAM
	call	AES_SR_InvSubBytesAndXOR
#endif

    adiw	r28, 0x05	
    in	r0, 0x3f	
    cli
    out	0x3e, r29	
    out	0x3f, r0	
    out	0x3d, r28	
    pop	r29
    pop	r28
	pop r15
	pop r16
	pop r17
    ret
