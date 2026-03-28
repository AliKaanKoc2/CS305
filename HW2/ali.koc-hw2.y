%{
#include <stdio.h>
int yylex(void);
void yyerror(const char *s);
%}

%token tDEVICE tRULE tWHEN tTHEN tTIME tIN tAND tOR tNOT
%token tSENSOR tLIGHT tSWITCH tACCENT tAMBIENT tTASK tON tOFF
%token tDOTDOT tGE tLE tEQEQ tNE tLBRACE tRBRACE tLPAREN tRPAREN
%token tCOLON tSEMI tEQ tGT tLT
%token tTIMEVALUE tINT tSTRING tID

%%

program : declarations ;

declarations : declarations declaration
             | /* empty */
;

declaration : device | rule;

device : tDEVICE tID tCOLON device_type tSEMI;

device_type : tSENSOR | tLIGHT | tSWITCH;

rule : tRULE tSTRING tLBRACE when_clause then_clause tRBRACE;

when_clause : tWHEN bool_low tSEMI;

then_clause : tTHEN action_list;

action_list : action
            | action_list action
;

action: tID tEQ state tSEMI;

bool_low :  bool_mid
          | bool_low tOR bool_mid;

bool_mid :  bool_high  
          | bool_mid tAND bool_high;

bool_high : predicate   
          | tNOT bool_high
          | tLPAREN bool_low tRPAREN
;       

predicate : tID rel_op tINT
          | tTIME tIN tTIMEVALUE tDOTDOT tTIMEVALUE
          | tTIME tIN tTIMEVALUE
          | tID comp_op state
;

rel_op : tGE | tLE | tEQEQ | tNE | tGT | tLT;

comp_op : tEQEQ | tNE;

state : tON | tOFF | tACCENT | tAMBIENT | tTASK;

%%

void yyerror(const char *s) {}

int main ()
{
    if (yyparse())
    {
        printf("ERROR\n");
        return 1;
    }

    else
    {
        printf("OK\n");
        return 0;
    }
}