; By Emile van der Laan
; www.emsign.nl
;
#define	AES_KEY_LENGTH (AES_KEY_SIZE/8) //!< Key length in number of bytes.
#define	AES_ROUNDS (6+(AES_KEY_LENGTH/4))//10 //!< Number of rounds.
#define AES_BLOCKSIZE 16 //
#define	AES_EXPANDED_KEY_SIZE (AES_BLOCKSIZE * (AES_ROUNDS+1)) //!< 176, 208 or 240 bytes.

	.data
	.extern	AES_sBox
	.extern	AES_sBoxInv
	.extern	AES_expandedKey
	.text
	.extern	AES_CalcSBox
	.extern	AES_CalcSBoxInv
	.extern AES_XORBytes
	.extern AES_SF_SubBytes
	.extern AES_SR_SubBytes

#ifdef AES_SMALL_FLASH 
#if AES_KEY_SIZE == 128
	.global AES_128_SF_Init
#elif AES_KEY_SIZE == 192
	.global AES_192_SF_Init
#elif AES_KEY_SIZE == 256
	.global AES_256_SF_Init
#endif
#endif

#ifdef AES_SMALL_RAM 
#if AES_KEY_SIZE == 128
	.global AES_128_SR_Init
#elif AES_KEY_SIZE == 192
	.global AES_192_SR_Init
#elif AES_KEY_SIZE == 256
	.global AES_256_SR_Init
#endif
#endif

AES_KeyExpansion:
;void AES_KeyExpansion( unsigned char * expandedKey ,unsigned char *AES_key)
;{
;	unsigned char temp[4];
;	unsigned char i;
;	unsigned char t;
;	unsigned char Rcon[4] = { 0x01, 0x00, 0x00, 0x00 }; // Round constant.
;	// Copy key to start of expanded key.
;	i = KEYLENGTH;
;	do {
;		*expandedKey = *AES_key;
;		expandedKey++;
;		AES_key++;
;	} while( --i );
;	// Prepare last 4 bytes of key in temp.
;	expandedKey -= 4;
;	temp[0] = *(expandedKey++);
;	temp[1] = *(expandedKey++);
;	temp[2] = *(expandedKey++);
;	temp[3] = *(expandedKey++);
;
;	// Expand key.
;	i = KEYLENGTH;
;	while( i < BLOCKSIZE*(ROUNDS+1) ) {
;		// Are we at the start of a multiple of the key size?
;		if( (i % KEYLENGTH) == 0 ) {
;			t = temp[0];
;			temp[0] = temp[1];
;			temp[1] = temp[2];
;			temp[2] = temp[3];
;			temp[3] = t;
;//			AES_CycleLeft( temp ); // Cycle left once.
;			AES_SubBytes( temp, 4 ); // Substitute each byte.
;			AES_XORBytes( temp, Rcon, 4 ); // Add constant in GF(2).
;			*Rcon = (*Rcon << 1) ^ (*Rcon & 0x80 ? BPOLY : 0);
;		}
;		// Keysize larger than 24 bytes, ie. larger that 192 bits?
;		#if KEYLENGTH > 24
;		// Are we right past a block size?
;		else if( (i % KEYLENGTH) == BLOCKSIZE ) {
;			AES_SubBytes( temp, 4 ); // Substitute each byte.
;		}
;		#endif
;		// Add bytes in GF(2) one KEYLENGTH away.
;		AES_XORBytes( temp, expandedKey - KEYLENGTH, 4 );
;		// Copy result to current 4 bytes.
;		*(expandedKey++) = temp[ 0 ];
;		*(expandedKey++) = temp[ 1 ];
;		*(expandedKey++) = temp[ 2 ];
;		*(expandedKey++) = temp[ 3 ];
;		i += 4; // Next 4 bytes.
;	}	
;}

;void AES_KeyExpansion( unsigned char * expandedKey ,unsigned char *AES_key)
; unsigned char * expandedKey = R25/R24 (Hi/low)
; unsigned char * AES_key		R23/R22 (Hi/low)
; Y+1 = free
; Y+2 = i 
; Y+3 -> Y->6 = temp
; Y+7 -> Y+10 = Rcon
; Y+11/12 = expandedKey
; Y+13/14 = AES_key
	push	r28
    push	r29
    in	r28, 0x3d	; 61
    in	r29, 0x3e	; 62
    sbiw	r28, 0x10	; 16
    in	r0, 0x3f	; 63
    cli
    out	0x3e, r29	; 62
    out	0x3f, r0	; 63
    out	0x3d, r28	; 61
