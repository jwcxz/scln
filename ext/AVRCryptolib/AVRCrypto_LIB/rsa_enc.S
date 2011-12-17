; By Emile van der Laan
; www.emsign.nl

#include <avr/io.h>

	.global rsa_ror		; (unsigned char   al,unsigned char   *a);
	.global rsa_memtst	; (unsigned char   *a,unsigned char   al)

#define __zero_reg__ R1
	.text			; switches to the .text section (code and ROM constants)


; C calling  rsa_ror(unsigned int al, unsigned char   *a);
;	*a is in R23:R22 
;	al is the size in R25/R22	
; 	This function will ror a long
rsa_ror:
// R23/R22 	= *a
// R25/R24 	= al
	movw R30,R22
	clc
	ror r23
RSAROR1:
	rol r23
	ld R22,Z
	ROR R22
	st Z+,R22
	ror r23
	sbiw R24,1
	BRNE RSAROR1
	ret 		


; unsigned char rsa_memtst(unsigned int al,unsigned char  *a,)
;	*a is in R23:R22 
;	al is the size in R25/R24	
;	Return R25:R24

rsa_memtst:
	movw R30,R22
	add r30,r24
	adc r31,r25
memtst_L1:
	sbiw R24,1
	breq memtst_end
	ld r22,-Z
	tst R22
	breq memtst_L1
	eor R25,R25
	ldi R24,1 
memtst_end:
	ret

