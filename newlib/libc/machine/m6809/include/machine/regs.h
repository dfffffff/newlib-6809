#ifndef __M6809_REGS_H
#define __M6809_REGS_H

#ifdef __NO_INLINE__
#define ASM_DECL static
#else
#define ASM_DECL extern inline
#endif


enum cc_flags
{
	CC_CARRY = 0x1,
	CC_OVERFLOW = 0x2,
	CC_ZERO = 0x4,
	CC_NEGATIVE = 0x8,
	CC_IRQ = 0x10,
	CC_HALF = 0x20,
	CC_FIRQ = 0x40,
	CC_E = 0x80,
};

/* for bit testing CC reg */
register const volatile unsigned char __cc asm ("cc");


/*
	WARNING: setstack() and getstack() must be used with precaution.
	Only one local variable is allowed, they must be used with
	function without or with one parameter,
	also beware of function inlining and tail call optimization.

	please consider this valid use case:

	int add3 (int param1, int param2, int param3)
	{
		int result;
		result = param1 + param2 + param3;
		return result;
	}

	// make sure no inlining occur, can have one parameter
	__attribute__((noinline)) void dosomework (int value)
	{
		// no restriction here
		int result;
		result = add3(value, 2, 3);
		printf("%s=%d\n", "result", result);
	}

	// make sure no inlining occur, no parameter
	__attribute__((noinline)) void func (void)
	{
		int oldstack;          // ok for one local variable
		oldstack = getstack();
		setstack(0xC000);
		dosomework(1);         // ok for one parameter function call
		setstack(oldstack);
		__builtin_blockage();  // prevent tail call optimization on setstack
	}

	int main (...)
	{
		...
		func();
		...
		return ...;
	}
*/

#ifdef __NO_INLINE__
ASM_DECL __attribute__((naked)) void setstack (const unsigned int s)
{
#if defined(__ABI_STACK__)
#error setstack() unsupported at (__NO_INLINE__ && __ABI_STACK__)
	/*asm volatile ("puls\td,x\n\tleas\t-2,x\n\ttfr\td,pc");*/
#elif defined(__ABI_BX__) || defined(__ABI_REGS__)
	asm volatile ("puls\td\n\tleas\t,x\n\ttfr\td,pc");
#else
#error UNKNOWN ABI
#endif
}
#else
ASM_DECL void setstack (const unsigned int s)
{
	asm volatile ("leas\t,%0" :: "a" (s));
}
#endif


#ifdef __NO_INLINE__
ASM_DECL __attribute__((naked)) unsigned int getstack (void)
{
#ifdef __DRET__
	asm volatile ("leax\t2,s\n\ttfr\tx,d\n\trts");
#else
	asm volatile ("leax\t2,s\n\trts");
#endif
}
#else
ASM_DECL unsigned int getstack (void)
{
	unsigned int result;
	asm volatile ("lea%0\t,s" : "=a" (result));
	return result;
}
#endif


ASM_DECL void setdp (const unsigned char dp)
{
	asm volatile ("tfr\t%0,dp" :: "q" (dp));
}


ASM_DECL unsigned char getdp (void)
{
	unsigned char result;
	asm volatile ("tfr\tdp,%0" : "=q" (result));
	return result;
}


#undef ASM_DECL

#endif /* __M6809_REGS_H */
