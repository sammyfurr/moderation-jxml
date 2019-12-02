%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "json_xml.h"
int yylex (void);
void yyerror (char const *);

/* For printing json lists with the object names around them.  This
 could be dynamic, to allow as many nested lists as possible, but that
 isn't really the point of the program. */
#define MAX_LIST_DEPTH 1024
char* list_names[MAX_LIST_DEPTH];
char* list_name;
int list_depth;

/* We need a way to free the list names after we've copied them*/
n_collect_t* parse_top;
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
	|	error EOL
		{ yyerrok; }
	;

jlist:
		json
	|
		jlist
		{ printf("</%s>", list_names[list_depth]); }
		LS
		{ printf("<%s>", list_names[list_depth]); }
		json
		{ printf("</%s>", list_names[list_depth]); }
	;

jobjpair:
		JSTR
		{
		    if ((list_name = strdup($1)) == NULL){
			perror("Error determining potential list name");
			free_n_collect_list(parse_top);
			exit(EXIT_FAILURE);
		    }
		    add_n_collect(&parse_top, list_name);
		    list_name[strlen(list_name)-1] = '\0';
		    printf("<%s>", $1);
		}
		OS
		json
		{
		    printf("</%s>", $1);
		    free((void*)$1);
		}
	;

jobj:		jobjpair
	|	jobj LS jobjpair
	;

json:
		OL jobj OR
	|	LL
		{
		    list_depth++;
		    if(list_depth > MAX_LIST_DEPTH){
			printf("List depth exceeded\n");
			free_n_collect_list(parse_top);
			exit(EXIT_FAILURE);
		    }
		    list_names[list_depth] = list_name;
		    printf("<%s>", list_names[list_depth]);
		}
		jlist
		LR
		{
		    list_depth--;
		}
	|	NUM
		{ printf("%.10g", $1); }
	|	JSTR
		{
		    printf("%s", $1);
		    free((void*)$1);
		}
	|	TE
		{ printf("%s", $1); }
	|	FE
		{ printf("%s", $1); }
	|	NL
		{ printf("%s", $1); }
	;

%%
int main (void){
    parse_top = NULL;
    list_name = NULL;
    list_depth = -1;
    yyparse();
    free_n_collect_list(parse_top);
    exit(EXIT_SUCCESS);
}

void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}
