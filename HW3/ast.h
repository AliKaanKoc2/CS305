#ifndef AST_H
#define AST_H

typedef enum { SENSOR, LIGHT, SWITCH } DeviceType;
typedef enum { ACCENT, AMBIENT, TASK, ON, OFF } StateKind;
typedef enum { GT, LT, GE, LE, EQEQ, NE } CmpOp;
typedef enum { B_AND, B_OR, B_NOT, B_PRED } BoolKind;
typedef enum { P_NUMCMP, P_STATECMP, P_TIMERANGE, P_TIMEPOINT } PredKind;



#endif