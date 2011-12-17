#include <avr/io.h>

#define md5_Info_buf 	md5_Info+0
#define md5_Info_bits 	md5_Info+(4*4)
#define md5_Info_in 	md5_Info+(4*4)+(2*4)
#define md5_Info_inlong md5_Info_in


	.text			; switches to the .text section (code )
	.global	MD5Update

	.data			; switches to the .data section (Ram )
	.extern md5_Info

	.text			; switches to the .text section (Code )	
;/* Update context to reflect the concatenation of another buffer full
; * of bytes.
; */
;void MD5Update(unsigned char *buf, unsigned int len)
;*buf = R24:R25
; len = R23:R22
;{
MD5Update:
	push	r16
	push	r17
	push	r28
	push	r29
	in	r28, 0x3d	
	in	r29, 0x3e	
	sbiw	r28, 10	
	in	r0, 0x3f	
	cli
	out	0x3e, r29	
	out	0x3f, r0	
	out	0x3d, r28	

	std	Y+10,r23
	std	Y+9, r22
	std	Y+8, r25
	std	Y+7, r24
;    unsigned long t;
;    /* Update bitcount */
;    t = md5_Info.bits[0];
	lds	r18, md5_Info_bits+0
	lds	r19, md5_Info_bits+1
	lds	r20, md5_Info_bits+2
	lds	r21, md5_Info_bits+3


 ;   if ((md5_Info.bits[0] = t + ((unsigned long) len << 3)) < t)
	ldd	r24, Y+9	;len << 3
	ldd	r25, Y+10	
	eor	r26, r26
	eor	r27, r27

	add	r24, r24
	adc	r25, r25
	adc	r26, r26

	add	r24, r24
	adc	r25, r25
	adc	r26, r26

	add	r24, r24
	adc	r25, r25
	adc	r26, r26


	add	r24, r18 	; t + ((unsigned long) len << 3)) 
	adc	r25, r19
	adc	r26, r20
	adc	r27, r21
; md5_Info.bits[0] = t + ((unsigned long) len << 3))
	sts	md5_Info_bits+0,r24
	sts	md5_Info_bits+1,r25
	sts	md5_Info_bits+2,r26
	sts	md5_Info_bits+3,r27

	cp	r24, r18
	cpc	r25, r19
	cpc	r26, r20
	cpc	r27, r21
	movw	r24, r18
	brcc	MD5UpdateA

;		md5_Info.bits[1]++;		/* Carry from low to high */
	lds	r18, md5_Info_bits+4
	lds	r19, md5_Info_bits+5
	lds	r20, md5_Info_bits+6
	lds	r21, md5_Info_bits+7
	add	r18, 0x01	; 1
	adc r19, r1
	adc	r20, r1
	adc	r21, r1
	sts	md5_Info_bits+4,r18
	sts	md5_Info_bits+5,r19
	sts	md5_Info_bits+6,r20
	sts	md5_Info_bits+7,r21

MD5UpdateA:
;//    md5_Info.bits[1] += len >> 29;
;    t = (t >> 3) & 0x3f;	/* Bytes already in shsInfo->data */
	set
	bld	r1, 2
MD5UpdateL:
	lsr	r25
	ror	r24
	ror r1
	brne	MD5UpdateL
	andi	r24, 0x3F
	std	Y+3, r24
	std	Y+4, r1
	std	Y+5, r1
	std	Y+6, r1

    /* Handle any leading odd-sized chunks */
