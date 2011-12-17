
; SHA-1 for the AVR
; By Emile van der Laan
; www.emsign.nl


#include <avr/io.h>

#define __zero_reg__ R1
;	Declare the Ram data
	.data
	.global	Sha_Info
Sha_Info:
	.space	(16*4)+(5*4)+(2*4)+2
Sha_WP:
	.space	2
sha_copy_digest:
	.space	(6*4)

;	.global	Sha_Init_Const
	.section .progmem.data ; This will be loaded at the start of the rom so you will not need long Pointers
Sha_Init_Const:
	.byte	0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10,0xf0,0xe1,0xd2,0xc3

	.text			; switches to the .text section (code and ROM constants)
	.global	Sha_Final
	.global	Sha_Init
	.global SHA_Reverse_Bytes
	.global Sha_Transform

SHA_Reverse_Bytes:
	ldi		r30,lo8(Sha_Info)
	ldi		r31,hi8(Sha_Info)
	ldi		r24,0x10				; SHA_BLOCKSIZE/sizeof(LONG)
Reverse_Next_Bytes:
	ldd		r25,Z+0
	ldd 	r26,Z+3
	std		Z+0,r26
	std		Z+3,r25
	ldd		r25,Z+1
	ldd 	r26,Z+2
	std		Z+1,r26
	std		Z+2,r25
	adiw	R30,4
	dec     r24
	brne	Reverse_Next_Bytes
	ret

;Sha_Init()

Sha_Init:
;	memcpy_P(Sha_Info.digest,Sha_Init_Const,sizeof(sha_init_const));
    ldi	r20, 0x14	; 20
    ldi	r21, 0x00	; 0
    ldi	r22, lo8(Sha_Init_Const) 
    ldi	r23, hi8(Sha_Init_Const) 
    ldi	r24, lo8(Sha_Info+16*4)	
    ldi	r25, hi8(Sha_Info+16*4)	
    call	memcpy_P
;	memset(&Sha_Info.count_lo,0,sizeof(Sha_Info.count_lo)+sizeof(Sha_Info.count_hi)+sizeof(Sha_Info.local));
    ldi	r20, 0x0A	
    ldi	r21, 0x00	
    ldi	r22, 0x00	
    ldi	r23, 0x00	
    ldi	r24, lo8(Sha_Info+16*4+5*4)	
    ldi	r25, hi8(Sha_Info+16*4+5*4)	
    call memset 
	ret

Sha_Final:
    push	r28
    push	r29
    in		r28, 0x3d	; SP LOW
    in		r29, 0x3e	; SP HI
    sbiw	r28, 0x0a	; 
    in		r0, 0x3f	; SREG
    cli
    out		0x3e, r29	; SP HI
    out		0x3f, r0	; SREG
    out		0x3d, r28	; SP LOW
;	int count= Y+(1->2)
;	unsigned  long 
;	lo_bit_count = Y+(3->6)
;   hi_bit_count = Y+(7->10);
;	Point the Z pointer to Sha_Info
    ldi	r30, lo8(Sha_Info+16*4+5*4)
    ldi	r31, hi8(Sha_Info+16*4+5*4) 

;	hi_bit_count = Sha_Info.count_hi;
    ldd		r24, Z+4
    ldd		r25, Z+5
    ldd		r26, Z+6
    ldd		r27, Z+7
    std		Y+7, r24
    std		Y+8, r25
    std		Y+9, r26
    std		Y+10, r27

;	lo_bit_count = Sha_Info.count_lo;
    ldd		r24, Z+0
    ldd		r25, Z+1
    ldd		r26, Z+2
    ldd		r27, Z+3
    std		Y+3, r24
    std		Y+4, r25
    std		Y+5, r26
    std		Y+6, r27

;	count = (int) ((lo_bit_count >> 3) & 0x3f);
	lsr		r25
	ror		r24
	lsr		r24
	lsr		r24
	andi	r24, 0x3F	
    std		Y+2, r1	
    std		Y+1, r24

