#include <avr/io.h>
// 
// Des for the AVR
// By Emile van der Laan 
// 

	.text			; switches to the .text section (code and ROM constants)
	.global	Des_Dec
	.extern T1_1
	.extern T2_1
	.extern T1_1
	.extern T2_1
	.extern des_Input_mem_ex
	.extern des_permutation
	.extern des_frement

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Des_Dec:
;	permutation((unsigned char *)T1_1);
;	dechiffrement();
;	permutation((unsigned char *)T2_1);
	push	r28
	push	r29
	ldi		r24,lo8(T1_1)
	ldi		r25,hi8(T1_1)
	rcall	des_permutation
	rcall	des_dechiffrement
	ldi		r24,lo8(T2_1)
	ldi		r25,hi8(T2_1)
	rcall	des_permutation
	pop		r29
	pop		r28
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;void dechiffrement(void)
;{
des_dechiffrement:
;    unsigned char n,i;
;	for (n = 6*16; n!=0; )
	ldi		r18, 0x60-6
dechiff2:
	push	r18
;	{
;		n-=6;
	rcall	des_frement
	pop		R18
	subi	r18, 0x06
	brcc	dechiff2
;	}
dechiff1:
;	Des_Input_mem_ex();
	rjmp	des_Input_mem_ex
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
