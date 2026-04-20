%{
/*
 * parser.y - Bison grammar for HA (Home Automation) language
 * HW2: Syntax Analysis (no AST construction)
 */

#include <stdio.h>

int yylex();

/* Error handling */
void yyerror (const char *msg) 
{
	;
}

%}

/* Terminal tokens */
%token tDEVICE tRULE tWHEN tTHEN
%token tTIME tIN tAND tOR tNOT
%token tSENSOR tLIGHT tSWITCH
%token tACCENT tAMBIENT tTASK
%token tON tOFF
%token tLBRACE tRBRACE tLPAREN tRPAREN
%token tCOLON tSEMI tEQ tDOTDOT
%token tGT tLT tGE tLE tEQEQ tNE
%token tID tSTRING tINT tTIMEVALUE

%%

program
    : stmt_list
    ;

stmt_list
    : stmt_list stmt
    | /* empty */
    ;

stmt
    : device_decl
    | rule_decl
    ;

device_decl
    : tDEVICE tID tCOLON dev_type tSEMI
    ;

dev_type
    : tSENSOR
    | tLIGHT
    | tSWITCH
    ;

rule_decl
    : tRULE tSTRING tLBRACE when_clause then_clause tRBRACE
    ;

when_clause
    : tWHEN bool_expr tSEMI
    ;

then_clause
    : tTHEN action_list tSEMI
    ;

action_list
    : action_list tSEMI action
    | action
    ;

action
    : tID tEQ switch_state
    | tID tEQ light_state
    ;

switch_state
    : tON
    | tOFF
    ;

light_state
    : tACCENT
    | tAMBIENT
    | tTASK
    ;

bool_expr
    : bool_expr tOR bool_term
    | bool_term
    ;

bool_term
    : bool_term tAND bool_factor
    | bool_factor
    ;

bool_factor
    : tNOT bool_factor
    | tLPAREN bool_expr tRPAREN
    | predicate
    ;

predicate
    : tID relop tINT
    | tTIME tIN tTIMEVALUE tDOTDOT tTIMEVALUE
    | tTIME tIN tTIMEVALUE
    | tID comp switch_state
    | tID comp light_state
    ;

comp
    : tEQEQ
    | tNE
    ;

relop
    : tGT
    | tLT
    | tGE
    | tLE
    | tEQEQ
    | tNE
    ;

%%

int main()
{
	if (yyparse()) {
		// Parse error
		printf("ERROR\n");
		return 1;
	}
	else {
		// Successful parsing
		printf("OK\n");
		return 0;
	}
}