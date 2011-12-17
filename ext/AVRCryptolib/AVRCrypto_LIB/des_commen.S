#include <avr/io.h>
// 
// Des for the AVR
// By Emile van der Laan 
// 

	.data
Des_Kns:
	.space	96
Knns:
	.space	2
Des_Input:
	.space	8
Des_Key:
	.space	8
Des_Temp:
	.space	1
Des_cds:
	.space	7

	.global	Des_Key
	.global	Des_Input
	.global	Des_Kns

	.text			; switches to the .text section (code and ROM constants)
	.global	DesKeyScheduleCalculation	
	.global	des_Input_mem_ex
	.global	des_permutation
	.global	des_frement
	.global	T1_1
	.global	T2_1
	.section .progmem.data

T1_1:
	.byte 39, 7, 47, 15, 55, 23, 63, 31
	.byte 38, 6, 46, 14, 54, 22, 62, 30
	.byte 37, 5, 45, 13, 53, 21, 61, 29
	.byte 36, 4, 44, 12, 52, 20, 60, 28
	.byte 35, 3, 43, 11, 51, 19, 59, 27
	.byte 34, 2, 42, 10, 50, 18, 58, 26
	.byte 33, 1, 41,  9, 49, 17, 57, 25
	.byte 32, 0, 40,  8, 48, 16, 56, 24

T2_1:
	.byte 57, 49, 41, 33, 25, 17,  9, 1
	.byte 59, 51, 43, 35, 27, 19, 11, 3 
	.byte 61, 53, 45, 37, 29, 21, 13, 5 
	.byte 63, 55, 47, 39, 31, 23, 15, 7 
	.byte 56, 48, 40, 32, 24, 16,  8, 0 
	.byte 58, 50, 42, 34, 26, 18, 10, 2 
	.byte 60, 52, 44, 36, 28, 20, 12, 4 
	.byte 62, 54, 46, 38, 30, 22, 14, 6

T3_32:
	.byte 31+32, 0+32, 1+32, 2+32, 3+32, 4+32
	.byte  3+32, 4+32, 5+32, 6+32, 7+32, 8+32
	.byte  7+32, 8+32, 9+32,10+32,11+32,12+32
	.byte 11+32,12+32,13+32,14+32,15+32,16+32
	.byte 15+32,16+32,17+32,18+32,19+32,20+32
	.byte 19+32,20+32,21+32,22+32,23+32,24+32
	.byte 23+32,24+32,25+32,26+32,27+32,28+32
	.byte 27+32,28+32,29+32,30+32,31+32, 0+32

T5_1_32:
	.byte   8+32,16+32,22+32,30+32
	.byte  12+32,27+32, 1+32,17+32
	.byte  23+32,15+32,29+32, 5+32
	.byte  25+32,19+32, 9+32, 0+32
	.byte   7+32,13+32,24+32, 2+32
	.byte   3+32,28+32,10+32,18+32
	.byte  31+32,11+32,21+32, 6+32
	.byte   4+32,26+32,14+32,20+32

T7_1_2:
	.byte 56,48,40,32,24,16, 8
	.byte  0,57,49,41,33,25,17
	.byte  9, 1,58,50,42,34,26
	.byte 18,10, 2,59,51,43,35
	.byte 62,54,46,38,30,22,14
	.byte  6,61,53,45,37,29,21
	.byte 13, 5,60,52,44,36,28
	.byte 20,12, 4,27,19,11, 3

T9:
	.byte 13,16,10,23, 0, 4
	.byte  2,27,14, 5,20, 9
	.byte 22,18,11, 3,25, 7
	.byte 15, 6,26,19,12, 1
	.byte 40,51,30,36,46,54
	.byte 29,39,50,44,32,47
	.byte 43,48,38,55,33,52
	.byte 45,41,49,35,28,31

sTable:
;	S-box 1
	.byte 0xE4, 0xD1, 0x2F, 0xB8, 0x3A, 0x6C, 0x59, 0x07
	.byte 0x0F, 0x74, 0xE2, 0xD1, 0xA6, 0xCB, 0x95, 0x38
	.byte 0x41, 0xE8, 0xD6, 0x2B, 0xFC, 0x97, 0x3A, 0x50
	.byte 0xFC, 0x82, 0x49, 0x17, 0x5B, 0x3E, 0xA0, 0x6D

