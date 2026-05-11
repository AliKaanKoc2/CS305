%{
#include <stdio.h>
int yylex();
int yyerror(char *s){
    return 0;
}
%}

%token tNUM
%%

expr : tNUM | expr expr '-' |  expr expr '+';
%%

int main(){
    if (yyparse() == 0){
        printf("Parsing successful\n");
    }
    else{
        printf("Parsing failed\n");
    }

    return 0;
}
