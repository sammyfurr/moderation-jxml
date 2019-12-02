%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "json_xml.h"
int yylex (void);
void yyerror (char const *);

/* For printing json lists in xml with the object names around them.
 This could be dynamic, to allow as many nested lists as possible, but
 that isn't really the point of the program. */
#define MAX_LIST_DEPTH 1024
char* list_names[MAX_LIST_DEPTH];
char* list_name;
int list_depth;

/* Tracks names for garbage collection, using functions declared in
 json_xml.h */
n_collect_t* parse_top;

%}

/* The value of our tokens can be either a char const * or a
 double. */
			
/* Tokens are:	
 NUM = json number
 JSTR = json string
 TE = true
 FE = false
 NL = null
 EOL = end of line (\n not in quotes)
 LL LR LS = [ , ]
 OL OR OS = { : } */
			
%define api.value.type union
%token	<double>	NUM
%token	<char const *>  JSTR
%token	<char const *>	TE
%token	<char const *>	FE
%token	<char const *>	NL
%token			EOL
%token LL LR LS OL OR OS
			
%% /* Begin Grammar Rules! */

/* This creates a REPL-like loop due to the left-recursion of input
 line.  The program reads a line of input at a time until EOF is
 read. */
input:
		%empty
	|	input line
		;

/* A line can be just \n, some JSON followed by \n, or an error (bad
 json).  If this wasn't a REPL we would want to recover so nicely from
 bad JSON. */
line:
		EOL
		{ printf("\n"); }
	|	json EOL
		{ printf("\n"); }
	|	error EOL
		{ yyerrok; }
	;

/* A json list is json , json , json ...  */
jlist:
		json
	|
		jlist
		{
		    /* In XML, lists print like so:
		       <names>
		        <name>Sammy</name>
			<name>Kieth</name>
		       </names>
		     This tracking prints lists correctly. */
		    printf("</%s>", list_names[list_depth]);
		}
		LS
		{ printf("<%s>", list_names[list_depth]); }
		json
		{ printf("</%s>", list_names[list_depth]); }
	;

/* A jobjpair is json : json. */
jobjpair:
		JSTR
		{
		    /* Since we will potentially need to use the name
		       of this object to print our list later, add it
		       to the garbage collection list. */
		    if ((list_name = strdup($1)) == NULL){
			perror("Error determining potential list name");
			free_n_collect_list(parse_top);
			exit(EXIT_FAILURE);
		    }
		    add_n_collect(&parse_top, list_name);
		    /* Store the name of the object minus the s at the
		       end in list_name. */
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

/* A json object is jobjpair , jobjpair , jobjpair ...  */
jobj:		jobjpair
	|	jobj LS jobjpair
	;

json:
		/* json object is { jobj }  */
		OL jobj OR
		/* json list is [ jlist ]  */
	|	LL
		{
		    /* Push the name of our list to our stack of list
		       names. */
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
		    /* Pop current list name off the stack. */
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