;	unsigned char Rcon[4] = { 0x01, 0x00, 0x00, 0x00 }; // Round constant.
    ldi	r26, 0x01	; 1
    std	Y+7, r26	; Rcon[0] 0x07
    std	Y+8, r1		; Rcon[1] 0x08
    std	Y+9, r1		; Rcon[2] 0x09
    std	Y+10, r1	; Rcon[3] 0x0a
;	i = KEYLENGTH;
    ldi		r18, AES_KEY_LENGTH	; 0x20	; 32
	movw	r30,r22	; Z = AES_key
	movw	r26,r24	; x = * expandedKey
AES_KeyExpansion1:
;	*expandedKey++ = *AES_key++;	
	ld	r19,Z+
	st	x+,r19
;;	} while( --i );
	subi	r18,1
	brne	AES_KeyExpansion1
;	expandedKey -= 4;
	sbiw	r26, 0x04	; 4
;	temp[0] = *(expandedKey++);
	ld	r24,x+
    std	Y+3, r24
;	temp[1] = *(expandedKey++);
	ld	r24,x+
	std	Y+4, r24
;	temp[2] = *(expandedKey++);
	ld	r24,x+
	std	Y+5, r24
;	temp[3] = *(expandedKey++);
	ld	r24,x+
	std	Y+6, r24
    std	Y+12, r27
    std	Y+11, r26
;	i = KEYLENGTH;
    ldi	r24, AES_KEY_LENGTH  
    std	Y+2, r24	; 0x02
    rjmp	AES_KeyExpansion2 