;    if (t) {
	subi	r24, 0x00
	brne	MD5UpdateB
	rjmp	MD5UpdateC
MD5UpdateB:
;	unsigned char *p = (unsigned char *) md5_Info.in + t;
	ldd	r24, Y+3
	ldd	r25, Y+4
	subi	r24, lo8(-(md5_Info_in))
	sbci	r25, hi8(-(md5_Info_in))
	std	Y+2, r25
	std	Y+1, r24
;	t = 64 - t;
	ldi	r18, 0x40
	ldi	r19, 0x00
	ldi	r20, 0x00
	ldi	r21, 0x00
	ldd	r24, Y+3
	ldd	r25, Y+4
	ldd	r26, Y+5
	ldd	r27, Y+6

	sub	r18, r24
	sbc	r19, r25
	sbc	r20, r26
	sbc	r21, r27

	std	Y+3, r18
	std	Y+4, r19
	std	Y+5, r20
	std	Y+6, r21

;	if (len < t) {
	ldd	r24, Y+9
	ldd	r25, Y+10
	eor	r26, r26
	eor	r27, r27
	cp	r24, r18
	cpc	r25, r19
	cpc	r26, r20
	cpc	r27, r21
	movw r20,r24	
	brcc	MD5UpdateE 
;	    memcpy(p, buf, len);
	ldd	r24, Y+1
	ldd	r25, Y+2
	ldd	r22, Y+7
	ldd	r23, Y+8
	call	memcpy
;	    return;
	rjmp	MD5UpdateF
;	}
MD5UpdateE:
;	memcpy(p, buf, t);
;          R24:R25,R22:R23,R20:21
	ldd	r24, Y+1
	ldd	r25, Y+2
	ldd	r22, Y+7
	ldd	r23, Y+8
	ldd	r20, Y+3
	ldd	r21, Y+4

	call	memcpy; 0x4212	; 0x4212 <memcpy>	
;	MD5Transform();
	call	MD5Transform ;0x3bc6	; 0x3bc6 <MD5Transform>
;	buf += t;
	ldd	r18, Y+3
	ldd	r19, Y+4
	ldd	r24, Y+7
	ldd	r25, Y+8
	add	r24, r18
	adc	r25, r19
	std	Y+8, r25
	std	Y+7, r24
;	len -= t;
	ldd	r24, Y+9
	ldd	r25, Y+10
	sub	r24, r18
	sbc	r25, r19
	std	Y+10, r25
	std	Y+9, r24
;    }
    /* Process data in 64-byte chunks */

;    while (len >= 64) {
	rjmp	MD5UpdateG 
MD5UpdateD:
;	memcpy(md5_Info.in, buf, 64);
;          R25:R24,R23:R22,R21:20
	ldi	r24, lo8(md5_Info_in)
	ldi	r25, hi8(md5_Info_in)
	ldd	r22, Y+7
	ldd	r23, Y+8
	ldi	r20, 0x40
	ldi r21, 0x00
	call	memcpy
;	MD5Transform();
	call	MD5Transform
;	buf += 64;
	ldd	r24, Y+7
	ldd	r25, Y+8
	subi	r24, lo8(-(64))
	sbci	r25, hi8(-(64))
	std	Y+8, r25
	std	Y+7, r24
;	len -= 64;
	ldd	r24, Y+9
	ldd	r25, Y+10
	subi	r24, 0x40
	sbci	r25, 0x00
	std	Y+10, r25
	std	Y+9, r24
MD5UpdateG:
MD5UpdateC:
	ldd	r24, Y+9
	ldd	r25, Y+10
	cpi	r24, 0x40
	cpc	r25, r1
	brcc	MD5UpdateD
;    }
;    /* Handle any remaining bytes of data. */
;    memcpy(md5_Info.in, buf, len);
	ldi	r24, lo8(md5_Info_in)
	ldi	r25, hi8(md5_Info_in) 
	ldd	r22, Y+7	
	ldd	r23, Y+8
	ldd	r20, Y+9
	ldd	r21, Y+10
	call	memcpy
MD5UpdateF:
	adiw	r28, 10	; 
	in	r0, 0x3f
	cli
	out	0x3e, r29
	out	0x3f, r0
	out	0x3d, r28
	pop	r29
	pop	r28
	pop	r17
	pop	r16
	ret
;}
