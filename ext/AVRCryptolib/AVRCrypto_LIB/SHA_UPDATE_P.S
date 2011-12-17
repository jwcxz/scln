#include <avr/io.h>

// 
// SHA-1 for the AVR
// By Emile van der Laan
// www.emsign.nl
//


#define __zero_reg__ R1
	.text			; switches to the .text section (code and ROM constants)
	.global	Sha_Update_P
	.extern SHA_Reverse_Bytes
	.extern Sha_Transform


/* update the SHA digest */

;void sha_update( unsigned char *buffer, unsigned int count)
;{
; buffer 	Y+(1->2)  
; count 	Y+(3->4)
; i 		Y+(5->6)
Sha_Update_P:
    push	r28
    push	r29
    in		r28, 0x3d	; 61
    in		r29, 0x3e	; 62
    sbiw	r28, 0x06	; 6
    in		r0, 0x3f	; 63
    cli
    out		0x3e, r29	; 62
    out		0x3f, r0	; 63
    out		0x3d, r28	; 61
    std		Y+2, r25	; 
    std		Y+1, r24	; 
    std		Y+4, r23	; 
    std		Y+3, r22	; 
;	int i;
;	if ((Sha_Info.count_lo + ((unsigned long) count << 3)) < Sha_Info.count_lo) {
    eor		r20, r20	; R26=0
    eor		r21, r21
    movw	r26, r20
	movw	r18, r22
    set
    bld		r1, 2
Sha_Update1:
    add		r18, r18
    adc		r19, r19
    adc		r20, r20
    adc		r21, r21
    lsr		r1
    brne	Sha_Update1 
    lds		r24, Sha_Info+21*4+0
    lds		r25, Sha_Info+21*4+1
    lds		r26, Sha_Info+21*4+2
    lds		r27, Sha_Info+21*4+3
    add		r18, r24
    adc		r19, r25
    adc		r20, r26
    adc		r21, r27
    cp		r18, r24
    cpc		r19, r25
    cpc		r20, r26
    cpc		r21, r27
    brcc 	Sha_Update2;	
;	++Sha_Info.count_hi;
    lds		r24,Sha_Info+21*5+0;
    lds		r25,Sha_Info+21*5+1;
    lds		r26,Sha_Info+21*5+2;
    lds		r27,Sha_Info+21*5+3;
    adiw	r24, 0x01	; 1
    adc		r26, r1
    adc		r27, r1
    sts		Sha_Info+21*5+0,r24;
    sts		Sha_Info+21*5+1,r25;
    sts		Sha_Info+21*5+2,r26;
    sts		Sha_Info+21*5+3,r27;
;	}
Sha_Update2:
;	Sha_Info.count_lo += (unsigned long) count << 3;
    sts		Sha_Info+21*4+0,r18;
    sts		Sha_Info+21*4+1,r19;
    sts		Sha_Info+21*4+2,r20;
    sts		Sha_Info+21*4+3,r21;

;	if (Sha_Info.local) {
    lds		r24, Sha_Info+23*4  
    lds		r25, Sha_Info+23*4+1
    sbiw	r24, 0x00	; 0
    brne	Sha_Update5 ; 	
    rjmp	Sha_Update9 ; 
Sha_Update5:
;	i = SHA_BLOCKSIZE - Sha_Info.local;
    ldi		r20, 0x40	; 64
    ldi		r21, 0x00	; 0
    sub		r20, r24
    sbc		r21, r25
    std		Y+6, r21	; hi(i)
    std		Y+5, r20	; lo(i)
;	if (i > count) {
    ldd		r24, Y+3	; lo(count)
    ldd		r25, Y+4	; hi(count)
    cp		r24, r20
    cpc		r25, r21
    brge 	Sha_Update6;
;		i = count;
    std		Y+6, r25	; hi(i)
    std		Y+5, r24	; lo(i)
	movw	r20, r24	; copy i also in R20
;	}
Sha_Update6:

;	memcpy_P(((unsigned char *) Sha_Info.data) + Sha_Info.local, buffer, i);
;	count -= i			;
    ldd		r18, Y+3	; lo(count)
    ldd		r19, Y+4	; hi(count)
    sub		r18, r20	;
    sbc		r19, r21	;
    std		Y+4, r19	; hi(count)
    std		Y+3, r18	; lo(count) 
;	buffer += i	
    ldd		r22, Y+1	; lo(buffer)
    ldd		r23, Y+2	; hi(buffer)
	movw	r18, r22	;
    add		r18, r20	;
    adc		r19, r21	;
    std		Y+2, r19	; hi(buffer)
    std		Y+1, r18	; lo(buffer)
;	Sha_Info.local += i	;
    lds		r24, Sha_Info+23*4
    lds		r25, Sha_Info+23*4+1
	movw    r18, r24
    add		r18, r20
    adc		r19, r21
    sts		Sha_Info+23*4+1,r19
    sts		Sha_Info+23*4  ,r18
    subi	r24, lo8(-(Sha_Info))
    sbci	r25, hi8(-(Sha_Info))
    call	memcpy_P  

;	if (Sha_Info.local == SHA_BLOCKSIZE) {
    lds		r24, Sha_Info+23*4  
    lds		r25, Sha_Info+23*4+1
    cpi		r24, 0x40	; 64
    cpc		r25, r1
    brne	Sha_Update7 
;		SHA_Reverse_Bytes();
    call	SHA_Reverse_Bytes
;		Sha_Transform();
    call	Sha_Transform; 
;	} else {
;		return;
;	}
;	}
Sha_Update9:
;	while (count >= SHA_BLOCKSIZE) {
    ldd		r20, Y+3	; lo(count)
    ldd		r21, Y+4	; hi(count)
    cpi		r20, 0x40	; 64
    cpc		r21, r1
    brlt	Sha_Update8
;	memcpy_P(Sha_Info.data, buffer, SHA_BLOCKSIZE);
;		   R24            R22     R20
;	buffer += SHA_BLOCKSIZE;
;	count -= SHA_BLOCKSIZE;
	movw 	r24, r20
    ldi		r20, 0x40	; 64
    ldi		r21, 0x00	; 0
    ldd		r22, Y+1	; lo(buffer)
    ldd		r23, Y+2	; hi(buffer)
	movw	r18, r22
    add		r18, r20	
    adc		r19, r21	
    std		Y+2, r19	; hi(buffer)	
    std		Y+1, r18	; lo(buffer)
	movw	r18, r24	; count in r18
    sub 	r18, r20	; add 0x40  64 dec
    sbc		r19, r21	;
    std		Y+4, r19	
    std		Y+3, r18	
    ldi		r24, lo8(Sha_Info);
    ldi		r25, hi8(Sha_Info);
    call	memcpy_P
;	SHA_Reverse_Bytes();
    call	SHA_Reverse_Bytes
;	Sha_Transform();
    call	Sha_Transform
    rjmp	Sha_Update9
;	}
Sha_Update8:
;	memcpy_P(Sha_Info.data, buffer, count);
;	Sha_Info.local = count;
    ldd		r22, Y+1	; lo(buffer)	
    ldd		r23, Y+2	; hi(buffer)
    ldi		r24, lo8(Sha_Info)  
    ldi		r25, hi8(Sha_Info)  
    sts		Sha_Info+23*4+1,r21 
    sts		Sha_Info+23*4,  r20 
    call 	memcpy_P
Sha_Update7:
    adiw	r28, 0x06	
    in		r0, 0x3f	
    cli
    out		0x3e, r29	
    out		0x3f, r0	
    out		0x3d, r28	
    pop		r29
    pop		r28
    ret

