	.global AES_SF_SubBytes
	.extern AES_sBox
	.text
;void AES_SF_SubBytes( unsigned char * bytes, unsigned char count )
;{
;	do {
;		*bytes = AES_sBox[ *bytes ]; // Substitute every byte in state.
;		bytes++;
;	} while( --count );
;}


AES_SF_SubBytes:
;void AES_SF_SubBytes( unsigned char * bytes, unsigned char count )
; unsigned char * bytes R25/R24 (Hi/low)
; unsigned char count   R22 (Hi/low)
	movw	r26,r24
	lds		r20,AES_sBox
	lds		r21,AES_sBox+1
AES_SF_SubBytes1:
;		*bytes = AES_sBox[ *bytes ]; // Substitute every byte in state.
	ld		r24,x
	movw	r30,r20
	add		r30,r24
	adc		r31,r1
	ld		r24,z
	st		x+,r24
	subi	r22,1
	brne	AES_SF_SubBytes1				
	ret