;	S-box 2
	.byte 0xF1, 0x8E, 0x6B, 0x34, 0x97, 0x2D, 0xC0, 0x5A
	.byte 0x3D, 0x47, 0xF2, 0x8E, 0xC0, 0x1A, 0x69, 0xB5
	.byte 0x0E, 0x7B, 0xA4, 0xD1, 0x58, 0xC6, 0x93, 0x2F
	.byte 0xD8, 0xA1, 0x3F, 0x42, 0xB6, 0x7C, 0x05, 0xE9

;	S-box 3
	.byte 0xA0, 0x9E, 0x63, 0xF5, 0x1D, 0xC7, 0xB4, 0x28
	.byte 0xD7, 0x09, 0x34, 0x6A, 0x28, 0x5E, 0xCB, 0xF1
	.byte 0xD6, 0x49, 0x8F, 0x30, 0xB1, 0x2C, 0x5A, 0xE7
	.byte 0x1A, 0xD0, 0x69, 0x87, 0x4F, 0xE3, 0xB5, 0x2C

;	S-box 4
	.byte 0x7D, 0xE3, 0x06, 0x9A, 0x12, 0x85, 0xBC, 0x4F
	.byte 0xD8, 0xB5, 0x6F, 0x03, 0x47, 0x2C, 0x1A, 0xE9
	.byte 0xA6, 0x90, 0xCB, 0x7D, 0xF1, 0x3E, 0x52, 0x84
	.byte 0x3F, 0x06, 0xA1, 0xD8, 0x94, 0x5B, 0xC7, 0x2E

;	S-box 5
	.byte 0x2C, 0x41, 0x7A, 0xB6, 0x85, 0x3F, 0xD0, 0xE9
	.byte 0xEB, 0x2C, 0x47, 0xD1, 0x50, 0xFA, 0x39, 0x86
	.byte 0x42, 0x1B, 0xAD, 0x78, 0xF9, 0xC5, 0x63, 0x0E
	.byte 0xB8, 0xC7, 0x1E, 0x2D, 0x6F, 0x09, 0xA4, 0x53

;	S-box 6
	.byte 0xC1, 0xAF, 0x92, 0x68, 0x0D, 0x34, 0xE7, 0x5B
	.byte 0xAF, 0x42, 0x7C, 0x95, 0x61, 0xDE, 0x0B, 0x38
	.byte 0x9E, 0xF5, 0x28, 0xC3, 0x70, 0x4A, 0x1D, 0xB6
	.byte 0x43, 0x2C, 0x95, 0xFA, 0xBE, 0x17, 0x60, 0x8D

;	S-box 7
	.byte 0x4B, 0x2E, 0xF0, 0x8D, 0x3C, 0x97, 0x5A, 0x61
	.byte 0xD0, 0xB7, 0x49, 0x1A, 0xE3, 0x5C, 0x2F, 0x86
	.byte 0x14, 0xBD, 0xC3, 0x7E, 0xAF, 0x68, 0x05, 0x92
	.byte 0x6B, 0xD8, 0x14, 0xA7, 0x95, 0x0F, 0xE2, 0x3C

;	S-box 8
	.byte 0xD2, 0x84, 0x6F, 0xB1, 0xA9, 0x3E, 0x50, 0xC7
	.byte 0x1F, 0xD8, 0xA3, 0x74, 0xC5, 0x6B, 0x0E, 0x92
	.byte 0x7B, 0x41, 0x9C, 0xE2, 0x06, 0xAD, 0xF3, 0x58
	.byte 0x21, 0xE7, 0x4A, 0x8D, 0xFC, 0x90, 0x35, 0x6B

	.text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;void mem_clr(unsigned char *s1,unsigned char len)
