#include "check.h"
#include "ast.h"
#include <string.h>
#include <stdio.h>

int errorCount = 0;

const char* deviceTypeStr(DeviceType t) 
{
    if (t == SENSOR) return "sensor";
    if (t == LIGHT)  return "light";
    if (t == SWITCH) return "switch";
    return "";
}

const char* stateStr(StateKind s) 
{
    if (s == ON) return "on";
    if (s == OFF) return "off";
    if (s == ACCENT) return "accent";
    if (s == AMBIENT) return "ambient";
    if (s == TASK) return "task";
    return "";
}

const char* cmpOpStr(CmpOp op) {
    if (op == GT) return ">";
    if (op == LT) return "<";
    if (op == GE) return ">=";
    if (op == LE) return "<=";
    if (op == EQEQ) return "==";
    if (op == NE) return "!=";
    return "";
}

int isOnOff(StateKind s) 
{ 
    return s == ON || s == OFF; 
}

int isBrightness(StateKind s) 
{ 
    return s == ACCENT || s == AMBIENT || s == TASK; 
}

void checkDevices()
{
    for (Device *d = deviceHead; d != NULL; d = d->next)
    {
        for (Device *earlier = deviceHead; earlier != d; earlier = earlier->next)
        {
            if(strcmp(d->name,earlier->name) == 0)
            {
                printf("%d DUPLICATE DEVICE (%s)\n", d->line, d->name);
                errorCount++;
                break;
            }
        }
    }
}

void checkRules()
{
    for (Rule *r = ruleHead; r != NULL; r = r->next)
    {
        for (Rule *earlier = ruleHead; earlier != r; earlier = earlier->next)
        {
            if(strcmp(r->name,earlier->name) == 0)
            {
                printf("%d DUPLICATE RULE (%s)\n", r->braceLine, r->name);
                errorCount++;
                break;
            }
        }

        checkBoolExpr(r->when);
        for (Action *a = r->then; a != NULL; a = a->next) {
            checkAction(a);
        }
    }
}

void checkPredicate(Predicate *p)
{
    if(p->kind == P_NUMCMP)
    {
        Device *d = findDevice(p->u.numCmp.device);
        if (d == NULL)
        {
            printf("%d UNDECLARED DEVICE (%s)\n", p->line, p->u.numCmp.device);
            errorCount++;
            return;
        }
        else
        {
            if(d->type != SENSOR)
            {
                printf("%d TYPE ERROR (%s;expected=sensor;found=%s)\n", p->line, p->u.numCmp.device, deviceTypeStr(d->type));
                errorCount++;
            }
        }
    }
    else if (p->kind == P_STATECMP)
    {
        Device *d = findDevice(p->u.stateCmp.device);
        if (d == NULL)
        {
            printf("%d UNDECLARED DEVICE (%s)\n", p->line, p->u.stateCmp.device);
            errorCount++;
            return;
        }
        else
        {
            if(d->type == SENSOR)
            {
                printf("%d TYPE ERROR (%s;expected=actuator;found=sensor)\n", p->line, p->u.stateCmp.device);
                errorCount++;
                return;
            }

            if(d->type == LIGHT && isOnOff(p->u.stateCmp.state))
            {
                printf("%d STATE ERROR (%s;expected=brightness;found=%s)\n", p->line, p->u.stateCmp.device, stateStr(p->u.stateCmp.state));
                errorCount++;
            }

            if(d->type == SWITCH && isBrightness(p->u.stateCmp.state))
            {
                printf("%d STATE ERROR (%s;expected=on/off;found=%s)\n", p->line, p->u.stateCmp.device, stateStr(p->u.stateCmp.state));
                errorCount++;
            }
        }
    }
    else if (p->kind == P_TIMERANGE)
    {
        int hour1 = p->u.timeRange.hh1, hour2 = p->u.timeRange.hh2, min1 = p->u.timeRange.mm1, min2 = p->u.timeRange.mm2;
        if (hour1 < 0 || hour1 > 23 || min1 < 0 || min1 > 59)
        {
            printf("%d TIME ERROR (%02d:%02d)\n", p->line, hour1, min1);
            errorCount++;
        }
        if (hour2 < 0 || hour2 > 23 || min2 < 0 || min2 > 59)
        {
            printf("%d TIME ERROR (%02d:%02d)\n", p->line, hour2, min2);
            errorCount++;
        }
    }
    else if (p->kind == P_TIMEPOINT)
    {
        int hour = p->u.timePoint.hh, min = p->u.timePoint.mm;
        if (hour < 0 || hour > 23 || min < 0 || min > 59)
        {
            printf("%d TIME ERROR (%02d:%02d)\n", p->line, hour, min);
            errorCount++;
        }
    }
}

void checkBoolExpr(BoolExpr *b)
{
    if(b->kind == B_AND)
    {
        checkBoolExpr(b->u.andOr.left);
        checkBoolExpr(b->u.andOr.right);
    }
    else if (b->kind == B_OR)
    {
        checkBoolExpr(b->u.andOr.left);
        checkBoolExpr(b->u.andOr.right);
    }
    else if (b->kind == B_NOT)
    {
        checkBoolExpr(b->u.bool_not.ptr);
    }
    else if (b->kind == B_PRED)
    {
        checkPredicate(b->u.pred.predicate);
    }
}

void checkAction(Action *act)
{
    Device *d = findDevice(act->name);
    if ( d == NULL )
    {
        printf("%d UNDECLARED DEVICE (%s)\n", act->line, act->name);
        errorCount++;
        return;
    }

    else if ( d->type == SENSOR )
    {
        printf("%d TYPE ERROR (%s;expected=actuator;found=sensor)\n", act->line, act->name);
        errorCount++;
        return;
    }

    if(d->type == LIGHT && isOnOff(act->state))
    {
        printf("%d STATE ERROR (%s;expected=brightness;found=%s)\n", act->line, act->name, stateStr(act->state));
        errorCount++;
    }

    if(d->type == SWITCH && isBrightness(act->state))
    {
        printf("%d STATE ERROR (%s;expected=on/off;found=%s)\n", act->line, act->name, stateStr(act->state));
        errorCount++;
    }
}

Device *findDevice(char *name)
{
    for (Device *d = deviceHead; d != NULL; d = d->next)
    {
        if(strcmp(name,d->name) == 0)
        {
            return d;
        }
    }
    return NULL;
}