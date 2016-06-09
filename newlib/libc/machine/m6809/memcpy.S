;;;
;;; Copyright 2016 by David Flamand <dflamand@gmail.com>
;;;
;;; memcpy for m6809
;;;
;;;  support for -mdret
;;;  optimization: copy 2 byte at a time
;;;
;;;  TODO: support stack only args
;;;

	.module memcpy.S
	.area .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; void *memcpy(void *dest, const void *src, size_t n)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl _memcpy
_memcpy:
	pshs	u,y,x
	ldd	10,s
	beq	_l2
	leay	,x
	tfr	d,x
	ldu	8,s
	bitb	#1
	beq	_l1
	ldb	,u+
	stb	,y+
	leax	-1,x
	beq	_l2
_l1:	ldd	,u++
	std	,y++
	leax	-2,x
	bne	_l1
_l2:
#ifdef __DRET__
	puls	d,y,u,pc
#else
	puls	x,y,u,pc
#endif