mem_clr:
	st		Z+,R1
	dec		r22
	brne	mem_clr
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memory_copy:
	ld		r0, Z+
	st		X+, r0
	dec		R20
	brne	memory_copy 
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
des_Input_mem_ex:
;void Des_Input_mem_ex(void)
;{
;unsigned char i,n;
;	for(i=0;i<4;i++)
;	n=Des_Input[i]
;	Des_Input[i]=Des_Input[4+i];
;	Des_Input[4+i]=n;	

	ldi		r26, lo8(Des_Input)		; YL
	ldi		r27, hi8(Des_Input)		; YH
	ldi		r30, lo8(Des_Input+4)	; ZL
	ldi		r31, hi8(Des_Input+4)	; ZH
	ldi		r20,0x04
mem_ex1:
	ld		r18, Z
	ld		r19, X
	st		Z+,R19
	st		X+,R18
	dec		r20
	brne	mem_ex1
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

des_frement:
;		memcpy(Des_Temp,&Des_Input[4], 4);
	ldi		r20, 0x04
	ldi		r30,lo8(Des_Input+4)
	ldi		r31,hi8(Des_Input+4)
	ldi		r26,lo8(Des_Temp)
	ldi		r27,hi8(Des_Temp)
	rcall	memory_copy
;		fonction(n)
	mov		r24, r18
	rcall	fonction				;This will use R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R30,R31
;		for (i = 0; i < 4; i++)		Des_Input[i+4] =( ( Des_Input[i]) ^ (Des_Temp[4+i] )  ) 
	ldi		r26, lo8(Des_Temp+4)	; YL
	ldi		r27, hi8(Des_Temp+4)	; YH
	ldi		r28, lo8(Des_Input)		; YL
	ldi		r29, hi8(Des_Input)		; YH
	ldi		r30, lo8(Des_Input+4)	; ZL
	ldi		r31, hi8(Des_Input+4)	; ZH
	ldi		r20,0x04
frement1:
	ld		r18, X+
	ld		r19, Y+
	eor		R18,R19
	st		z+,R18
	dec		r20
	brne	frement1	
;		memcpy(Des_Input, Des_Temp, 4);
	ldi		r20, 0x04	
	ldi		r30, lo8(Des_Temp)
	ldi		r31, hi8(Des_Temp)
	ldi		r26, lo8(Des_Input)
	ldi		r27, hi8(Des_Input)
	rjmp	memory_copy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

des_permutation:
;This will use R16,R18,R20,R21,R22,R23,R24,R25,R26,R27,R30,R31
;will save R28,R29(Y) R1 will be 0 At return
;void permutation( unsigned char *tab)
;{
;    unsigned char i;
;	memcpy(Des_Temp,Des_Input,8);
	ldi		r20, 0x08
	ldi		r30, lo8(Des_Input)
	ldi		r31, hi8(Des_Input)
	ldi		r26, lo8(Des_Temp)
	ldi		r27, hi8(Des_Temp)
	rcall	memory_copy
;	mem_clr(Des_Input,8);
	ldi		r22, 0x08
	ldi		r30, lo8(Des_Input)
	ldi		r31, hi8(Des_Input)
	rcall	mem_clr
	movw	R30,R24
;	for (i = 0; i < 64; i++)
	eor		r16, r16
permut1:
;	{	
;		if( Des_Temp[i/8]&(0x80>>(i%8)))
	mov		r26,r16
	lsr		r26
	lsr		r26
	lsr		r26
	eor		r27, r27
	subi	r26, lo8(-(Des_Temp))
	sbci	r27, hi8(-(Des_Temp))
	ld		r20, X
	mov		r18, R16
	andi	r18, 0x07
	ldi		r24, 0x80
	rjmp	permut4
permut5:
	lsr		r24
permut4:
	dec		r18
	brpl	permut5
	and		r24, R20
	breq	permut8
;		{
;			unsigned char bitno;
;			bitno = pgm_read_byte_near(tab);
	lpm		r18, Z
;			Des_Input[bitno/8]|=(0x80>>(bitno%8));
	mov		r26, r18
	lsr		r26
	lsr		r26
	lsr		r26
	eor		r27, r27
	subi	r26, lo8(-(Des_Input))
	sbci	r27, hi8(-(Des_Input))
	andi	r18, 0x07
	ldi		r24, 0x80
	rjmp	permut10
permut9:
	lsr		R24
permut10:
	dec		r18
	brpl	permut9
	ld		r18, X
	or		r24, r18
	st		X, r24
;		}
permut8:
;		tab++;
	adiw	r30, 0x01
	inc		R16
	cpi		r16, 0x40
	brcs	permut1
permut2:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fonction:
;void fonction(unsigned char n)
;{	 
;This will use R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R30,R31
;	unsigned char ptrs;
;	unsigned char i, l;
;	unsigned char c;
;	unsigned char t;
;	Knns=&Des_Kns[n];
	eor		r25, r25
	subi	r24, lo8(-(Des_Kns))
	sbci	r25, hi8(-(Des_Kns))
	sts		Knns+1, r25
	sts		Knns, r24
;	mem_clr(&Des_Temp[4],4);
	ldi		r22, 0x04
	ldi		r30, lo8(Des_Temp+4)
	ldi		r31, hi8(Des_Temp+4)
	rcall	mem_clr
;	l = 0;
	eor		R20,R20
	ldi		r28, lo8(T5_1_32)
	ldi		r29, hi8(T5_1_32)
;    for (i = 0; i < 8;i++)
	eor	r23,r23
fonction3:
	cpi		r23, 0x08
	brcs	fonction1
	rjmp	fonction2
fonction1:
;	{
;		c  =(unsigned char)( 32 * (unsigned char)(get_bit_input_knns(l)));
	rcall	get_bit_input_knns
	swap	r17
	lsl		R17
	mov		R21,r17
;			l++;
	inc		R20
;		c +=(unsigned char)(  8 * (unsigned char)(get_bit_input_knns(l)));
	rcall	get_bit_input_knns ;This will use R16,R17,R24,R25,R30,R31
	lsl		R17
	lsl		R17
	lsl		R17
	add		R21,R17
;			l++;
	inc		R20
;		c +=(unsigned char)(  4 * (unsigned char)(get_bit_input_knns(l)));
	rcall	get_bit_input_knns ;This will use R16,R17,R24,R25,R30,R31
	lsl		R17
	lsl		R17
	add		R21,R17
;			l++;
	inc 	R20
;		c +=(unsigned char)(  2 * (unsigned char)(get_bit_input_knns(l)));
	rcall	get_bit_input_knns ;This will use R16,R17,R24,R25,R30,R31
	lsl		R17
	add		R21,R17
;			l++;
	inc 	R20
;		c +=(unsigned char)(  1 * (unsigned char)(get_bit_input_knns(l)));
	rcall	get_bit_input_knns ;This will use R16,R17,R24,R25,R30,R31
	add		R21,R17
;			l++;
	inc		r20
;		c +=(unsigned char)( 16 * (unsigned char)(get_bit_input_knns(l)));
	rcall	get_bit_input_knns ;This will use R16,R17,R24,R25,R30,R31
	swap	r17
	add		R21,R17
;			l++;
	inc 	R20
;			t = pgm_read_byte_near(&T6[i][c]);
	mov		r30, r23
	swap	r30
	lsl		r30
	eor		r31, r31
	mov		r19, r21 
	lsr		r19
	add		r30, r19
	subi	r30, lo8(-(sTable))
	sbci	r31, hi8(-(sTable))
	lpm		r26, Z
	mov		r19, r21
	lsr		r19
	brcs	fonction7A
	swap	r26
fonction7A:
	andi	r26,0xf
;		for(c=0;c<4;c++)
	eor	r21,r21
fonction7:
	cpi		r21, 0x04
	brcs	fonction5
	rjmp	fonction6
fonction5:
;		{
;		if(t&0x08){
	movw	R30,R28
	lpm		R18, Z+
	movw	R28,R30
    mov		r24, r26
	ldi		R25,0x08
	and		r24,r25
	breq	fonction8
;					unsigned char bitno;
;					bitno=pgm_read_byte_near(&T5_1_32[ptrs]);
	mov		r30,R18
	eor		r31,R31
	lsr		r30
	lsr		r30
	lsr		r30
	subi	r30, lo8(-(Des_Temp))
	sbci	r31, hi8(-(Des_Temp))
	andi	r18, 0x07
	ldi		r24, 0x80
	rjmp	fonction9
fonction10:
	lsr		r24
fonction9:
	dec		r18
	brpl	fonction10
	ld		r18, Z
	or		r18, r24
	st		Z, r18
;					}
fonction8:
;			t*=2;
	lsl		R26
	inc		R21
	rjmp	fonction7
fonction6:
	inc		r23
	rjmp	fonction3
fonction2:
	ret
;		}
;    }
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

get_bit_input_knns:
;unsigned char  get_bit_input_knns(unsigned char l)
;{
; R20 = l
; R16
; R17 = input
; 
;This will use     R16,R17,R24,R25,R30,R31
	mov		R16, R20
;unsigned char input; 
;input=pgm_read_byte_near(&T3_32[l]);
	mov		R30, R20
	eor		r31, r31
	subi	r30, lo8(-(T3_32))
	sbci	r31, hi8(-(T3_32))
	lpm		R17, Z
;if(Des_Input[input/8] & (0x80>>(input%8)) 
	mov		r30, R17
	lsr		r30
	lsr		r30
	lsr		r30
	eor		r31, r31
	subi	r30, lo8(-(Des_Input))
	sbci	r31, hi8(-(Des_Input))
	ld		r24, Z
	andi	R17, 0x07
	ldi		r25, 0x80
	rjmp	input_knns0
input_knns1:
	lsr		r25
input_knns0:
	dec	r17
	brpl	input_knns1
	and		r24, r25
	breq	input_knns2
;	input = 1;
	ldi		r17, 0x01
	rjmp	input_knns3
input_knns2:
;	else
;	input = 0;
	eor		R17, R17	; R17= input
input_knns3:
;if((*Knns) & (0x80>>(l%8))) 
	lds		r30, Knns
	lds		r31, Knns+1
	ld		r25, Z+
	andi	r16, 0x07
;if((l&0x07) == 0x07) Knns++;
	cpi		r16, 0x07
	brne	input_knns9
	sts		Knns+1, r31
	sts		Knns, r30
input_knns9:
	ldi		r24, 0x80
	rjmp	input_knns4
input_knns5:
	lsr		r24
input_knns4:
	dec		r16
	brpl 	input_knns5
	and		r24, r25
	breq 	input_knns8
; input^=1;
	ldi		r25, 0x01
	eor		r17, r25
input_knns8:
;return input; 	
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DesKeyT9:
;void DesKeyT9(unsigned char n)
;{
; R24 = n
; R18 = I
; R17 = Temp
; R16 = K
;This will use     R0,R1,R16,R17,R24,R25,R26,R27(X),R30,R31(Z)
; R1 will be 0 At return
;unsigned char i;
;	n*=6;
	mov		R28,r19
	lsl		R28
	add		R28,r19
	lsl		R28
	eor		R29,r29
; R28:R29 = Y = Kns
	subi	r28, lo8(-(Des_Kns))
	sbci	r29, hi8(-(Des_Kns))
; R30:R31 = Z = T9
	ldi		r30, lo8(T9)
	ldi		r31, hi8(T9)
;	for (i = 0; i < 6; i++)
	eor		r18,r18
DesKeyT9_1:
;	{	
;	unsigned char k;
;		for (k = 0x80; k !=0; k>>=1)
	ldi		R16, 0x80
DesKeyT9_4:
;		{	
;		unsigned char tmp14;
;		tmp14=pgm_read_byte_near(&T9[tmp15++]);
	lpm		r26, Z+
;		if(Des_cds[tmp14/8]&(0x80>>(tmp14%8))) 
	mov		r25, r26
	lsr		r26
	lsr		r26
	lsr		r26
	eor		r27, r27
	subi	r26, lo8(-(Des_cds))
	sbci	r27, hi8(-(Des_cds))
	ld		r24, X
	andi	R25,7
	inc		R25
	sec
	eor		R17,R17
DesKeyT9_4B:
	ror		R17
	dec		R25
	brne	DesKeyT9_4B
	and		R24,R17
	breq	DesKeyT9_9
;				Des_Kns[n]|=k;
	ld		r24, Y
	or		r24, r16
	st		Y, r24
DesKeyT9_9:
	lsr		r16
	brcc	DesKeyT9_4
;		}
DesKeyT9_5:
	ld		R17,Y+
	inc		R18
	cpi		r18, 0x06
	brcs	DesKeyT9_1
DesKeyT9_2:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
two_drol_cds:
	rcall	drol_cds
drol_cds:				;This will use  R16,R17,R30,R31
	ldi		R30, lo8(Des_cds+7)
	ldi		R31, hi8(Des_cds+7)
	ldi		R17,7
	lds		R16,Des_cds+3
	swap	R16 
	rol		R16
drol_cds1:
	ld		R16,-z
	rol		R16
	st		z,R16
	dec		R17
	brne	drol_cds1
	lds		r24, Des_cds+3
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DesKeyScheduleCalculation:
	push	r16
	push	r17
; will save R28,R29(Y) 
	push	r28		; YL
	push	r29		; YH
;	mem_clr(Des_cds,7);
	ldi		r22, 0x07
	ldi		r30, lo8(Des_cds)
	ldi		r31, hi8(Des_cds)
	rcall	mem_clr
// 	for (n = 0; n < 56; n++)
//	{
//		unsigned char bitno;
//		bitno=pgm_read_byte_near(&T7_1_2[n]);		
//		if(Des_Key[bitno/8]&(0x80>>(bitno%8)))
//			set_bit_cds(n);
//	}
	ldi		R20,0x80
; 	for (n = 0; n < 56; n++)
	clr		R16
	ldi		r30, lo8(T7_1_2)	;Z
	ldi		r31, hi8(T7_1_2)	;Z
KeySchedule2:
;	{
;		unsigned char bitno;
;		bitno=pgm_read_byte_near(&T7_1_2[n]);		
	lpm		r24,Z+
;		if(Des_Key[bitno/8]&(0x80>>(bitno%8)))
	mov		R25,R24
	lsr		R24
	lsr		R24
	lsr		R24
	ldi		r26,lo8(Des_Key)	; X
	ldi		r27,hi8(Des_Key)	; X
	add		r26,r24
	adc		R27,R1
	ldi		R17,0x80
KeySchedule4:
	andi	R25,0x07
	breq	KeySchedule3
KeySchedule41:
	lsr		R17
	dec		R25
	brne	KeySchedule41
KeySchedule3:
	ld		R25,X
	and		R25,R17
	breq	KeySchedule5
;    Des_cds[n/8]|=(0x80>>(n%8));
	mov		R24,R16
	lsr		R24
	lsr		R24
	lsr		R24
	ldi		R26, lo8(Des_cds)	; X
	ldi		R27, hi8(Des_cds)	; X
	add		R26,R24
	adc		R27,R1
	ld		R18,X
	or		R18,R20
	st		X  ,R18
KeySchedule5:
	lsr		R20
	brcc	KeySchedule6
	ror		R20
KeySchedule6:
	inc		R16
	cpi		R16,56	; 56
	brcs	KeySchedule2
;	}
KeySchedule1:
;   unsigned char n;
;	mem_clr(Des_Kns,16*6);
	ldi		r22, 16*6
	ldi		r30, lo8(Des_Kns)
	ldi		r31, hi8(Des_Kns)
	rcall	mem_clr
;	for (n = 0; n < 16; n++)
	mov 	R19, r1
DesKeySch0:
;	if( n==1 || n==15 || n==0 || n==8 )
	cpi		R19,0x02
	brlo	DesKeySchA
	cpi		R19,0x08
	breq	DesKeySchA
	cpi		R19,0x0F
	breq	DesKeySchA
	rjmp	DesKeySch1
DesKeySchA:
;		{
;			if(Des_cds[0]&0x80)
	lds		r24, Des_cds
	and		r24, r24
	brge	DesKeySch2
;			{
;				drol_cds();
	rcall	drol_cds
;				Des_cds[3]|= 0x10;
	ori		r24, 0x10
	rjmp	DesKeySch3
;			}
;			else
DesKeySch2:
;			{
;				drol_cds();
	rcall	drol_cds
;				Des_cds[3]&=~(0x10);
	andi 	r24, 0xEF
	rjmp	DesKeySch3
;			}
;		}
;		else
;		{
DesKeySch1:
;			if(Des_cds[0]&0x80)
	lds		r24, Des_cds
	and		r24, r24
	brge	DesKeySch4
;			{
;				if(Des_cds[0]&0x40)
	lds		r24, Des_cds
	andi	r24,0x40
	breq	DesKeySch5
;				{
;				drol_cds();
	rcall	two_drol_cds
;				Des_cds[3]|= (0x30);
	ori		r24, 0x30
	rjmp	DesKeySch3
;				}
;				else
;				{
DesKeySch5:
	rcall	two_drol_cds
;				Des_cds[3]|= (0x20);
	ori		r24, 0x20
;				Des_cds[3]&=~(0x10);
	andi	r24, 0xEF
	rjmp	DesKeySch3
;				}
;			}
;			else
;			{
DesKeySch4:
;				if(Des_cds[0]&0x40)
	lds		r24, Des_cds
	andi	r24,0x40
	breq	DesKeySch6
;				{
	rcall	two_drol_cds
;				Des_cds[3]&=~(0x20);
	andi	r24, 0xDF	; 223
;				Des_cds[3]|= (0x10);
	ori		r24, 0x10
	rjmp	DesKeySch3
;				}
;				else
DesKeySch6:
;				{
	rcall	two_drol_cds
;				Des_cds[3]&=~(0x30);
	andi	r24, 0xCF
;				}
;			}
;		}
DesKeySch3:
	sts		Des_cds+3, r24
;		DesKeyT9(n);
	rcall	DesKeyT9
	inc		r19
	cpi		r19, 0x10
	brlo	DesKeySch0
DesKeySchb:
	pop		r29
	pop		r28
	pop		r17
	pop		r16
	ret