AES_KeyExpansion8:   
;		if( (i % AES_KEY_LENGTH ) == 0 ) { // AES_KEY_LENGTH = 16 or 24 or 32
#if AES_KEY_LENGTH == 24
AES_KeyExpansion8B:
	subi	r24,AES_KEY_LENGTH
	breq	AES_KeyExpansion8C
	brcc	AES_KeyExpansion8B
	rjmp 	AES_KeyExpansion3
AES_KeyExpansion8C:
#else
    andi	r24, AES_KEY_LENGTH-1	; 31
    brne	AES_KeyExpansion3
#endif
AES_KeyExpansion8C:
;			t = temp[0];
    ldd	r25, Y+3	; 0x03
;			temp[0] = temp[1];
    ldd		r24, Y+4	; 0x04
    std		Y+3, r24	; 0x03
;			temp[1] = temp[2];
    ldd		r24, Y+5	; 0x05
    std		Y+4, r24	; 0x04
;			temp[2] = temp[3];
    ldd		r24, Y+6	; 0x06
    std		Y+5, r24	; 0x05
;			temp[3] = t;
    std		Y+6, r25	; 0x06
;			AES_SubBytes( temp, 4 ); // Substitute each byte.
    movw	r24, r28
    adiw	r24, 0x03	; 3
    ldi		r22, 0x04	; 4

#ifdef AES_SMALL_FLASH 
	call	AES_SF_SubBytes
#endif

#ifdef AES_SMALL_RAM 
	call	AES_SR_SubBytes
#endif
;			AES_XORBytes( temp, Rcon, 4 ); // Add constant in GF(2).// R23/R22 unchanged
    movw	r24, r28
    adiw	r24, 0x07	; Y+7 = Rcon
	movw	r22, r24
    movw	r24, r28
	adiw	r24, 3
    ldi		r20, 0x04	; 4   
    call	AES_XORBytes  ;// R23/R22 unchanged

;			*Rcon = (*Rcon << 1) ^ (*Rcon & 0x80 ? BPOLY : 0);
    ldd		r24, Y+7
	lsl		r24
	brcc	AES_KeyExpansion4
	ldi		r25,0x1b	; BPOLY
	eor		r24,r25
AES_KeyExpansion4:
	std		Y+7, r24

#if AES_KEY_LENGTH > 24
    rjmp	AES_KeyExpansion6
AES_KeyExpansion3:
; if( (i % KEYLENGTH) == BLOCKSIZE )
    ldd		r24, Y+2	; 0x02
    andi	r24, AES_KEY_LENGTH-1	; 31
    cpi		r24, 0x10	; 16
    brne	AES_KeyExpansion6
	;			AES_SubBytes( temp, 4 ); // Substitute each byte.
    movw	r24, r28
    adiw	r24, 0x03	; 3
    ldi		r22, 0x04	; 4
#ifdef AES_SMALL_FLASH 
	call	AES_SF_SubBytes
#endif
#ifdef AES_SMALL_RAM 
	call	AES_SR_SubBytes
#endif
#else
AES_KeyExpansion3:
#endif 
AES_KeyExpansion6:

;		AES_XORBytes( temp, expandedKey - KEYLENGTH, 4 ); // R23/R22 unchanged
    ldd	r24, Y+11	; 0x0b
    ldd	r25, Y+12	; 0x0c
;	movw	r18, r24
    sbiw	r24, AES_KEY_LENGTH  ; 0x20	; 32
	movw	r22, r24
    movw	r24, r28		; get temp form the stack Y+3
	adiw	r24, 3
    ldi		r20, 0x04	; 4
    call	AES_XORBytes	; // R23/R22 unchanged R20 R23/22 R25/24 R27/26 R31/30 used
    ldd	r26, Y+11					; x=expandedKey
    ldd	r27, Y+12	

;		*(expandedKey++) = temp[ 0 ];
    ldd	r24, Y+3	; 0x03
	st	x+,r24
;		*(expandedKey++) = temp[ 1 ];
	ldd	r24, Y+4
	st	x+,r24
;		*(expandedKey++) = temp[ 2 ];
    ldd	r24, Y+5
	st	x+,r24
;		*(expandedKey++) = temp[ 3 ];
    ldd	r24, Y+6
	st	x+,r24
    std	Y+12, r27	
    std	Y+11, r26	; 0x0b
;		i += 4; // Next 4 bytes.
    ldd	r24, Y+2	; 0x02
    subi	r24, -4 ; 0xFC	; 252
    std	Y+2, r24	; 0x02
AES_KeyExpansion2:
;	while( i < BLOCKSIZE*(ROUNDS+1) ) 
;    ldd	r24, Y+2	; 0x02
    cpi	r24, AES_EXPANDED_KEY_SIZE ; 0xF0	; 240
;	brcs	AES_KeyExpansion8
    brcc	AES_KeyExpansion7;.+2      	; 0x4066 <AES_Key_256_SF_Expansion+0x192>
    rjmp	AES_KeyExpansion8;.-228    	; 0x3f82 <AES_Key_256_SF_Expansion+0xae>
AES_KeyExpansion7:

	adiw	r28, 0x10	; 16
	in	r0, 0x3f	; 63
	cli
	out	0x3e, r29	; 62
	out	0x3f, r0	; 63
	out	0x3d, r28	; 61
	pop	r29
	pop	r28
	ret



#ifdef AES_SMALL_FLASH 
#if AES_KEY_SIZE == 128
AES_128_SF_Init:
#elif AES_KEY_SIZE == 192
AES_192_SF_Init:
#elif AES_KEY_SIZE == 256
AES_256_SF_Init:
#endif
#endif 

#ifdef AES_SMALL_RAM 
#if AES_KEY_SIZE == 128
AES_128_SR_Init:
#elif AES_KEY_SIZE == 192
AES_192_SR_Init:
#elif AES_KEY_SIZE == 256
AES_256_SR_Init:
#endif
#endif
;void AES_SF_Init( unsigned char * tempbuf,unsigned char *tempbuf1,unsigned char *tempbuf2,unsigned char *AES_Key  )
;{
;       unsigned char i = 0;
;       unsigned char t = 1;
;        do {
;		// Use 0x03 as root for exponentiation and logarithms.
;       	tempbuf1[i] = t; // powTbl
;      		tempbuf2[t] = i; // logTbl
;      		i++;
;		// Muliply t by 3 in GF(2^8).
;      		t ^= (t << 1) ^ (t & 0x80 ? BPOLY : 0);
;      	} while( t != 1 ); // Cyclic properties ensure that i < 255.       	
;      	tempbuf1[255] = tempbuf1[0]; // powTbl 255 = '-0', 254 = -1, etc.
;	AES_sBox = tempbuf;
;	AES_CalcSBox( AES_sBox ,tempbuf1,tempbuf2);
;
;	AES_expandedKey = tempbuf1;
;	AES_KeyExpansion( AES_expandedKey ,AES_Key);
;
;	AES_sBoxInv = tempbuf2; // Must be block2.
;	AES_CalcSBoxInv( AES_sBox, AES_sBoxInv );
;}
;void AES_SR_Init( unsigned char * tempbuf,unsigned char *AES_Key  );	
;void AES_SF_Init( unsigned char * tempbuf,unsigned char *tempbuf1,unsigned char *tempbuf2,unsigned char *AES_Key  )
; SR unsigned char * tempbuf  = R25/R24 (Hi/low)
; SR unsigned char * AES_key  = R23/R22 (Hi/low)
; SF unsigned char * tempbuf  = R25/R24 (Hi/low)
; SF unsigned char * tempbuf1 = R23/R22 (Hi/low)
; SF unsigned char * tempbuf2 = R21/R20 (Hi/low)
; SF unsigned char * AES_key  = R19/R18 (Hi/low)

    push	r28
    push	r29
    in	r28, 0x3d	; 61
    in	r29, 0x3e	; 62
    sbiw	r28, 0x0A	; 12
    in	r0, 0x3f	; 63
    cli
    out	0x3e, r29	; 62
    out	0x3f, r0	; 63
    out	0x3d, r28	; 61
; Y+1 = *AES_Key
; Y+2 = *AES_Key
    std	Y+4, r25	; 0x04 unsigned char *tempbuf
    std	Y+3, r24	; 0x03

#ifdef AES_SMALL_RAM
	std	Y+2, r23	; 0x0a unsigned char *AES_Key
    std	Y+1, r22	; 0x09
#endif

#ifdef AES_SMALL_FLASH 
    std	Y+6, r23	; 0x06 unsigned char *tempbuf1
    std	Y+5, r22	; 0x05
    std	Y+8, r21	; 0x08 unsigned char *tempbuf2
    std	Y+7, r20	; 0x07
    std	Y+2, r19	; 0x0a unsigned char *AES_Key
    std	Y+1, r18	; 0x09

	eor r18,r18		; i
	ldi	r19,1		; t
;    ldd	r22, Y+5	; 0x05 *tempbuf1 =R20
;    ldd	r23, Y+6	; 0x06
;    ldd	r20, Y+7	; 0x07 *tempbuf2
;    ldd	r21, Y+8	; 0x08
AES_Init1:
;       	tempbuf1[i] = t; // powTbl
    mov	r30, R18 ; 
    eor	r31, r31
    add	r30, r22
    adc	r31, r23
    st	Z, r19
;      		tempbuf2[t] = i; // logTbl
    mov	r30, r19 ; 
    eor	r31, r31
    add	r30, r20
    adc	r31, r21
    st	Z, r18
;	i++
	inc	r18
;      		t ^= (t << 1) ^ (t & 0x80 ? BPOLY : 0);
	mov		r24, r19
	lsl		r24
	brcc	AES_Init2B
	ldi		r25,0x1b	; BPOLY
	eor		r24,r25
AES_Init2B:
	eor		r19,r24
; while( t != 1 ); // Cyclic properties ensure that i < 255.       	
    cpi		r19, 0x01	; 1
    brne	AES_Init1; .-88     	; 0x3870 <AES_128_SF_Init+0x2a>
;      	tempbuf1[255] = tempbuf1[0]; // powTbl 255 = '-0', 254 = -1, etc.
	movw	r30,r22
    ld		r24, Z
    subi	r30, 0x01
    sbci	r31, 0xFF
	st		Z, r24
;	AES_sBox = tempbuf;
    ldd	r24, Y+3
    ldd	r25, Y+4
    sts	AES_sBox+1,r25
    sts	AES_sBox  ,r24
;	AES_CalcSBox( AES_sBox ,tempbuf1,tempbuf2);
    call	AES_CalcSBox
;	AES_expandedKey = tempbuf1
    ldd	r24, Y+5
    ldd	r25, Y+6
#endif
#ifdef AES_SMALL_RAM
;	AES_expandedKey = tempbuf
    ldd	r24, Y+3
    ldd	r25, Y+4
#endif
    sts	AES_expandedKey+1, r25
    sts	AES_expandedKey  , r24
;	AES_KeyExpansion( AES_expandedKey ,AES_Key);
    ldd	r22, Y+1
    ldd	r23, Y+2
	call AES_KeyExpansion
#ifdef AES_SMALL_FLASH
;	AES_sBoxInv = tempbuf2; // Must be block2.
    ldd	r22, Y+7
    ldd	r23, Y+8
    sts		AES_sBoxInv+1, r23
    sts		AES_sBoxInv  , r22
;	AES_CalcSBoxInv( AES_sBox, AES_sBoxInv );
    lds		r24, AES_sBox
    lds		r25, AES_sBox+1
    call	AES_CalcSBoxInv
#endif // AES_SMALL_FLASH 
    adiw	r28, 0x0A
    in		r0, 0x3f
    cli
    out		0x3e, r29
    out		0x3f, r0
    out		0x3d, r28
    pop		r29
    pop		r28
    ret