;	((unsigned char *) Sha_Info.data)[count++] = 0x80;
    ldd		r18, Y+1	; count low
    ldd		r19, Y+2	; count hi
    movw	r26, r18
    subi	r18, lo8(-(1))	;Add 1 ## Add in the Z reg
    sbci	r19, hi8(-(1))	; 
    std		Y+2, r19	; 
    std		Y+1, r18	; 
    subi	r26, lo8(-(Sha_Info)) ; 
    sbci	r27, hi8(-(Sha_Info)) ; 
    ldi		r24, 0x80	; 128
    st		X, r24
;	if (count > SHA_BLOCKSIZE - 8) {
    ldd		r24, Y+1	; 
    ldd		r25, Y+2	; 
    cpi		r24, 0x39	; 57
    cpc		r25, r1
    brlt	Sha_Final2  ; 
;	memset(((unsigned char *) Sha_Info.data) + count, 0, SHA_BLOCKSIZE - count);
    ldi		r18, 0x40	; 64
    ldi		r19, 0x00	; 
    ldd		r24, Y+1	; count low 
    ldd		r25, Y+2	; count hi
    sub		r18, r24
    sbc		r19, r25
    ldd		r24, Y+1	; count low
    ldd		r25, Y+2	; count hi
    subi 	r24, lo8(-(Sha_Info))	;
    sbci 	r25, hi8(-(Sha_Info))	;
    movw 	r20, r18
    ldi		r22, 0x00	
    ldi		r23, 0x00	
    call	memset	
;	SHA_Reverse_Bytes();
    call	SHA_Reverse_Bytes	
;	Sha_Transform();
    call	Sha_Transform		
;	memset((unsigned char *) Sha_Info.data, 0, SHA_BLOCKSIZE - 8);
    ldi		r20, 0x38	; 56
    ldi		r21, 0x00	
    ldi		r22, 0x00	
    ldi		r23, 0x00	
    ldi		r24, lo8(Sha_Info) 
    ldi		r25, hi8(Sha_Info) 
    call	memset	
    rjmp	Sha_Final3	
;	} else {
Sha_Final2:
;	memset(((unsigned char *) Sha_Info.data) + count, 0,
    ldi		r18, 0x38	; 56
    ldi		r19, 0x00	; 0
    ldd		r24, Y+1	
    ldd		r25, Y+2	
    sub		r18, r24
    sbc		r19, r25
    ldd		r24, Y+1	
    ldd		r25, Y+2	
    subi	r24, lo8(-(Sha_Info))	; 162
    sbci	r25, hi8(-(Sha_Info))	; 246
    movw	r20, r18
    ldi		r22, 0x00	
    ldi		r23, 0x00	
    call	memset	
;		SHA_BLOCKSIZE - 8 - count);
;	}
Sha_Final3:
;	SHA_Reverse_Bytes();
    call	SHA_Reverse_Bytes 
;	Point the Z pointer to Sha_Info
    ldi	r30, lo8(Sha_Info+14*4)
    ldi	r31, hi8(Sha_Info+14*4) 

;	Sha_Info.data[14] = hi_bit_count;
    ldd		r24, Y+7	
    ldd		r25, Y+8	
    ldd		r26, Y+9	
    ldd		r27, Y+10	
    std		Z+0, r24
    std		Z+1, r25
    std		Z+2, r26
    std		Z+3, r27
;	Sha_Info.data[15] = lo_bit_count;
    ldd		r24, Y+3	
    ldd		r25, Y+4	
    ldd		r26, Y+5	
    ldd		r27, Y+6	
    std		Z+4, r24	
    std		Z+5, r25
    std		Z+6, r26
    std		Z+7, r27
