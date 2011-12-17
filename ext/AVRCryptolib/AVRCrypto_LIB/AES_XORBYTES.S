#include <avr/io.h>
; This is part of the AES
; by Emile van der Laan
; www.emsign.nl

	.text			; switches to the .text section (code and ROM constants)
	.global	AES_XORBytes

; void AES_XORBytes( unsigned char * bytes1, unsigned char * bytes2, unsigned char count )
; *bytes1   = R25/R24 (Hi/low)
; *bytes2   = R23/R22 (Hi/low)
; count     = R20         (Lo)
AES_XORBytes:
	movw 	R30,R24		; Z = bytes1
	movw	R26,R22		; X = bytes2
AES_XORBytes_2:	
;		*bytes1 ^= *bytes2; // Add in GF(2), ie. XOR.
	ld		R25,X+
	ld		R24,Z
	EOR		R24,R25
	st		Z+,R24
	subi	r20,1
	brne 	AES_XORBytes_2
	ret

