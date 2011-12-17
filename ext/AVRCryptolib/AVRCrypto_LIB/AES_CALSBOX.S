; This is part of the AES
; by Emile van der Laan
; www.emsign.nl

		.global AES_CalcSBox
		.global AES_sBox
		.data		

;unsigned char * AES_sBox; //!< Final location of s-box.
AES_sBox: 
		.space	2

		.text
;unsigned char * AES_sBox; //!< Final location of s-box.
;void AES_CalcSBox( unsigned char *sBox ,unsigned char *AES_powTbl, unsigned char *AES_logTbl)
;{
;	unsigned char i, rot;
;	unsigned char temp;
;	unsigned char result;
;
;	// Fill all entries of sBox[].
;	i = 0;
;	do {
;		// Inverse in GF(2^8).
;		if( i > 0 ) {
;	                temp = AES_powTbl[ 255 - AES_logTbl[i] ];
;	        } else 
;			{
;                	temp = 0;
;			}
;                // Affine transformation in GF(2).
;                result = temp ^ 0x63; // Start with adding a vector in GF(2).
;                for( rot = 0; rot < 4; rot++ ) 
;				{ 	// Rotate left.
;					temp = (temp<<1) | (temp>>7);
;					// Add rotated byte in GF(2).
;					result ^= temp;
;				}
;		// Put result in table.
;                sBox[i] = result;
;	} while( ++i != 0 );
;}	
AES_CalcSBox:
;void AES_CalcSBox( unsigned char *sBox ,unsigned char *AES_powTbl, unsigned char *AES_logTbl)
;{
; unsigned char * sBox = R25/R24 (Hi/low)
; unsigned char * AES_powTbl = R23/R22 (Hi/low)
; unsigned char * AES_logTbl = R21/R20 (Hi/low)

	push	r15
	push	r16
	push	r17
	movw	r26, r20
;	unsigned char i, rot;
;	unsigned char temp;
;	unsigned char result;
;	// Fill all entries of sBox[].
;	i = 0;
	eor 	r15, r15 ; i
	adiw	r26, 1
	rjmp 	AES_CalcSBox1 
;	do {
AES_CalcSBox6:
		// Inverse in GF(2^8).
;		if( i > 0 ) {
;	                temp = AES_powTbl[ 255 - AES_logTbl[i] ];
	ld  	r21,  x+
	ldi		r20, 0xff
	sub 	r20, r21
	movw 	r30, r22
    add		r30, r20
    adc		r31, r1
	ld		r16, Z
    rjmp	AES_CalcSBox2; .+2      	; 0x3c14 <AES_CalcSBox+0x54>
;	        } else 
;			{
;                 	temp = 0;
AES_CalcSBox1:
	eor 	r16, r16
;			}
AES_CalcSBox2:
;                // Affine transformation in GF(2)
;                result = temp ^ 0x63; // Start with adding a vector in GF(2)
	mov 	r17, r16		; r17 = result
    ldi		r21, 0x63	; 99
    eor		r17, r21
;                for( rot = 0; rot < 4; rot++ ) 
	ldi 	r20,4
;				{ 	// Rotate left.
AES_CalcSBox4:
;					temp = (temp<<1) | (temp>>7);
	lsl 	r16
	adc 	r16, r1
;					// Add rotated byte in GF(2).
;					result ^= temp;
	eor 	r17, r16
	subi	r20, 1
	brne	AES_CalcSBox4
;				}			
;		// Put result in table.
;                sBox[i] = result;
	movw 	r30, r24
	add 	r30, r15
    adc		r31, r1
	st		Z, r17
;	} while( ++i != 0 );
	inc		r15
	brne	AES_CalcSBox6
	pop		r17
	pop		r16
	pop 	r15
	ret
