;;;
;;; Copyright 2016 by David Flamand <dflamand@gmail.com>
;;;
;;; memset for m6809
;;;
;;;  support for -mdret and -mabi=stack
;;;  optimization: set 2 byte at a time
;;;

	.module	memset.S
	.area	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; void *memset(void *s, int c, size_t n)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	_memset
_memset:
#ifdef __ABI_STACK__
	pshs	u
	ldd	8,s
	beq	l3
	ldu	4,s
#else
	pshs	u,x
	ldd	8,s
	beq	l3
	leau	,x
#endif
	tfr	d,x
	lda	6+1,s
	bitb	#1
	beq	l1
	sta	,u+
	leax	-1,x
	beq	l3
l1:	tfr	a,b
l2:	std	,u++
	leax	-2,x
	bne	l2
l3:
#ifdef __ABI_STACK__
#ifdef __DRET__
	ldd	4,s
#else
	ldx	4,s
#endif
	puls	u,pc
#else
#ifdef __DRET__
	puls	d,u,pc
#else
	puls	x,u,pc
#endif
#endif
