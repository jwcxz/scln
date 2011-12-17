; By Emile van der Laan
; www.emsign.nl

	.global AES_SR_InvSubBytesAndXOR
	.data
	.extern AES_Flash_InvSBox
	.text

AES_SR_InvSubBytesAndXOR:
; unsigned char * bytes R25/R24 (Hi/low)
; unsigned char * key   R23/R22 (Hi/low)
; unsigned char count   R20 (Hi/low)
	push	r28
	push	r29
	movw 	r26,r22
	movw	r28,r24
	ldi		r18,lo8(AES_Flash_InvSBox)
	ldi		r19,hi8(AES_Flash_InvSBox)
InvSubBytesAndXOR1:
	ld		r24,Y
	movw	r30,r18
	add		r30,r24
	adc		r31,r1
	lpm		r24,Z
	ld		r25,X+
	eor		r24,r25
	st		Y+,r24
	subi	r20,1
	brne	InvSubBytesAndXOR1
	pop		r29
	pop		r28
	ret


