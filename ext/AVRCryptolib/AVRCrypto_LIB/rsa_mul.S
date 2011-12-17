// This is a RSA implementation for the Mega or at90s8515 
// By Emile van der Laan.
// www.emsign.nl

#include <avr/io.h>
 	  
#define __zero_reg__ R1

	.data			; switches to the .data section (initialized RAM variables)

	.text			; switches to the .text section (code and ROM constants)
	.global rsa_mull 	; (unsigned char   *a,unsigned char   *b,unsigned char   *c,unsigned char al,unsigned char bl,unsigned char cl);


; C calling  void mull(unsigned int Key_size, unsigned char *Y,unsigned char *X,unsigned char *Z)
;	key size in R25:R24
;	*Y is in R23:R22 buffer of Keys_size 
; 	*X is in R21:R20 buffer of Keys_size 
;	*Z is in R19:R18 buffer of Keys_size * 2
; 	
rsa_mull:
	push r0
	push r1
	push r2
	push r13
	push r14
	push r15
	push r16
	push r17
	push r28
	push r29

	movw r30,r18
	movw R28,R22	; Y
	movw R22,R24
mul_Clr_1:
	st Z+,__zero_reg__
	st Z+,__zero_reg__
	sbiw R24,1
	brne mul_Clr_1

	eor  R14,R14
	movw R24,R22	; restore the Key_size
	subi R22,1
	sbc  R23,R14 
	add  R28,R24	; Make the pointer to the End of the buffer, Z is at the and
	adc  R29,R25
	add  R20,R24	;
	adc  R21,R25

rsamulloop2:
	ld	R16,-y
	movw R26,R20 	; X
	push R31 		; Z
	push R30
	push r25		; key_len 
	push r24

	eor R2,R2
	eor R1,R1	
rsamulloop1:
	mov r15,r1
	mov r13,r2
// R2:R1:R0 = R0 * R16
	ld 	R0,-x
#if !__AVR_ENHANCED__
	rcall RSA_Mull_A16
#else
	mul R0,R16
#endif
	ld  R17,-z
	add R0,r17
	adc R1,R14
	eor R2,R2
	adc R2,R14
	add R0,R15
	adc R1,R13
	adc R2,R14
	st  z,R0
	sbiw R24,1
	brne rsamulloop1

	tst r1
	breq rsamul_noaddr1
	ld  R17,-z
	add R1,r17
	adc R2,R14
	st  z,R1
	rjmp rsamul_noaddr2
rsamul_noaddr1:
	sbiw R30,1
rsamul_noaddr2:
	tst r2
	breq rsamul_noaddr3
	ld  R17,-z
	add R2,r17
	st  z,R2
rsamul_noaddr3:
	pop R24
	pop R25
	pop R30
	pop R31

	sbiw R30,1		; dec the z pointer
	subi R22,1
	sbc  R23,R14 
	brcc rsamulloop2	
  	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r2
	pop r1
	pop r0
	ret

#if !__AVR_ENHANCED__
RSA_Mull_A16:
	clr R1
	lsr R0
	brcc .MULLD0//  D0
	ADD R1,R16
.MULLD0:
	ROR R1
	ROR R0
	brcc .MULLD1//  D1
	ADD R1,R16
.MULLD1:
	ROR R1
	ROR R0
	brcc .MULLD2//  D2
	ADD R1,R16
.MULLD2:
	ROR R1
	ROR R0
	brcc .MULLD3//  D3
	ADD R1,R16
.MULLD3:
	ROR R1
	ROR R0
	brcc .MULLD4//  D4
	ADD R1,R16
.MULLD4:
	ROR R1
	ROR R0
	brcc .MULLD5//  D5
	ADD R1,R16
.MULLD5:
	ROR R1
	ROR R0
	brcc .MULLD6//  D6
	ADD R1,R16
.MULLD6:
	ROR R1
	ROR R0
	brcc .MULLD7//  D7
	ADD R1,R16
.MULLD7:
	ROR R1
	ROR R0
	ret 
#endif 


