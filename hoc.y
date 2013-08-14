%{
#include <stdio.h>
#include "hoc.h"
#define code2(c1,c2)	code(c1); code(c2)
#define code3(c1,c2,c3)	code(c1); code(c2); code(c3)
%}
%union {		/* stack type */
	Symbol	*sym;	/* symbol table pointer */
	Inst	*inst;	/* machine instruction */
}
%token	<sym>	NUMBER VAR BLTIN UNDEF
%right	'='
%left	'+' '-'		/* left associative, same precedence */
%left	'*' '/'		/* left associative, higher precedence */
%left	UNARYPLUS UNARYMINUS	/* unary plus and minus */
%right	'^'		/* exponentiation */
%%
list:	/* nothing */
	| list '\n'
	| list asgn '\n'	{ code2(pop, STOP); return 1; }
	| list expr '\n'	{ code2(print, STOP); return 1; }
	| list error '\n'	{ yyerrok; }
	;
asgn:	VAR '=' expr	{ code3(varpush, (Inst)$1, assign); }
	;
expr:	NUMBER		{ code2(constpush, (Inst)$1); }
	| VAR		{ code3(varpush, (Inst)$1, eval); }
	| asgn
	| BLTIN '(' expr ')'	{ code2(bltin, (Inst)$1->u.ptr); }
	| '(' expr ')'
	| expr '+' expr	{ code(add); }
	| expr '-' expr	{ code(sub); }
	| expr '*' expr	{ code(mul); }
	| expr '/' expr	{ code(div); }
	| expr '^' expr	{ code(power); }
	| '+' expr %prec UNARYPLUS	{ code(positive); }
	| '-' expr %prec UNARYMINUS	{ code(negate); }
	;
%%
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>
char	*progname;	/* for error messages */
int	lineno = 1;
jmp_buf	begin;

main(int argc, char *argv[])	/* hoc4 */
{
	progname = argv[0];
	init();
	setjmp(begin);
	for (initcode(); yyparse(); initcode())
		execute(prog);
	return 0;
}

execerror(char *s, char *t)	/* recover from run-time error */
{
	warning(s, t);
	longjmp(begin, 0);
}

yylex()		/* hoc4 */
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* number */
		double d;
		ungetc(c, stdin);
		scanf("%lf", &d);
		yylval.sym = install("", NUMBER, d);
		return NUMBER;
	}
	if (isalpha(c)) {
		Symbol	*s;
		char	sbuf[100], *p = sbuf;
		do {
			*p++ = c;
		} while ((c = getchar()) != EOF && isalnum(c));
		ungetc(c, stdin);
		*p = '\0';
		if ((s=lookup(sbuf)) == 0)
			s = install(sbuf, UNDEF, 0.0);
		yylval.sym = s;
		return s->type == UNDEF ? VAR : s->type;
	}
	if (c == '\n')
		lineno++;
	return c;
}

yyerror(char *s)	/* called for yacc syntax error */
{
	warning(s, (char *) 0);
}

warning(char *s, char *t)	/* print warning message */
{
	fprintf(stderr, "%s: %s", progname, s);
	if(t)
		fprintf(stderr, " %s", t);
	fprintf(stderr, " near line %d\n", lineno);
}
