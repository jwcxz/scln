
	.global AES_SF_InvSubBytesAndXOR
	.data
	.extern AES_sBoxInv
	.text
;void AES_SF_InvSubBytesAndXOR( unsigned char * bytes, unsigned char * key, unsigned char count )
;{
;	do {
;		*bytes = AES_sBoxInv[ *bytes ] ^ *key; // Inverse substitute every byte in state and add key.
;		bytes++;
;		key++;
;	} while( --count );
;}

AES_SF_InvSubBytesAndXOR:
; unsigned char * bytes R25/R24 (Hi/low)
; unsigned char * key   R23/R22 (Hi/low)
; unsigned char count   R20 (Hi/low)
	push	r28
	push	r29
	movw 	r26,r22
	movw	r28,r24
	lds		r18,AES_sBoxInv
	lds		r19,AES_sBoxInv+1
InvSubBytesAndXOR1:
	ld		r24,Y
	movw	r30,r18
	add		r30,r24
	adc		r31,r1
	ld		r24,Z
	ld		r25,X+
	eor		r24,r25
	st		Y+,r24
	subi	r20,1
	brne	InvSubBytesAndXOR1
	pop		r29
	pop		r28
	ret


