%{
/*
 * parser.y - Bison grammar for HA (Home Automation) language
 * HW2: Syntax Analysis (no AST construction)
 */

#include <stdio.h>
#include "ast.h"
#include "check.h"
extern int yylineno;
int yylex();

/* Error handling */
void yyerror (const char *msg) 
{
	;
}

%}

%union {
    int ival;
    char* sval;
    BoolExpr* bexpr;
    Predicate* pred;
    DeviceType devtype;
    StateKind state;
    CmpOp cmp;
    Action* act;

    struct {int hh, mm;} time;
}

%token <sval> tID
%token <ival> tINT
%token <sval> tSTRING
%token <time> tTIMEVALUE
%type  <bexpr> bool_expr
%type  <devtype> dev_type
%type <state> switch_state
%type <state> light_state
%type <cmp> comp 
%type <cmp> relop
%type <bexpr> when_clause
%type <act> then_clause
%type <act> action
%type <act> action_list
%type <pred> predicate
%type <bexpr> bool_factor
%type <bexpr> bool_term

/* Terminal tokens */
%token tDEVICE tRULE tWHEN tTHEN
%token tTIME tIN tAND tOR tNOT
%token tSENSOR tLIGHT tSWITCH
%token tACCENT tAMBIENT tTASK
%token tON tOFF
%token tLBRACE tRBRACE tLPAREN tRPAREN
%token tCOLON tSEMI tEQ tDOTDOT
%token tGT tLT tGE tLE tEQEQ tNE

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
    : tDEVICE tID tCOLON dev_type tSEMI                         { appendDevice(makeDevice($2, $4, yylineno)); }
    ;

dev_type
    : tSENSOR                                                   { $$ = SENSOR; }
    | tLIGHT                                                    { $$ = LIGHT;  }
    | tSWITCH                                                   { $$ = SWITCH; }
    ;

rule_decl
    : tRULE tSTRING tLBRACE when_clause then_clause tRBRACE     { appendRule(makeRule($2, yylineno, $4, $5)); }
    ;

when_clause
    : tWHEN bool_expr tSEMI                                     { $$ = $2; }
    ;

then_clause
    : tTHEN action_list tSEMI                                   { $$ = $2; }
    ;

action_list
    : action_list tSEMI action                                  { 
                                                                    Action* curr = $1;
                                                                    while (curr->next != NULL)
                                                                        curr = curr->next;
                                                                    curr->next = $3;
                                                                    $$ = $1;
                                                                }

    | action                                                    { $$ = $1; }
    ;

action
    : tID tEQ switch_state                                      { $$ = makeAction($1, $3, yylineno); }
    | tID tEQ light_state                                       { $$ = makeAction($1, $3, yylineno); }
    ;

switch_state
    : tON                                                       { $$ = ON;  }
    | tOFF                                                      { $$ = OFF; }
    ;

light_state
    : tACCENT                                                   { $$ = ACCENT;  }
    | tAMBIENT                                                  { $$ = AMBIENT; }
    | tTASK                                                     { $$ = TASK;    }
    ;

bool_expr
    : bool_expr tOR bool_term                                   { $$ = makeAndOr(B_OR, $1, $3); }
    | bool_term                                                 { $$ = $1; }
    ;

bool_term
    : bool_term tAND bool_factor                                { $$ = makeAndOr(B_AND, $1, $3); }
    | bool_factor                                               { $$ = $1; }
    ;

bool_factor
    : tNOT bool_factor                                          { $$ = makeNot($2);}
    | tLPAREN bool_expr tRPAREN                                 { $$ = $2; }
    | predicate                                                 { $$ = makePred($1);}
    ;

predicate
    : tID relop tINT                                            { $$ = makeNumCmp($1, $2, $3, yylineno);   }
    | tTIME tIN tTIMEVALUE tDOTDOT tTIMEVALUE                   { $$ = makeTimeRange($3.hh, $3.mm, $5.hh, $5.mm, yylineno);  }
    | tTIME tIN tTIMEVALUE                                      { $$ = makeTimePoint($3.hh, $3.mm, yylineno);                }
    | tID comp switch_state                                     { $$ = makeStateCmp($1, $2, $3, yylineno); }
    | tID comp light_state                                      { $$ = makeStateCmp($1, $2, $3, yylineno); }
    ;

comp
    : tEQEQ                                                     { $$ = EQEQ; }
    | tNE                                                       { $$ = NE;   }
    ;

relop
    : tGT                                                       { $$ = GT; }
    | tLT                                                       { $$ = LT; }
    | tGE                                                       { $$ = GE; }
    | tLE                                                       { $$ = LE; }
    | tEQEQ                                                     { $$ = EQEQ;}
    | tNE                                                       { $$ = NE; }
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
        checkDevices();
        if(errorCount == 0)
        {
            printf("OK\n");
        }	
		return 0;
	}
}