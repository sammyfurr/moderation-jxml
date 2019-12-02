%{
#include <stdio.h>
#include <stdlib.h>
int yylex (void);
void yyerror (char const *);
%}

%define api.value.type union
%token	<double>	NUM
%token	<char const *>  JSTR
%token	<char const *>	TE
%token	<char const *>	FE
%token	<char const *>	NL
%token			EOL
%token LL LR LS OL OR OS
%%

input:
		%empty
	|	input line
		;

line:
		EOL
		{ printf("\n"); }
	|	json EOL
		{ printf("\n"); }
	|	error EOL { yyerrok; }
	;

jlist:
		json
	|	jlist LS
		{ printf(","); }
		json
	;

jobjpair:
		JSTR
		{ printf("%s", $1); }
		OS
		{ printf(":"); }
		json
		{ free ((void*)$1); }
	;

jobj:		jobjpair
	|	jobj LS
		{ printf(","); }
		jobjpair
	;

json:
		OL
		{ printf("{"); }
		jobj OR
		{ printf("}"); }
	|	LL
		{ printf("["); }
		jlist LR
		{ printf("]"); }
	|	NUM
		{ printf("%.10g", $1); }
	|	JSTR
		{ printf("%s", $1); free ((void*)$1); }
	|	TE
		{ printf("%s", $1); }
	|	FE
		{ printf("%s", $1); }
	|	NL
		{ printf("%s", $1); }
	;

%%
	int main (void){
	    yyparse();
	    exit(EXIT_SUCCESS);
	}

void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}
