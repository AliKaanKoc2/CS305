#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

Device *deviceHead = NULL;
Rule *ruleHead = NULL;

Device *makeDevice(char *name, DeviceType type, int line)
{
    Device *ptr = malloc(sizeof(Device));

    ptr->name = strdup(name);
    ptr->type = type;
    ptr->line = line;
    ptr->next = NULL;

    return ptr;
}

Action *makeAction(char *name, StateKind state, int line)
{
    Action *ptr = malloc(sizeof(Action));

    ptr->name = strdup(name);
    ptr->state = state;
    ptr->line = line;
    ptr->next = NULL;

    return ptr;
}

Predicate *makeNumCmp(char *device, CmpOp op, int val, int line)
{
    Predicate *ptr = malloc(sizeof(Predicate));

    ptr->kind = P_NUMCMP;
    ptr->line = line;
    ptr->u.numCmp.device = strdup(device);
    ptr->u.numCmp.op = op;
    ptr->u.numCmp.val = val;

    return ptr;
}

Predicate *makeStateCmp(char *device, CmpOp op, StateKind state, int line)
{
    Predicate *ptr = malloc(sizeof(Predicate));

    ptr->kind = P_STATECMP;
    ptr->line = line;
    ptr->u.stateCmp.device = strdup(device);
    ptr->u.stateCmp.op = op;
    ptr->u.stateCmp.state = state;
    

    return ptr;
}

Predicate *makeTimeRange(int hh1, int mm1, int hh2, int mm2, int line)
{
    Predicate *ptr = malloc(sizeof(Predicate));

    ptr->kind = P_TIMERANGE;
    ptr->line = line;
    ptr->u.timeRange.hh1 = hh1;
    ptr->u.timeRange.mm1 = mm1;
    ptr->u.timeRange.hh2 = hh2;
    ptr->u.timeRange.mm2 = mm2;

    return ptr;
}

Predicate *makeTimePoint(int hh, int mm, int line)
{
    Predicate *ptr = malloc(sizeof(Predicate));

    ptr->kind = P_TIMEPOINT;
    ptr->line = line;
    ptr->u.timePoint.hh = hh;
    ptr->u.timePoint.mm = mm;
   
    return ptr;
}

BoolExpr* makeAndOr(BoolKind kind, BoolExpr* left, BoolExpr* right)
{
    BoolExpr *ptr = malloc(sizeof(BoolExpr));

    ptr->kind = kind;
    ptr->u.andOr.left = left;
    ptr->u.andOr.right = right;

    return ptr;
}

BoolExpr* makeNot(BoolExpr* pointer)
{
    BoolExpr *ptr = malloc(sizeof(BoolExpr));

    ptr->kind = B_NOT;
    ptr->u.bool_not.ptr = pointer;

    return ptr;
}

BoolExpr* makePred(Predicate* predicate)
{
    BoolExpr *ptr = malloc(sizeof(BoolExpr));

    ptr->kind = B_PRED;
    ptr->u.pred.predicate = predicate;

    return ptr;
}

Rule *makeRule(char *name, int braceLine, BoolExpr *when, Action *then)
{
    Rule *ptr = malloc(sizeof(Rule));

    ptr->name = strdup(name);
    ptr->braceLine = braceLine;
    ptr->when = when;
    ptr->then = then;
    ptr->next = NULL;

    return ptr;
}

void appendDevice(Device *d)
{
    if (deviceHead == NULL){deviceHead = d;}
    else
    {
        Device *curr = deviceHead;
        while(curr->next != NULL)
        {
            curr = curr->next;
        }
        curr->next = d;
    }
}

void appendRule(Rule *r)
{
    if (ruleHead == NULL){ruleHead = r;}
    else
    {
        Rule *curr = ruleHead;
        while(curr->next != NULL)
        {
            curr = curr->next;
        }
        curr->next = r;
    }
}