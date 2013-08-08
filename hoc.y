%{
double mem[26];
%}
%union {		/* stack type */
	double	val;	/* actual value */
	int	index;	/* index into mem[] */
}
%token	<val>	NUMBER
%token	<index>	VAR
%type	<val>	expr
%right	'='
%left	'+' '-'	/* left associative, same precedence */
%left	'*' '/'	/* let associative, higher precedence */
%left	UNARYPLUS UNARYMINUS	/* unary plus and minus */
%%
list:	/* nothing */
	| list '\n'
	| list expr '\n'	{ printf("\t%.8g\n", $2); }
	| list error '\n'	{ yyerrok; }
	;
expr:	NUMBER		{ $$ = $1; }
	| VAR		{ $$ = mem[$1]; }
	| VAR '=' expr	{ $$ = mem[$1] = $3; }
	| '+' expr %prec UNARYPLUS	{ $$ = $2; }
	| '-' expr %prec UNARYMINUS	{ $$ = -$2; }
	| expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '*' expr	{ $$ = $1 * $3; }
	| expr '/' expr	{ $$ = $1 / $3; }
	| '(' expr ')'	{ $$ = $2; }
	;
%%
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
char	*progname;	/* for error messages */
int	lineno = 1;

main(int argc, char *argv[])	/* hoc2 */
{
	progname = argv[0];
	yyparse();
}

yylex()		/* hoc2 */
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* number */
		ungetc(c, stdin);
		scanf("%lf", &yylval.val);
		return NUMBER;
	}
	if (islower(c)) {
		yylval.index = c - 'a';	/* ASCII only */
		return VAR;
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
