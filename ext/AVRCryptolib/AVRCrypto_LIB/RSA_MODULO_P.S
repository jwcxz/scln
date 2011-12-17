// This is a RSA implementation for the Mega or AVR4 core that is a at90s8515 
// By Emile van der Laan.
// www.emsign.nl

#include <avr/io.h>


	.macro  LPM_R15_ZP
#if __AVR_ENHANCED__
	lpm	r15, Z+
#else
	lpm
	adiw	r30,1
#endif
	.endm

	.macro  LPM_R15_MZ
	sbiw	r30,1
	lpm		r15, Z
	
	.endm
 	  
#define __zero_reg__ R1

	.data			; switches to the .data section (initialized RAM variables)

	.text			; switches to the .text section (code and ROM constants)
	.global rsa_modulo_P	; (unsigned char   *a,unsigned char   *b,unsigned char   *c,unsigned char al,unsigned char bl,unsigned char cl);

; C calling  void rsa_modulo(unsigned int keysize,unsigned char   *a,unsigned char PROGMEM *b,unsigned char   *c)
;	al is the size in R25:R24
;	*a is in R23:R22
; 	*b is in R21:R20
;	*c is in R19:R18
;      c[keysize]= a[2 * keysize ] % b[Keysize]
rsa_modulo_P:	
	push r28
	push r29
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r18
	push r19
	movw R8,r22
	ldi  r16,0x09
	mov  r7,r16
	add  R22, r24
	adc  R23, r25 	
	movw R28, R22	; R29:R28 points to the middle of *a Y
	ld	 R6,Y+
	movw R12,R24
	movw R16,R24
	lsl  R16
	rol  R17
	lsl  R16
	rol  R17
	lsl  R16
	rol  R17
	subi R16,1
	sbc  R17,__zero_reg__
rsa_modulo1:
	rcall rsa_modulosub		
;	rol_a
	dec  r7
	brne rol_start
	ldi  r30,0x08
	mov  r7,r30
	ld	 R6,Y+
rol_start:
	movw R24,r12
	lsr  R25
	ror  R24
	lsr  R25
	ror  R24
	movw R30,r22
	lsl  R6
	rol  R14
rol_a:
	ror r14
	ld  r15,-z
	rol r15
	st  z,r15
	ld  r15,-z
	rol r15
	st  z,r15
	ld  r15,-z
	rol r15
	st  z,r15
	ld  r15,-z
	rol r15
	st  z,r15

	rol r14		// save carry
	sbiw r24,1
	brne rol_a
	ror R14
	brcc noCarrySoNoSub 
	rcall sub_it
noCarrySoNoSub:
	subi R16,1
	sbc  R17,__zero_reg__
	brcc rsa_modulo1
	rcall rsa_modulosub	
	movw r20,r12
	movw r24,R18	
	movw R22,R8 	;z=a
	pop r19
	pop r18
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r29
	pop r28
;	memcpy R25:R24 des R23:R22 sorce R21:R20 len
	jmp memcpy

rsa_modulosub:
;	cmp_a_b
	movw r24,r12 
	movw R30,r20	;Z=b
	movw R26,R8 	;X=a
cmp_a:
//	ld r15,z+
	LPM_R15_ZP
	ld r14,x+
	cp r14,r15
	brlo sub_not
	brne sub_it 
	sbiw r24,1
	brne cmp_a	
sub_it:
;	sub_a
	movw r24,r12
	movw R30,r20	;Z=b
	movw R26,R22 	;X=a midle
	add  R30,R24
	adc  R31,R25
	clr r14 
sub_a: 
;	ld r15,-z
	LPM_R15_MZ
	ror r14
	ld r14,-x
	sbc r14,r15
	st x,r14
	rol r14
	sbiw r24,1
	brne sub_a
sub_not:
	ret