;	Sha_Transform();
    call	Sha_Transform	
    adiw	r28, 0x0a	
    in		r0, 0x3f	
    cli
    out		0x3e, r29	
    out		0x3f, r0	
    out		0x3d, r28	
    pop		r29
    pop		r28
    ret



;void Sha_Function(void)
Sha_Function:
    push	r16
    push	r17
    push	r28
    push	r29
	ldi r28,lo8(sha_copy_digest)
	ldi r29,hi8(sha_copy_digest)
;		sha_copy_digest[5] += ROT32(sha_copy_digest[0],5)  + sha_copy_digest[4] + *Sha_WP++ ;	

    ldd	r18, Y+0
    ldd	r19, Y+1
    ldd	r20, Y+2
    ldd	r21, Y+3
    ldi r22,5
Sha_Function1:
	lsl r18
	rol r19
	rol r20
	rol r21
	adc r18,__zero_reg__
    dec r22
    brne	Sha_Function1;

    ldd	r24, Y+4*4+0
    ldd	r25, Y+4*4+1
    ldd	r26, Y+4*4+2
    ldd	r27, Y+4*4+3

    add	r18, r24
    adc	r19, r25
    adc	r20, r26
    adc	r21, r27
    ldi	r16, lo8(Sha_WP)
    ldi	r17, hi8(Sha_WP)
    movw	r30, r16
    ld	r22, Z+
    ld	r23, Z+	

    movw	r30, r22
    ld	r24, Z+
    ld	r25, Z+	
    ld	r26, Z+	
    ld	r27, Z+	
    add	r18, r24
    adc	r19, r25
    adc	r20, r26
    adc	r21, r27


    ldd	r24, Y+5*4+0
    ldd	r25, Y+5*4+1
    ldd	r26, Y+5*4+2
    ldd	r27, Y+5*4+3

    add		r24, r18
    adc		r25, r19
    adc		r26, r20
    adc		r27, r21
    subi	r22, lo8(-(4)) 
    sbci	r23, hi8(-(4))
    movw	r30, r16
    st		Z+, r22
	st		Z+, r23	
    
    std	Y+5*4+0,r24
    std	Y+5*4+1,r25
    std	Y+5*4+2,r26
    std	Y+5*4+3,r27

;		sha_copy_digest[4] = sha_copy_digest[3]; 

    ldd	r24, Y+3*4+0
    ldd	r25, Y+3*4+1
    ldd	r26, Y+3*4+2
    ldd	r27, Y+3*4+3

    std	Y+4*4+0,r24
    std	Y+4*4+1,r25
    std	Y+4*4+2,r26
    std	Y+4*4+3,r27
;		sha_copy_digest[3] = sha_copy_digest[2]; 
    ldd	r24, Y+2*4+0
    ldd	r25, Y+2*4+1
    ldd	r26, Y+2*4+2
    ldd	r27, Y+2*4+3

    std	Y+3*4+0,r24
    std	Y+3*4+1,r25
    std	Y+3*4+2,r26
    std	Y+3*4+3,r27

;		sha_copy_digest[2] = ROT32(sha_copy_digest[1],30); 

    ldd	r24, Y+1*4+0
    ldd	r25, Y+1*4+1
    ldd	r26, Y+1*4+2
    ldd	r27, Y+1*4+3
	mov r23,__zero_reg__
	lsr r27
	ror r26
	ror r25
	ror r24
	ror r23
	lsr r27
	ror r26
	ror r25
	ror r24
	ror r23
	or  r27,r23
    std	Y+2*4+0,r24
    std	Y+2*4+1,r25
    std	Y+2*4+2,r26
    std	Y+2*4+3,r27
;		sha_copy_digest[1] = sha_copy_digest[0]; 

    ldd	r24, Y+0*4+0
    ldd	r25, Y+0*4+1
    ldd	r26, Y+0*4+2
    ldd	r27, Y+0*4+3

    std	Y+1*4+0,r24
    std	Y+1*4+1,r25
    std	Y+1*4+2,r26
    std	Y+1*4+3,r27
