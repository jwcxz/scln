; By Emile van der Laan
; www.emsign.nl

		.global AES_sBoxInv
		.global AES_CalcSBoxInv
		.data
		
AES_sBoxInv: 
		.space	2

		.text

;unsigned char * AES_sBoxInv; //!< Final location of inverse s-box.
;void AES_CalcSBoxInv( unsigned char * sBox, unsigned char * sBoxInv )
;{
;	unsigned char i = 0;
;	do
;	{
;	   sBoxInv[sBox[ i ]]=i;
;	} while( ++i != 0 );
;}
AES_CalcSBoxInv:
;void AES_CalcSBoxInv( unsigned char * sBox, unsigned char * sBoxInv )
;{
; unsigned char * sBox = R25/R24 (Hi/low)
; unsigned char * sBoxInv = R23/R22 (Hi/low)
	eor 	r18, r18
	movw	r30, r24
AES_CalcSBoxInv2:
	movw	r26, r22
	ld		r19, Z+
	add		r26, r19
	adc		r27, r1
	st		x, r18
	subi 	r18, -1
	brcs	AES_CalcSBoxInv2
	ret

