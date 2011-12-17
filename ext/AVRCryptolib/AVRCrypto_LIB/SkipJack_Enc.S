; By Emile van der Laan
; www.emsign.nl
;
#include <avr/io.h>

#define __zero_reg__ R1

	.text			; switches to the .text section (code )
	.global	skipjack_g
	.global skipjack_a
	.global skipjack_b
	.global SkipJack_Enc
	.extern skipjack_ftable

/*****************************************************************************/
;unsigned int skipjack_g(unsigned int g, unsigned char k, unsigned char *key){
; g   = R25/R24 (Hi/low)
; k   = R22
; Key = R21/R20 (Hi/Lo)

;	#define G1 (((unsigned char*)&g)[0])
;	#define G2 (((unsigned char*)&g)[1])
;	eor __zero_reg__,__zero_reg__
skipjack_g:	
	add 	r22,r22		; R22=K*4
	add 	r22,r22 
skipjack_g1:
	cpi 	R22,0x0a
	brlo	skipjack_g2
	subi	R22,0x0a
	rjmp 	skipjack_g1
skipjack_g2:
;	G1 ^= pgm_read_byte_near(&(skipjack_ftable[G2 ^ key[(4*k+0)%10]]));
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+0)%10]
	eor 	r30,r25			; ^ G2
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G2 ^ key[(4*k+0)%10]]
	eor		r24,r30			; ^ G1

;	G2 ^= pgm_read_byte_near(&(skipjack_ftable[G1 ^ key[(4*k+1)%10]]));
	inc 	r22				; get K * 4
	cpi 	R22,0x0a
	brlo	skipjack_g5
	subi	R22,0x0a
skipjack_g5:
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+1)%10]
	eor 	r30,r24			; ^ G1
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G1 ^ key[(4*k+1)%10]]
	eor		r25,r30			; ^ G2

;	G1 ^= pgm_read_byte_near(&(skipjack_ftable[G2 ^ key[(4*k+2)%10]]));
	inc 	r22				; get K * 4
	cpi 	R22,0x0a
	brlo	skipjack_g6
	subi	R22,0x0a
skipjack_g6:
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+2)%10]
	eor 	r30,r25			; ^ G2
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G1 ^ key[(4*k+2)%10]]
	eor		r24,r30			; ^ G1

;	G2 ^= pgm_read_byte_near(&(skipjack_ftable[G1 ^ key[(4*k+3)%10]]));
	inc 	r22				; get K * 4
	cpi 	R22,0x0a
	brlo	skipjack_g7
	subi	R22,0x0a
skipjack_g7:
	movw 	r30,r20			; Get Key in Z
	add		r30,r22			; add k*4
	adc		r31,__zero_reg__			;
	ld		r30,Z			; key[(4*k+3)%10]
	eor 	r30,r24			; ^ G1
	eor		r31,r31			; 
	subi	r30,lo8(-(skipjack_ftable))
    sbci	r31,hi8(-(skipjack_ftable))
	lpm		r30,Z			; r30 = skipjack_ftable[G1 ^ key[(4*k+3)%10]]
	eor		r25,r30			; ^ G2
	ret

