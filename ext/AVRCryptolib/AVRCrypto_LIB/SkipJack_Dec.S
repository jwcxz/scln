; By Emile van der Laan
; www.emsign.nl
;
#include <avr/io.h>

#define __zero_reg__ R1

	.text			; switches to the .text section (code )
	.global	skipjack_g_inv
	.global skipjack_a_inv
	.global skipjack_b_inv
	.global SkipJack_Dec
	.extern skipjack_ftable
;unsigned int skipjack_g_inv(unsigned int g, unsigned char k, unsigned char *key){
skipjack_g_inv:
; g   = R25/R24 (Hi/low)
; k   = R22
; Key = R21/R20 (Hi/Lo)

;	#define G1 (((unsigned char*)&g)[0])
;	#define G2 (((unsigned char*)&g)[1])
;	eor __zero_reg__,__zero_reg__
	add 	r22,r22		; R22=K*4
	add 	r22,r22 
	subi 	r22,-(3)	; add 3
skipjack_g_inv1:
	cpi 	R22,0x0a
	brlo	skipjack_g_inv2
	subi	R22,0x0a
	rjmp 	skipjack_g_inv1
skipjack_g_inv2:
;	G2 ^= pgm_read_byte_near(&(skipjack_ftable[G1 ^ key[(4*k+3)%10]]));
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+0)%10]
	eor 	r30,r24			; ^ G2
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G2 ^ key[(4*k+0)%10]]
	eor		r25,r30			; ^ G1
;	G1 ^= pgm_read_byte_near(&(skipjack_ftable[G2 ^ key[(4*k+2)%10]]));
	tst		r22
	brne	skipjack_g_inv5
	subi	r22,-(10)
skipjack_g_inv5:
	dec 	r22				
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+1)%10]
	eor 	r30,r25			; ^ G1
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G1 ^ key[(4*k+1)%10]]
	eor		r24,r30			; ^ G2
;	G2 ^= pgm_read_byte_near(&(skipjack_ftable[G1 ^ key[(4*k+1)%10]]));
	tst		r22
	brne	skipjack_g_inv6
	subi	r22,-(10)
skipjack_g_inv6:
	dec 	r22				
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+2)%10]
	eor 	r30,r24			; ^ G2
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G1 ^ key[(4*k+2)%10]]
	eor		r25,r30			; ^ G1
;	G1 ^= pgm_read_byte_near(&(skipjack_ftable[G2 ^ key[(4*k+0)%10]]));
	tst		r22
	brne	skipjack_g_inv7
	subi	r22,-(10)
skipjack_g_inv7:
	dec 	r22				
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+3)%10]
	eor 	r30,r25			; ^ G1
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G1 ^ key[(4*k+3)%10]]
	eor		r24,r30			; ^ G2
	ret

/*****************************************************************************/
;void skipjack_a_inv(unsigned int* w, unsigned char k, unsigned char* key){
; w   = R25/R24 (Hi/low)
; k   = R22
; Key = R21/R20 (Hi/Lo)
; t   = r19/R18
; tmp = R17/r16
;	unsigned int t;

skipjack_a_inv:
;	t = w[0] ^ w[1];
	movw	r30,r24	; get w in Z
	ldd		r18,z+((0*2)+0)			; R19/18=w[0]
	ldd		r19,z+((0*2)+1)
	ldd		r24,z+((1*2)+0)			; R25/24=w[1]
	ldd		r25,z+((1*2)+1)
	eor		r18,r24
	eor		r19,r25
;	t = t ^ k<<8;
	eor		r19,r22
;	w[0] = skipjack_g_inv(w[1],k-1,key);
	push	r30						; save Z or w
	push	r31
	dec		r22
	rcall	skipjack_g_inv
	pop		r31
	pop		r30
	std		z+((0*2)+0),r24			; w[0]=R25/R24
	std		z+((0*2)+1),r25
;	w[1] = w[2];
	ldd		r16,z+((2*2)+0)			; R17/16=w[1]
	ldd		r17,z+((2*2)+1)
	std		z+((1*2)+0),r16			; w[2]=R17/16
	std		z+((1*2)+1),r17
;	w[2] = w[3];
	ldd		r16,z+((3*2)+0)			; R17/16=w[1]
	ldd		r17,z+((3*2)+1)
	std		z+((2*2)+0),r16			; w[2]=R17/16
	std		z+((2*2)+1),r17

;	w[3] = t ;
	std		z+((3*2)+0),r18			; w[2]=R17/16
	std		z+((3*2)+1),r19
	ret
/*****************************************************************************/
;void skipjack_b_inv(unsigned int* w, unsigned char k, unsigned char* key){
skipjack_b_inv:
; w   = R25/R24 (Hi/low)
; k   = R22
; Key = R21/R20 (Hi/Lo)
; t   = r19/R18
; tmp = R17/r16
;	unsigned int t;
;	t = w[2];
	movw	r30,r24	; get w in Z
	ldd		r18,z+((2*2)+0)			; R19/18=w[3]
	ldd		r19,z+((2*2)+1)
;	w[2] = w[3];
	ldd		r16,z+((3*2)+0)			; R17/16=w[2]
	ldd		r17,z+((3*2)+1)
	std		z+((2*2)+0),r16			; w[3]=R17/16
	std		z+((2*2)+1),r17
;	w[3] = w[0];
	ldd		r16,z+((0*2)+0)			; R17/16=w[2]
	ldd		r17,z+((0*2)+1)
	std		z+((3*2)+0),r16			; w[3]=R17/16
	std		z+((3*2)+1),r17
;	t = t ^ k<<8;
	eor		r19,r22
;	w[0] = skipjack_g_inv(w[1],k-1,key);
	ldd		r24,z+((1*2)+0)			; R17/16=w[2]
	ldd		r25,z+((1*2)+1)
	dec 	r22
	push	r30						; save Z or w
	push	r31
	rcall	skipjack_g_inv
	pop		r31
	pop		r30
	std		z+((0*2)+0),r24			; w[0]=R25/r24
	std		z+((0*2)+1),r25
;	w[1] = w[0] ^ t ;
	eor		r24,r18
	eor		r25,r19
	std		z+((1*2)+0),r24			; w[0]=R25/r24
	std		z+((1*2)+1),r25
	ret

/*****************************************************************************/
/**
 * block is 64 bits (=8 bytes) in size, key is 80 bits (=10 bytes) in size.
 * 
 */
;void SkipJack_Dec(void* block, void* key){
SkipJack_Dec:
; block	= R25/R24 (Hi/low)
; key	= R23/R22 (Hi/low)
;	signed char k;;
;	for(k=31; k>=0; --k){
;		if(k & 0x08){
;			skipjack_b_inv((unsigned int*)block, k+1, key);
;		} else {
;			skipjack_a_inv((unsigned int*)block, k+1, key);
;		}
;	}
	push 	r16
	push	r17
	movw	r20,r22		; copy key to R20 for skipjack_x function
	ldi		r22,31
SkipJack_Dec1:
	push 	r22			; save the k
	push	r24			; save the key
	push	r25	
	sbrs	r22,3
	rjmp 	SkipJack_Dec2
	inc		r22
	rcall	skipjack_b_inv
	rjmp	SkipJack_Dec3
SkipJack_Dec2:
	inc		r22
	rcall	skipjack_a_inv
SkipJack_Dec3:
	pop		r25
	pop		r24
	pop		r22
	subi	r22,1
	brcc	SkipJack_Dec1
;	}
	pop 	r17
	pop		r16
	ret

