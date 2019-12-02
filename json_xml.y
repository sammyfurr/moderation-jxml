%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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
typedef struct n_collect{
    char *n;
    struct n_collect* previous;
} n_collect_t;
n_collect_t* n_collect_top;
void add_n_collect(char* n);
void free_n_collect(n_collect_t * nc);
void free_n_collect_list();
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
		    list_name = strdup($1);
		    add_n_collect(list_name);
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
			exit(EXIT_FAILURE);
		    }
		    list_names[list_depth] = list_name;
		    printf("<%s>", list_names[list_depth]);
		}
		jlist
		LR
		{
		    //		    free((void*)list_names[list_depth]);
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
    n_collect_top = NULL;
    list_name = NULL;
    list_depth = -1;
    yyparse();
    free_n_collect_list();
    exit(EXIT_SUCCESS);
}

void add_n_collect(char *n){
    n_collect_t* nc;
    if((nc = malloc(sizeof(n_collect_t))) == NULL){
	perror("Error parsing list");
	exit(EXIT_FAILURE);
    }
    nc->n = n;
    nc->previous = n_collect_top;
    n_collect_top = nc;
}

void free_n_collect(n_collect_t * nc){
    free((void *)nc->n);
    free((void *)nc);
}

void free_n_collect_list(){
    n_collect_t* nc = n_collect_top;
    while(n_collect_top != NULL){
	nc = n_collect_top->previous;
	free_n_collect(n_collect_top);
	n_collect_top = nc;
    }
}

void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}