/*****************************************************************************/
/*****************************************************************************/
;void skipjack_a(unsigned int* w, unsigned char k, unsigned char* key){
; w   = R25/R24 (Hi/low)
; k   = R22
; Key = R21/R20 (Hi/Lo)
; t   = r19/R18
; tmp = R17/r16
;	unsigned int t;
skipjack_a:
;	t = w[3];
	movw	r30,r24	; get w in Z
	ldd		r18,z+((3*2)+0)			; R19/18=w[3]
	ldd		r19,z+((3*2)+1)
;	w[3] = w[2];
	ldd		r16,z+((2*2)+0)			; R17/16=w[2]
	ldd		r17,z+((2*2)+1)
	std		z+((3*2)+0),r16			; w[3]=R17/16
	std		z+((3*2)+1),r17
;	w[2] = w[1];
	ldd		r16,z+((1*2)+0)			; R17/16=w[1]
	ldd		r17,z+((1*2)+1)
	std		z+((2*2)+0),r16			; w[2]=R17/16
	std		z+((2*2)+1),r17

;	w[1] = skipjack_g(w[0],k-1,key);
	ldd		r24,z+((0*2)+0)			; R25/24=w[0]
	ldd		r25,z+((0*2)+1)
	push	r30						; save Z or w
	push	r31
	push	r22						; save k
	dec		r22
	rcall 	skipjack_g
	pop		r22
	pop		r31
	pop		r30
	std		z+((1*2)+0),r24			; w[1]=R25/r24
	std		z+((1*2)+1),r25

;	w[0] = t ^ w[1] ^ k<<8;
	eor		r18,r24
	eor		r19,r25
	eor		r19,r22
	std		z+((0*2)+0),r18			; w[0]=R19/r18
	std		z+((0*2)+1),r19
	ret
/*****************************************************************************/
;void skipjack_b(unsigned int* w, unsigned char k, unsigned char* key){
; w   = R25/R24 (Hi/low)
; k   = R22
; Key = R21/R20 (Hi/Lo)
; t   = r19/R18
; tmp = R17/r16
;	unsigned int t;
skipjack_b:
;	t = w[0];
	movw	r30,r24	; get w in Z
	ldd		r18,z+((0*2)+0)			; R19/18=w[3]
	ldd		r19,z+((0*2)+1)
;	w[0] = w[3];
	ldd		r16,z+((3*2)+0)			; R17/16=w[2]
	ldd		r17,z+((3*2)+1)
	std		z+((0*2)+0),r16			; w[3]=R17/16
	std		z+((0*2)+1),r17
;	w[3] = w[2];
	ldd		r16,z+((2*2)+0)			; R17/16=w[2]
	ldd		r17,z+((2*2)+1)
	std		z+((3*2)+0),r16			; w[3]=R17/16
	std		z+((3*2)+1),r17
;	w[2] = t ^ k<<8 ^ w[1];
	ldd		r16,z+((1*2)+0)			; R17/16=w[1]
	ldd		r17,z+((1*2)+1)
	eor		r17,r22					; k<<8
	eor		r16,r18
	eor		r17,r19
	std		z+((2*2)+0),r16			; w[3]=R17/16
	std		z+((2*2)+1),r17

;	w[1] = skipjack_g(t,k-1,key);
	movw	r24,r18
	push	r30						; save Z or w
	push	r31
	dec		r22
	rcall	skipjack_g
	pop		r31
	pop		r30
	std		z+((1*2)+0),r24			; w[0]=R25/R24
	std		z+((1*2)+1),r25
	ret

/*****************************************************************************/
/**
 * block is 64 bits (=8 bytes) in size, key is 80 bits (=10 bytes) in size.
 * 
 */
;void SkipJack_Enc(void* block, void* key){
; block	= R25/R24 (Hi/low)
; key	= R23/R22 (Hi/low)
; 
SkipJack_Enc:
	push	r17
	push	r16
	movw	r20,r22		; copy key to R20 for skipjack_x function
	eor		r22,r22
;	for(k=0; k<32; ++k){
;		if(k & 0x08){
;			skipjack_b((unsigned int*)block, k+1, key);
;		} else {
;			skipjack_a((unsigned int*)block, k+1, key);
;		}
SkipJack_Enc1:
	push 	r22			; save the k
	push	r24			; save the key
	push	r25	
	sbrs	r22,3
	rjmp 	SkipJack_Enc2
	inc		r22
	rcall	skipjack_b
	rjmp	SkipJack_Enc3
SkipJack_Enc2:
	inc		r22
	rcall	skipjack_a
SkipJack_Enc3:
	pop		r25
	pop		r24
	pop		r22
	inc		r22
	cpi		r22,32
	brcs	SkipJack_Enc1
;	}
	pop		r16
	pop		r17
	ret
