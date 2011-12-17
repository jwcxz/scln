/* Copyright (c) 2002, 
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
   * Neither the name of the copyright holders nor the names of
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

/* $Id$ */

#include "macros.inc"

#define dest_hi r25
#define dest_lo r24
#define src_hi r23
#define src_lo r22
#define len_hi r21
#define len_lo r20

/** \ingroup avr_string
    \fn void *memeor(void *dest, const void *src, size_t len)
    \brief Copy a memory area.

    The memeor() function copies len bytes from memory area src to memory area
    dest.  The memory areas may not overlap.  

    \returns The memeor() function returns a pointer to dest.  */

#if !defined(__DOXYGEN__)

	.text
	.global	_U(memeor)
	.type	_U(memeor), @function
_U(memeor):
	push 	R16
	X_movw	ZL, src_lo
	X_movw	XL, dest_lo
#if OPTIMIZE_SPEED
;
	sbrs	len_lo, 0
	rjmp	.L_memeor_start
	rjmp	.L_memeor_odd
.L_memeor_loop:
	ld	__tmp_reg__, Z
	ld	R16,X+
	eor 	__tmp_reg__, R16 
	st	Z+,R16
.L_memeor_odd:
	ld	__tmp_reg__, Z
	ld	R16,X+
	eor 	__tmp_reg__, R16 
	st	Z+,R16
.L_memeor_start:
	subi	len_lo, lo8(2)
	sbci	len_hi, hi8(2)
#else
; 
	rjmp	.L_memeor_start
.L_memeor_loop:
	ld	__tmp_reg__, Z
	ld	R16,X+
	eor 	__tmp_reg__, R16 
	st	Z+,R16
.L_memeor_start:
	subi	len_lo, lo8(1)
	sbci	len_hi, hi8(1)
#endif
	brcc	.L_memeor_loop
; return dest (unchanged)
	pop	r16
	ret
.L_memeor_end:
	.size	_U(memeor), .L_memeor_end - _U(memeor)

#endif /* not __DOXYGEN__ */
