	.global AES_SR_SubBytes
	.extern AES_Flash_SBox
	.text

;void AES_SR_SubBytes( unsigned char * bytes, unsigned char count )
;{
;	do {
;		*bytes = pgm_read_byte_near(&AES_Flash_SBox[ *bytes ]); // Substitute every byte in state.
;		bytes++;
;	} while( --count );
;}

AES_SR_SubBytes:
;void AES_SF_SubBytes( unsigned char * bytes, unsigned char count )
; unsigned char * bytes R25/R24 (Hi/low)
; unsigned char count   R22 (Hi/low)
	movw	r26,r24
	ldi		r20,lo8(AES_Flash_SBox)
	ldi		r21,hi8(AES_Flash_SBox)
AES_SR_SubBytes1:
;		*bytes = pgm_read_byte_near(&AES_Flash_SBox[ *bytes ]); // Substitute every byte in state.
	ld		r24,x
	movw	r30,r20
	add		r30,r24
	adc		r31,r1
	lpm		r24,z
	st		x+,r24
	subi	r22,1
	brne	AES_SR_SubBytes1				
	ret
