;;;
;;; Copyright 2016 by David Flamand <dflamand@gmail.com>
;;;
;;; memcpy for m6809
;;;
;;;  support for -mdret and -mabi=stack
;;;  optimization: copy 2 byte at a time
;;;

	.module	memcpy.S
	.area	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; void *memcpy(void *dest, const void *src, size_t n)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	_memcpy
_memcpy:
#ifdef __ABI_STACK__
	pshs	u,y
	ldd	10,s
	beq	l2
	ldu	8,s
	ldy	6,s
#else
	pshs	u,y,x
	ldd	10,s
	beq	l2
	ldu	8,s
	leay	,x
#endif
	tfr	d,x
	bitb	#1
	beq	l1
	ldb	,u+
	stb	,y+
	leax	-1,x
	beq	l2
l1:	ldd	,u++
	std	,y++
	leax	-2,x
	bne	l1
l2:
#ifdef __ABI_STACK__
#ifdef __DRET__
	ldd	6,s
#else
	ldx	6,s
#endif
	puls	y,u,pc
#else
#ifdef __DRET__
	puls	d,y,u,pc
#else
	puls	x,y,u,pc
#endif
#endif
