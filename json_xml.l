%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "json_xml.tab.h"
#include "json_xml.h"
#define MAX_STR_CONST 1024
/* Check if we've overflowed our string buffer. */
void buf_check(char* b, char* p);
/* Tracks names for garbage collection, using functions declared in
 json_xml.h */
n_const_collect_t* lex_top;

%}
			
%x str
			
%%
         char string_buf[MAX_STR_CONST];
         char *string_buf_ptr;

\"       { /* Quotes begin jstrings.  We're cheating a bit here by not
              adding the quotes to the string in our output.  This is
              because it's far more annoying to strip them out later
              when we convert to XML. */
           string_buf_ptr = string_buf;
           buf_check(string_buf, string_buf_ptr);
           BEGIN(str);
         }

<str>\"  { /* Closing quote ends jstring. */
           BEGIN(INITIAL);
           *string_buf_ptr = '\0';
           buf_check(string_buf, string_buf_ptr);
           if((yylval.JSTR = strdup(string_buf)) == NULL){
             perror("Error parsing string");
             free_n_const_collect_list(lex_top);
             exit(EXIT_FAILURE);
           }
	   add_n_const_collect(&lex_top, yylval.JSTR);
           return JSTR;
         }

<str>\\\" { /* These blocks parse escaped chars.  */
           *string_buf_ptr++ = '\"';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\\\ {
           *string_buf_ptr++ = '\\';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\"/" {
           *string_buf_ptr++ = '/';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\b {
           *string_buf_ptr++ = '\b';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\f {
           *string_buf_ptr++ = '\f';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\n {
           *string_buf_ptr++ = '\n';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\r {
           *string_buf_ptr++ = '\r';
           buf_check(string_buf, string_buf_ptr);
         }
<str>\\t {
           *string_buf_ptr++ = '\t';
           buf_check(string_buf, string_buf_ptr);
         }

<str>[^\\\n\"]+ { /* Any character but \, newline, or "*/
           char *yptr = yytext;
           while (*yptr){
             *string_buf_ptr++ = *yptr++;
	     buf_check(string_buf, string_buf_ptr);
         }
         }

"["      { return LL; }
"]"      { return LR; }
","      { return LS; }
"{"      { return OL; }
"}"      { return OR; }
":"      { return OS; }
"true"   { yylval.TE = "true"; return TE; }
"false"  { yylval.FE = "false"; return FE; }
"null"   { yylval.NL = "null"; return NL; }
-?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?  { yylval.NUM = atof (yytext); return NUM; }
[ \t]    { /* Skip Whitespace */ }
\n       { return EOL; }
.        {
           printf("Parse error: %s is not correct json\n", yytext);
           free_n_const_collect_list(lex_top);
           exit(EXIT_FAILURE);
         }
<<EOF>>  {
           free_const_collect_list(lex_top);
           yyterminate();
         }

%%

void buf_check(char* b, char* p){
    if(p >= b + MAX_STR_CONST){
	printf("String exceeds buffer size\n");
	free_n_const_collect_list(lex_top);
	exit(EXIT_FAILURE);
    }
}
