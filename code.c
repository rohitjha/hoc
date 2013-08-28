#include <stdio.h>
#include "hoc.h"
#include "y.tab.h"

#define	NSTACK	256
static	Datum	stack[NSTACK];	/* the stack */
static	Datum	*stackp;	/* next free spot on stack */

#define	NPROG	2000
Inst	prog[NPROG];	/* the machine */
Inst	*progp;		/* next free spot for code generation */
Inst	*pc;		/* program counter during execution */

initcode()		/* initialize for code generation */
{
	//printf("initcode\n");
	stackp = stack;
	progp = prog;
}

push(Datum d)		/* push d onto stack */
{
	//printf("push\n");
	if (stackp >= &stack[NSTACK])
		execerror("stack overflow", (char *) 0);
	*stackp++ = d;
}

Datum pop()		/* pop and return top elem from stack */
{
	//printf("pop\n");
	if (stackp <= stack)
		execerror("stack underflow", (char *) 0);
	return *--stackp;
}

Inst *code(Inst f)	/* install one instruction or operand */
{
	Inst	*oprogp = progp;
	if (progp >= &prog[NPROG])
		execerror("program too big", (char *) 0);
	*progp++ = f;
	return oprogp;
}

execute(Inst *p)	/* run the machine */
{
	for (pc = p; *pc != STOP; )
		(*(*pc++))();
	//printf("execute\n");
}

constpush()		/* push constant onto stack */
{
	Datum	d;
	d.val = ((Symbol *)*pc++)->u.val;
	push(d);
	//printf("constpush\n");
}

varpush()		/* push variable onto stack */
{
	Datum	d;
	d.sym = (Symbol *)(*pc++);
	push(d);
	//printf("varpush\n");
}

add()		/* add top two elems on stack */
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val += d2.val;
	push(d1);
	//printf("add\n");
}

sub()		/* subtract top two elems on stack */
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val -= d2.val;
	push(d1);
	//printf("subtract\n");
}

mul()		/* multiply top two elems on stack */
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val *= d2.val;
	push(d1);
	//printf("multiply\n");
}

div()		/* divide top two elems on stack */
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val /= d2.val;
	push(d1);
	//printf("divide\n");
}

power()		/* exponentiation operation on top two elems */
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val = Pow(d1, d2);
	push(d1);
	//printf("exponentiation\n");
}

negate()	/* negation of topmost elem */
{
	Datum	d;
	d = pop();
	d.val = (-1) * d.val;
	push(d);
	//printf("negation\n");
}

positive()
{
	/* equivalent to a pop() and push() */
	//printf("positive\n");
}

eval()		/* evaluate variable on stack */
{
	Datum	d;
	d = pop();
	if (d.sym->type == UNDEF)
		execerror("undefined variable", d.sym->name);
	d.val = d.sym->u.val;
	push(d);
	//printf("eval\n");
}

assign()	/* assign top value to next value */
{
	Datum	d1, d2;
	d1 = pop();
	d2 = pop();
	if (d1.sym->type != VAR && d1.sym->type != UNDEF)
		execerror("assignment to non-variable", d1.sym->name);
	d1.sym->u.val = d2.val;
	d1.sym->type = VAR;
	push(d2);
	//printf("assign\n");
}

print()		/* pop top value from stack, print it */
{
	//printf("print\n");
	Datum	d;
	d = pop();
	printf("\t%.8g\n", d.val);
}

bltin()		/* evaluate built-in on top of stack */
{
	Datum	d;
	d = pop();
	d.val = (*(double (*) ())(*pc++))(d.val);
	push(d);
	//printf("built-in\n");
}

gt()
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val = (double)(d1.val > d2.val);
	push(d1);
}

lt()
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val = (double)(d1.val < d2.val);
	push(d1);
}

eq()
{
        Datum   d1, d2;
        d2 = pop();
        d1 = pop();
        d1.val = (double)(d1.val == d2.val);
        push(d1);
}

ge()
{
        Datum   d1, d2;
        d2 = pop();
        d1 = pop();
        d1.val = (double)(d1.val >= d2.val);
        push(d1);
}

le()
{
	Datum	d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val = (double)(d1.val <= d2.val);
	push(d1);
}

ne()
{
        Datum   d1, d2;
        d2 = pop();
        d1 = pop();
        d1.val = (double)(d1.val != d2.val);
        push(d1);
}

and()
{
        Datum   d1, d2;
        d2 = pop();
        d1 = pop();
        d1.val = (double)(d1.val && d2.val);
        push(d1);
}

or()
{
        Datum   d1, d2;
        d2 = pop();
        d1 = pop();
        d1.val = (double)(d1.val || d2.val);
        push(d1);
}

not()
{
        Datum   d;
        d = pop();
        d.val = (double)(!d.val);
        push(d);
}

whilecode()
{
	Datum	d;
	Inst	*savepc = pc;	/* loop body */

	execute(savepc+2);	/* condition */
	d = pop();
	while(d.val) {
		execute(*((Inst **)(savepc)));	/* body */
		execute(savepc+2);
		d = pop();
	}
	pc = *((Inst **)(savepc+1));	/* next statement */
}

ifcode()
{
	Datum	d;
	Inst	*savepc = pc;	/* then part */

	execute(savepc+3);	/* condition */
	d = pop();
	if(d.val)
		execute(*((Inst **)(savepc)));
	else if (*((Inst **)(savepc+1)))	/* else part? */
		execute(*((Inst **)(savepc+1)));
	pc = *((Inst **)(savepc+2));	/* next stmt */
}

prexpr()	/* print numeric value */
{
	Datum	d;
	d = pop();
	printf("%.8g\n", d.val);
}
