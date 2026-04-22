#include <stdio.h>
#include <string.h>
#include "ast.h"
#include "print.h"
#include <stdlib.h>
#include "check.h"

void printPredicate(Predicate *p)
{
    if(p->kind == P_NUMCMP)
    {
        printf("(%s_%s_%d)", p->u.numCmp.device, cmpOpStr(p->u.numCmp.op), p->u.numCmp.val);
    }
    else if (p->kind == P_STATECMP)
    {
        printf("(%s_%s_%s)", p->u.stateCmp.device, cmpOpStr(p->u.stateCmp.op), stateStr(p->u.stateCmp.state));
    }
    else if (p->kind == P_TIMERANGE)
    {
        printf("(TIME_%02d:%02d..%02d:%02d)", p->u.timeRange.hh1, p->u.timeRange.mm1, p->u.timeRange.hh2, p->u.timeRange.mm2);
    }
    else if (p->kind == P_TIMEPOINT)
    {
        printf("(TIME_%02d:%02d)", p->u.timePoint.hh, p->u.timePoint.mm);
    }
}

void printCond(BoolExpr *b) 
{
    if(b->kind == B_AND)
    {
        printf("(");
        printCond(b->u.andOr.left);
        printf("_AND_");
        printCond(b->u.andOr.right);
        printf(")");
    }
    else if (b->kind == B_OR)
    {
        printf("(");
        printCond(b->u.andOr.left);
        printf("_OR_");
        printCond(b->u.andOr.right);
        printf(")");
    }
    else if (b->kind == B_NOT)
    {
        printf("(NOT_");
        printCond(b->u.bool_not.ptr);
        printf(")");
    }
    else if (b->kind == B_PRED)
    {
        printPredicate(b->u.pred.predicate);
    }
}

void printActions(Action *head)
{
    for (Action *a = head; a != NULL; a = a->next)
    {
        if (a != head) printf(";");
        printf("%s=%s", a->name, stateStr(a->state));
    }
}

void printReport()
{
    printf("DEVICES\n");

    char *lastPrinted = "";
    while(1)
    {
        Device *smallest = NULL;
        for (Device *d = deviceHead; d != NULL; d = d->next)
        {
            if(strcmp(d->name,lastPrinted) > 0)
            {
                if (smallest == NULL || strcmp(d->name,smallest->name) < 0)
                {
                    smallest = d;
                }
            }
        }

        if (smallest == NULL) {break;}

        printf("%s:%s\n", smallest->name, deviceTypeStr(smallest->type));

        lastPrinted = smallest->name;
    }

    printf("\n");

    for (Rule *r = ruleHead; r != NULL; r = r->next) {
        r->name[strlen(r->name) - 1] = '\0';
        printf("RULE:%s\n", r->name + 1); // look again 
        printf("COND:");
        printCond(r->when);      // recursive tree walk
        printf("\n");
        printf("ACT:");
        printActions(r->then);   // walk action list, emit device=state with ; separators
        printf("\n");
        printf("\n");            // blank line after rule block
    }
}