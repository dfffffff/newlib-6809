;;;
;;; Copyright 2006 by Brian Dominy <brian@oddchange.com>
;;;
;;; Changes by David Flamand <dflamand@gmail.com> (May 2016)
;;;  added support for -mdret and -mabi=stack
;;;  added check for zero in longjmp return value
;;;  reduced size of jmp_buf
;;;  some optimizations
;;;
;;; setjmp/longjmp for m6809
;;;

;;; TODO:
;;; - Support nonstandard compiler options
;;; - Support other state (i.e. HW registers for various platforms)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The jmp_buf is structured as follows:
;
; Offset       Value
; 0-1          Y
; 2-3          U
; 4-5          S
; 6-7          PC
; 8            DP
; 9            CC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SAVE_Y = 0
SAVE_U = 2
SAVE_S = 4
SAVE_PC = 6
SAVE_DP_CC = 8

SETJMP_S = 2

	.module	setjmp.S
	.area	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; int setjmp(jmp_buf env)
;
; A pointer to env is passed in register X.
; The return value is placed in X or D.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	_setjmp
_setjmp:
#ifdef __ABI_STACK__
	ldx	2,s           ; X = env
#endif
	pshs	u             ; Save nonvolatile U register
	sty	SAVE_Y,x      ; Save the Y register
	stu	SAVE_U,x      ; Save the U register
	leau	SETJMP_S+2,s
	stu	SAVE_S,x      ; Save the S register
	ldd	SETJMP_S,s
	std	SAVE_PC,x     ; Save the PC register
	tfr	dp,a
	tfr	cc,b
	std	SAVE_DP_CC,x  ; Save the DP/CC registers
#ifdef __DRET__
	clra                  ; Return zero in D
	clrb
#else
	ldx	#0            ; Return zero in X
#endif
	puls	u,pc          ; Restore U and PC registers (returning)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; void longjmp(jmp_buf env, int val)
;
; A pointer to env is passed in register X.
; val is placed on the stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	_longjmp
_longjmp:
#ifdef __ABI_STACK__
	ldx	2,s           ; X = env
	ldd	4,s           ; D = val
#else
	ldd	2,s           ; D = val
#endif
	bne	l1
	incb                  ; Zero is not allowed
l1:	lds	SAVE_S,x      ; Restore the S register
	ldu	SAVE_PC,x     ; Load the PC register
	pshs	u,d           ; Save PC and return value onto stack
	ldu	SAVE_U,x      ; Restore the U register
	ldy	SAVE_Y,x      ; Restore the Y register
	ldd	SAVE_DP_CC,x  ; Load the DP/CC registers
	tfr	a,dp          ; Restore the DP register
	tfr	b,cc          ; Restore the CC register
#ifdef __DRET__
	puls	d,pc          ; Restore D and PC registers (returning)
#else
	puls	x,pc          ; Restore X and PC registers (returning)
#endif
