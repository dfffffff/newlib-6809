;;;
;;; Copyright 2016 by David Flamand <dflamand@gmail.com>
;;;
;;; memset for m6809
;;;
;;;  support for -mdret
;;;  optimization: set 2 byte at a time
;;;
;;;  TODO: support stack only args
;;;

	.module memset.S
	.area .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; void *memset(void *s, int c, size_t n)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl _memset
_memset:
	pshs	y,x
	ldd	8,s
	beq	_l3
	leay	,x
	tfr	d,x
	lda	6+1,s
	bitb	#1
	beq	_l1
	sta	,y+
	leax	-1,x
	beq	_l3
_l1:	tfr	a,b
_l2:	std	,y++
	leax	-2,x
	bne	_l2
_l3:
#ifdef __DRET__
	puls	d,y,pc
#else
	puls	x,y,pc
#endif