;		sha_copy_digest[0] = sha_copy_digest[5];

    ldd	r24, Y+5*4+0
    ldd	r25, Y+5*4+1
    ldd	r26, Y+5*4+2
    ldd	r27, Y+5*4+3
    std	Y+0*4+0,r24
    std	Y+0*4+1,r25
    std	Y+0*4+2,r26
    std	Y+0*4+3,r27

	pop	r29
    pop	r28
    pop	r17
    pop	r16
    ret


;void Sha_Transform()
;{
Sha_Transform:
    push	r16
    push	r28
    push	r29
    in		r28, 0x3d	
    in		r29, 0x3e	
    subi	r28, 0x42	
    sbci	r29, 0x01	
    in		r0, 0x3f	
    cli
    out		0x3e, r29	
    out		0x3f, r0	
    out		0x3d, r28	
;	int i;
;	unsigned long W[80];
;	memcpy(W,Sha_Info.data,sizeof(Sha_Info.data));
    movw	r24, r28
    adiw	r24, 0x03	
    ldi		r20, 0x40	
    ldi		r21, 0x00	
    ldi		r22, lo8(Sha_Info) 
    ldi		r23, hi8(Sha_Info) 
    call	memcpy 			

;	for (i = 16; i < 80; ++i) {
;	W[i] = W[i-3] ^ W[i-8] ^ W[i-14] ^ W[i-16];
;	W[i] = ROT32(W[i], 1);
    ldi		r16, 0x10	; 16
    movw	r30, r28	; Add W
    adiw	r30, 0x03	; 1
Sha_Transform3:
    ldd		r18, Z+0+((16*4)-(16*4))	; W[i-16]
    ldd		r19, Z+1+((16*4)-(16*4))	
    ldd		r20, Z+2+((16*4)-(16*4))	
    ldd		r21, Z+3+((16*4)-(16*4))	
    ldd		r22, Z+0+((16*4)-(14*4))	; W[i-14]
    ldd		r23, Z+1+((16*4)-(14*4))	
    ldd		r24, Z+2+((16*4)-(14*4))	
    ldd		r25, Z+3+((16*4)-(14*4))	
    eor		r18, r22
    eor		r19, r23
    eor		r20, r24
    eor		r21, r25
    ldd		r22, Z+0+((16*4)-(8*4))	; W[i-8]
    ldd		r23, Z+1+((16*4)-(8*4))
    ldd		r24, Z+2+((16*4)-(8*4))	
    ldd		r25, Z+3+((16*4)-(8*4))
    eor		r18, r22
    eor		r19, r23
    eor		r20, r24
    eor		r21, r25
    ldd		r22, Z+0+((16*4)-(3*4))	; W[i-3]
    ldd		r23, Z+1+((16*4)-(3*4))	
    ldd		r24, Z+2+((16*4)-(3*4))	
    ldd		r25, Z+3+((16*4)-(3*4))	
    eor		r18, r22
    eor		r19, r23
    eor		r20, r24
    eor		r21, r25
	lsl		r18
	rol		r19
	rol		r20
	rol		r21
	adc		r18,__zero_reg__
	adiw	r30, 0x04	
    std		Z+60,r18; W[i]
    std		Z+61,r19
    std		Z+62,r20	
    std		Z+63,r21
	inc		r16
    cpi		r16, 0x50	; 80
	brlo 	Sha_Transform3

Sha_Transform2:
;	memcpy(sha_copy_digest,Sha_Info.digest,4*5);
    ldi		r20, 0x14	; 20
    ldi		r21, 0x00	; 0
    ldi		r22, lo8(Sha_Info+16*4)
    ldi		r23, hi8(Sha_Info+16*4)
    ldi		r24, lo8(sha_copy_digest)
    ldi		r25, hi8(sha_copy_digest)
    call	memcpy 
;	Sha_WP = W;
    movw	r24, r28
    adiw	r24, 0x03
    sts		Sha_WP+1,r25
    sts		Sha_WP+0,r24
	ldi		r30,lo8(sha_copy_digest)
	ldi		r31,hi8(sha_copy_digest)
	ldi 	r16,0
Sha_Transform6:
;	for (i =  0; i < 20; ++i) 
;		sha_copy_digest[5] = ((sha_copy_digest[1] & sha_copy_digest[2]) | (~sha_copy_digest[1] & sha_copy_digest[3])) + CONST1;
    ldd		r18, Z+1*4+0
    ldd		r19, Z+1*4+1
    ldd		r24, Z+2*4+0
    ldd		r25, Z+2*4+1
	movw 	r26, r18
	and		r18, r24
	and		r19, r25
    com		r26
    com		r27
    ldd		r24, Z+3*4+0
    ldd		r25, Z+3*4+1
	and		r26, r24
	and		r27, r25
    or		r18, r26
    or		r19, r27

    ldd		r20, Z+1*4+2
    ldd		r21, Z+1*4+3
    ldd		r24, Z+2*4+2
    ldd		r25, Z+2*4+3
	movw 	r26, r20
	and		r20, r24
	and		r21, r25
    com		r26
    com		r27
    ldd		r24, Z+3*4+2
    ldd		r25, Z+3*4+3
	and		r26, r24
	and		r27, r25
    or		r20, r26
    or		r21, r27

    subi	r18, 0x67	
    sbci	r19, 0x86	
    sbci	r20, 0x7D	
    sbci	r21, 0xA5	
    std		Z+5*4+0,r18
    std		Z+5*4+1,r19
    std		Z+5*4+2,r20
    std		Z+5*4+3,r21
	call	Sha_Function
	inc		r16
	cpi 	r16,20
	brlo	Sha_Transform6;
;	for (i = 20; i < 40; ++i) 
;		sha_copy_digest[5] =  (sha_copy_digest[1] ^ sha_copy_digest[2] ^ sha_copy_digest[3]) + CONST2;	

Sha_Transform5:
    ldd		r18, Z+1*4+0
    ldd		r19, Z+1*4+1
    ldd		r20, Z+1*4+2
    ldd		r21, Z+1*4+3
    ldd		r24, Z+2*4+0
    ldd		r25, Z+2*4+1
    ldd		r26, Z+2*4+2
    ldd		r27, Z+2*4+3
    eor		r18, r24
    eor		r19, r25
    eor		r20, r26
    eor		r21, r27
    ldd		r24, Z+3*4+0
    ldd		r25, Z+3*4+1
    ldd		r26, Z+3*4+2
    ldd		r27, Z+3*4+3
    eor		r18, r24
    eor		r19, r25
    eor		r20, r26
    eor		r21, r27
    subi	r18, 0x5F
    sbci	r19, 0x14
    sbci	r20, 0x26
    sbci	r21, 0x91
    std		Z+5*4+0,r18
    std		Z+5*4+1,r19
    std		Z+5*4+2,r20
    std		Z+5*4+3,r21
	call	Sha_Function
	inc		r16
	cpi 	r16,40
	brlo	Sha_Transform5;
Sha_Transform7:
;	for (i = 40; i < 60; ++i) 
;		sha_copy_digest[5] = ((sha_copy_digest[1] & sha_copy_digest[2]) | (sha_copy_digest[1] & sha_copy_digest[3]) | (sha_copy_digest[2] & sha_copy_digest[3])) + CONST3;	
    ldd		r18, Z+1*4+0
    ldd		r19, Z+1*4+1
    ldd		r24, Z+2*4+0
    ldd		r25, Z+2*4+1
	movw 	r26, r18
	and		r18, r24
	and		r19, r25
    ldd		r24, Z+3*4+0
    ldd		r25, Z+3*4+1
	and		r26, r24
	and		r27, r25
    or		r18, r26
    or		r19, r27
    ldd		r26, Z+2*4+0
    ldd		r27, Z+2*4+1
	and 	r24, r26
	and 	r25, r27
	or		r18, r24
	or		r19, r25

    ldd		r20, Z+1*4+2
    ldd		r21, Z+1*4+3
    ldd		r24, Z+2*4+2
    ldd		r25, Z+2*4+3
	movw 	r26, r20
	and		r20, r24
	and		r21, r25
    ldd		r24, Z+3*4+2
    ldd		r25, Z+3*4+3
	and		r26, r24
	and		r27, r25
    or		r20, r26
    or		r21, r27
    ldd		r26, Z+2*4+2
    ldd		r27, Z+2*4+3
	and 	r24, r26
	and 	r25, r27
	or		r20, r24
	or		r21, r25

    subi	r18, 0x24	
    sbci	r19, 0x43	
    sbci	r20, 0xE4	
    sbci	r21, 0x70	
    std		Z+5*4+0,r18
    std		Z+5*4+1,r19
    std		Z+5*4+2,r20
    std		Z+5*4+3,r21
	call	Sha_Function
	inc		r16
	cpi 	r16,60
	brlo	Sha_Transform7;
;	for (i = 60; i < 80; ++i) 
;		sha_copy_digest[5] = (sha_copy_digest[1] ^ sha_copy_digest[2] ^ sha_copy_digest[3]) + CONST4;	
Sha_Transform9:
    ldd		r18, Z+1*4+0
    ldd		r19, Z+1*4+1
    ldd		r20, Z+1*4+2
    ldd		r21, Z+1*4+3
    ldd		r24, Z+2*4+0
    ldd		r25, Z+2*4+1
    ldd		r26, Z+2*4+2
    ldd		r27, Z+2*4+3
    eor		r18, r24
    eor		r19, r25
    eor		r20, r26
    eor		r21, r27
    ldd		r24, Z+3*4+0
    ldd		r25, Z+3*4+1
    ldd		r26, Z+3*4+2
    ldd		r27, Z+3*4+3
    eor		r18, r24
    eor		r19, r25
    eor		r20, r26
    eor		r21, r27
    subi	r18, 0x2A
    sbci	r19, 0x3E
    sbci	r20, 0x9D
    sbci	r21, 0x35
    std		Z+5*4+0,r18
    std		Z+5*4+1,r19
    std		Z+5*4+2,r20
    std		Z+5*4+3,r21
	call	Sha_Function
	inc		r16
	cpi 	r16,80
	brlo	Sha_Transform9;
;	for (i = 0; i < 5; ++i)
;		Sha_Info.digest[i] += sha_copy_digest[i];    
	ldi		r30, lo8(Sha_Info+(16*4))
    ldi 	r31, hi8(Sha_Info+(16*4))
    ldi		r26, lo8(sha_copy_digest)
    ldi		r27, hi8(sha_copy_digest)	
	ldi		r16,0
Sha_Transform12:	
	ldd 	r22,Z+0
	ldd 	r23,Z+1
	ldd 	r24,Z+2
	ldd 	r25,Z+3
	ld 		r18,X+
	ld 		r19,X+
	ld 		r20,X+
	ld 		r21,X+
	add		r22,r18
	adc		r23,r19
	adc		r24,r20
	adc		r25,r21
	st 		Z+,r22
	st 		Z+,r23
	st 		Z+,r24
	st 		Z+,r25
	inc		r16
	cpi 	r16,5
	brlo	Sha_Transform12;
Sha_Transform14:
    subi	r28, 0xBE	
    sbci	r29, 0xFE	
    in		r0, 0x3f	
    cli
    out		0x3e, r29	
    out		0x3f, r0	
    out		0x3d, r28	
	pop		r29
	pop		r28
    pop		r16
    ret

