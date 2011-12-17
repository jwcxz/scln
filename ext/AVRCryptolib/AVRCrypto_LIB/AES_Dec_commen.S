; This is part of the AES
; by Emile van der Laan
; www.emsign.nl

	.text			; switches to the .text section (code and ROM constants)
	.global	AES_InvMixColumns
	.global	AES_InvShiftRows


AES_InvMixColumn_Regs:
;	r16 = (r16 << 1) ^ (r16 & 0x80 ? BPOLY : 0);
	lsl r16
	brcc AES_InvMixColumn1
	eor r16,r14
AES_InvMixColumn1:	
; 	r17 = (r17 << 1) ^ (r17 & 0x80 ? BPOLY : 0);
	lsl r17
	brcc AES_InvMixColumn2
	eor r17,r14
AES_InvMixColumn2:	
;   r18 = (r18 << 1) ^ (r18 & 0x80 ? BPOLY : 0);
	lsl r18
	brcc AES_InvMixColumn3
	eor r18,r14
AES_InvMixColumn3:	
;  	r19 = (r19 << 1) ^ (r19 & 0x80 ? BPOLY : 0);
	lsl r19
	brcc AES_InvMixColumn4
	eor r19,r14
AES_InvMixColumn4:	
	ret

;void AES_InvMixColumn( unsigned char * column )
;{
; * column   = R25/R24 (Hi/low)
AES_InvMixColumn:
;	unsigned char r16, r17, r18, r19;
;	unsigned char r20, r21, r22, r23;
	movw	r30,r26
;	r16 = column[0];
	ld	r16,x+
;	r17 = column[1];
	ld	r17,x+
;	r18 = column[2];
	ld	r18,x+
;	r19 = column[3];
	ld	r19,x+
;	r20 = r17 ^ r18 ^ r19;
	mov r20,r17
	eor	r20,r18
	eor r20,r19
;	r21 = r16 ^ r18 ^ r19;
	mov r21,r16
	eor r21,r18
	eor r21,r19
;	r22 = r16 ^ r17 ^ r19;
	mov r22,r16
	eor r22,r17
	eor r22,r19
;	r23 = r16 ^ r17 ^ r18;
	mov r23,r16
	eor	r23,r17
	eor r23,r18
	rcall AES_InvMixColumn_Regs
;	r20 ^= r16 ^ r17;
	eor	r20,r16
	eor r20,r17
;	r21 ^= r17 ^ r18;
	eor r21,r17
	eor r21,r18
;	r22 ^= r18 ^ r19;
	eor r22,r18
	eor r22,r19
;	r23 ^= r16 ^ r19;
	eor	r23,r16
	eor r23,r19
	rcall AES_InvMixColumn_Regs
;	r20 ^= r16 ^ r18;
	eor	r20,r16
	eor r20,r18
;	r21 ^= r17 ^ r19;
	eor r21,r17
	eor r21,r19
;	r22 ^= r16 ^ r18;
	eor r22,r16
	eor r22,r18
;	r23 ^= r17 ^ r19;
	eor	r23,r17
	eor r23,r19
	rcall AES_InvMixColumn_Regs

;	r16 ^= r17 ^ r18 ^ r19;
	eor r16,r17
	eor r16,r18
	eor r16,r19
;	r20 ^= r16;
	eor r20,r16
;	r21 ^= r16;
	eor r21,r16
;	r22 ^= r16;
	eor r22,r16
;	r23 ^= r16;
	eor r23,r16
	movw	r26,r30
;	column[0] = r20;
	st	x+,20
;	column[1] = r21;
	st	x+,21
;	column[2] = r22;
	st	x+,22
;	column[3] = r23;
	st	x+,23
	ret
;}

;void AES_InvMixColumns( unsigned char * state )
;{
AES_InvMixColumns:
	push	r14
	ldi r20,0x1B
	mov r14,r20
	movw	r26,r24
;	AES_InvMixColumn( state + 0*4 );
	rcall	AES_InvMixColumn
;	AES_InvMixColumn( state + 1*4 );
	rcall	AES_InvMixColumn
;	AES_InvMixColumn( state + 2*4 );
	rcall	AES_InvMixColumn
;	AES_InvMixColumn( state + 3*4 );
	rcall	AES_InvMixColumn
	pop 	r14
	ret
;}

;void AES_InvShiftRows( unsigned char * state )
;{
;	unsigned char temp;
AES_InvShiftRows:
;	// Note: State is arranged column by column.
	movw	r26,r24
	movw	r30,r24
;	// Cycle second row right one time.
;	temp = state[ 1 + 3*4 ];
	adiw	r30,13	;(0+13)=Z 13
	ld		r15,z
;	state[ 1 + 3*4 ] = state[ 1 + 2*4 ];
	adiw	r26,9	;(+9)= X 9
	ld		r16,x
	st		z,r16;
;	state[ 1 + 2*4 ] = state[ 1 + 1*4 ];
	sbiw	r30,8	;(13-8) = Z 5
	ld		r16,z
	st		x,r16
;	state[ 1 + 1*4 ] = state[ 1 + 0*4 ];
	sbiw	r26,8	; 9-8=X 1
	ld		r16,x
	st		z,r16
;	state[ 1 + 0*4 ] = temp;
	st		x+,r15	; 1+1 =X 2
;	// Cycle third row right two times.
;	temp = state[ 2 + 0*4 ];
	ld		r15,x
;	state[ 2 + 0*4 ] = state[ 2 + 2*4 ];
	adiw	r30,5	; 5 + 5 = Z 10
	ld		r16,z
	st		x,r16
;	state[ 2 + 2*4 ] = temp;
	st		z,r15

;	temp = state[ 2 + 1*4 ];
	sbiw	r30,4	;10-4 = Z 6
	ld		r15,z
;	state[ 2 + 1*4 ] = state[ 2 + 3*4 ];
	adiw	r26,12	; 2 + 12 = X 14
	ld		r16,x
	st		z+,r16	;6+1 =Z 7
;	state[ 2 + 3*4 ] = temp;
	st		x,r15
;	// Cycle fourth row right three times, ie. left once.
;	temp = state[ 3 + 0*4 ];
	sbiw	r26,11	; 14-11=X 3
	ld		r15,x
;	state[ 3 + 0*4 ] = state[ 3 + 1*4 ];
	ld		r16,z	
	st		x,r16
;	state[ 3 + 1*4 ] = state[ 3 + 2*4 ];
	adiw	r26,8	; 3+8 = X 11
	ld		r16,x
	st		z,r16
;	state[ 3 + 2*4 ] = state[ 3 + 3*4 ];
	adiw	r30,8	; 7+8= Z 15
	ld		r16,z
	st		x,r16
;	state[ 3 + 3*4 ] = temp;
	st		z,r15
	ret
;}

