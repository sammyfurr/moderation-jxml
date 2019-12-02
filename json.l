%{
#include "json.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define MAX_STR_CONST 1024
void buf_check(char* b, char* p);
%}
%x str
			
%%
         char string_buf[MAX_STR_CONST];
         char *string_buf_ptr;

\"       {
           string_buf_ptr = string_buf;
           *string_buf_ptr++ = '\"';
           buf_check(string_buf, string_buf_ptr);
           BEGIN(str);
         }

<str>\"  { /* saw closing quote - all done */
           BEGIN(INITIAL);
           *string_buf_ptr++ = '\"';
           buf_check(string_buf, string_buf_ptr);
           *string_buf_ptr = '\0';
           buf_check(string_buf, string_buf_ptr);
           yylval.JSTR = strdup(string_buf);
           return JSTR;
         }

<str>\\\" {
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
             /* if(string_buf_ptr > string_buf + MAX_STR_CONST) */
             /*   exit(EXIT_FAILURE); */
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
[ \t]    { /*Skip Whitespace*/ }
\n       { return EOL; }
.        { printf("Parse error: %s is not correct json\n", yytext); exit(EXIT_FAILURE);}
%%
void buf_check(char* b, char* p){
    if(p >= b + MAX_STR_CONST){
	printf("String exceeds buffer size\n");
	exit(EXIT_FAILURE);
    }
}
