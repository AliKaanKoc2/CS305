#ifndef CHECK_H
#define CHECK_H

#include "ast.h"

extern int errorCount;

void checkDevices();
void checkRules();
void checkBoolExpr(BoolExpr *);
void checkPredicate(Predicate *);
void checkAction(Action *);

Device *findDevice(char *name);

#endif