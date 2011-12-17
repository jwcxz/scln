; This is part of the AES
; by Emile van der Laan
; www.emsign.nl



	.text			; switches to the .text section (code and ROM constants)
	.global	AES_Multiply
	.global	AES_DotProduct
	.global	AES_MixColumn
	.global	AES_MixColumns
	.global	AES_ShiftRows

; void AES_MixColumn( unsigned char  * column ) 
AES_MixColumn:
;{ 
;  unsigned char  result0=r16, result1=r17, result2=r18, result3=r19; 
;  unsigned char  column0=r20, column1=r21, column2=r22, column3=r23; 
;  column0 = column[0]; 
	ld	r20,x+
;  column1 = column[1]; 
	ld	r21,x+
;  column2 = column[2]; 
	ld	r22,x+    
;  column3 = column[3]; 
	ld	r23,x+

  // Partial sums (modular addition using XOR). 
;  result0 = column1 ^ column2 ^ column3; 
	mov		r16,r21
	eor		r16,r22
	eor		r16,r23
;  result1 = column0 ^ column2 ^ column3; 
	mov		r17,r20
	eor		r17,r22
	eor		r17,r23
;  result2 = column0 ^ column1 ^ column3; 
	mov		r18,r20
	eor		r18,r21
	eor		r18,r23
;  result3 = column0 ^ column1 ^ column2; 
	mov		r19,r20
	eor		r19,r21
	eor		r19,r22

	ldi	r25, 0x1B	; 27
;  if( column0 & 0x80 ) {     
	lsl r20
	brcc MixColumn0
;    column0 = (column0 << 1) ^ BPOLY; 
	eor r20,r25
MixColumn0:

;  if( column1 & 0x80 ) { 
	lsl r21
	brcc MixColumn1
;    column1 = (column1 << 1) ^ BPOLY; 
	eor r21,r25
MixColumn1:    

;  if( column2 & 0x80 ) {     
	lsl r22
	brcc MixColumn2
;    column2 = (column2 << 1) ^ BPOLY; 
	eor r22,r25
MixColumn2:    
;  if( column3 & 0x80 ) {     
	lsl r23
	brcc MixColumn3
;    column3 = (column3 << 1) ^ BPOLY; 
	eor r23,r25
MixColumn3:    

	sbiw r26,4
; // Final sums stored into original column bytes. 
;  column[0] = result0 ^ column0 ^ column1; 
	mov	r24,r16
	eor	r24,r20
	eor r24,r21
    st	x+, r24
;  column[1] = result1 ^ column1 ^ column2; 
	mov	r24,r17
	eor	r24,r21
	eor r24,r22
    st	x+, r24

;  column[2] = result2 ^ column2 ^ column3; 
	mov	r24,r18
	eor	r24,r22
	eor r24,r23
    st	x+, r24
;  column[3] = result3 ^ column0 ^ column3; 
	mov	r24,r19
	eor	r24,r20
	eor r24,r23
    st	x+, r24
    ret

;void AES_MixColumns( unsigned char * state )
;{
; * state   = R25/R24 (Hi/low)
AES_MixColumns:
	movw	r26,R24
    call	AES_MixColumn 
    call	AES_MixColumn 
    call	AES_MixColumn 
    call	AES_MixColumn 
	ret

;void AES_ShiftRows( unsigned char * state )
;{
; * state   = R25/R24 (Hi/low)
AES_ShiftRows:
;	unsigned char temp;
	// Note: State is arranged column by column.
	movw	r30,r24
	ld		r20,z+			; add one
	// Cycle second row left one time.
	movw	r26,r30
;	temp = state[ 1 + 0*4 ];
	ld		r21,z
;	state[ 1 + 0*4 ] = state[ 1 + 1*4 ];
	adiw	R30,4
	ld		r20,z
	st		x,r20
;	state[ 1 + 1*4 ] = state[ 1 + 2*4 ];
	adiw	R30,4
	adiw 	R26,4
	ld		r20,z
	st		x,r20
;	state[ 1 + 2*4 ] = state[ 1 + 3*4 ];
	adiw	R30,4
	adiw 	R26,4
	ld		r20,z
	st		x,r20
;	state[ 1 + 3*4 ] = temp;
	adiw 	R26,4
	st		x,r21
	// Cycle third row left two times.
;	temp = state[ 2 + 0*4 ];
	movw	r30,r24
	adiw 	R30,2
	ld		r21,z
;	state[ 2 + 0*4 ] = state[ 2 + 2*4 ];
	movw	r26,r30
	adiw	r30,8
	ld		r20,z
	st		x,R20	
;	state[ 2 + 2*4 ] = temp;
	st		z,r21
;	temp = state[ 2 + 1*4 ];
	movw	r30,r24
	adiw 	R30,(2 + 1*4)
	ld		r21,z
;	state[ 2 + 1*4 ] = state[ 2 + 3*4 ];
	movw	r26,r24
	adiw	r26,(2 + 3*4)
	ld		r20,x
	st		z,r20
;	state[ 2 + 3*4 ] = temp;
	st		x,r21
;	// Cycle fourth row left three times, ie. right once.
;	temp = state[ 3 + 3*4 ];
	movw	r30,r24
	adiw	r30,(3 + 3*4)
	ld		r21,z
;	state[ 3 + 3*4 ] = state[ 3 + 2*4 ];
	movw	r26,r24
	adiw	r26,(3 + 2*4)
	ld		r20,x
	st		z,r20
;	state[ 3 + 2*4 ] = state[ 3 + 1*4 ];
	sbiw	R30,4
	sbiw	r26,4
	ld		r20,x
	st		z,r20
;	state[ 3 + 1*4 ] = state[ 3 + 0*4 ];
	sbiw	R30,4
	sbiw	r26,4
	ld		r20,x
	st		z,r20
;	state[ 3 + 0*4 ] = temp;
	st		x,r21
	ret
