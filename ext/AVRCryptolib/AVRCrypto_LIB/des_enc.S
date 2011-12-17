#include <avr/io.h>
// 
// Des for the AVR
// By Emile van der Laan 
// 
	.text			; switches to the .text section (code and ROM constants)
	.global	Des_Enc
	.extern T1_1
	.extern T2_1
	.extern des_Input_mem_ex
	.extern des_permutation
	.extern des_frement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Des_Enc:
;	permutation((unsigned char *)T1_1);
;	chiffrement();
;	permutation((unsigned char *)T2_1);
	push	r28
	push	r29
	ldi		r24,lo8(T1_1)
	ldi		r25,hi8(T1_1)
	rcall	des_permutation
	rcall	des_chiffrement
	ldi		r24,lo8(T2_1)
	ldi		r25,hi8(T2_1)
	rcall	des_permutation
	pop		r29
	pop		r28
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
des_chiffrement:
;void chiffrement(void)
;{
;    unsigned char n,i;
	
;	for (n = 0; n < 6*16; n+=6)
	eor		R18,R18
chiffre4:
	push	r18
;	{
	rcall	des_frement
	pop		r18 
	subi	r18, -6
	cpi		r18, 0x60
	brcs	chiffre4
;	}
;	Des_Input_mem_ex();
	rjmp	des_Input_mem_ex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
