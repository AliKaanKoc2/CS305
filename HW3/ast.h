#ifndef AST_H
#define AST_H

typedef enum DeviceType { SENSOR, LIGHT, SWITCH } DeviceType;
typedef enum StateKind { ACCENT, AMBIENT, TASK, ON, OFF } StateKind;
typedef enum CmpOp { GT, LT, GE, LE, EQEQ, NE } CmpOp;
typedef enum BoolKind { B_AND, B_OR, B_NOT, B_PRED } BoolKind;
typedef enum PredKind { P_NUMCMP, P_STATECMP, P_TIMERANGE, P_TIMEPOINT } PredKind;

typedef struct Device
{
    char *name;
    DeviceType type;
    int line;
    struct Device *next;
} Device;

typedef struct Action
{
    char *name;
    StateKind state;
    int line;
    struct Action *next;
} Action;

typedef struct Predicate
{
    PredKind kind;
    int line;
    union
    {
        struct  {char *device; CmpOp op; int val;} numCmp;
        struct  {char *device; CmpOp op; StateKind state; } stateCmp;
        struct  {int hh1, mm1, hh2, mm2;} timeRange;
        struct  {int hh, mm;} timePoint;

    } u;

} Predicate;

typedef struct BoolExpr
{
    BoolKind kind;
    union
    {
        struct  {struct BoolExpr *left, *right;} andOr;
        struct  {struct BoolExpr * ptr;} bool_not;
        struct  {Predicate* predicate;} pred;

    } u;

} BoolExpr;

typedef struct Rule
{
    char *name;
    int braceLine;
    BoolExpr *when;
    Action *then;
    struct Rule *next;
} Rule;

Device *makeDevice(char *, DeviceType, int);
Action *makeAction(char *, StateKind, int);
Predicate *makeNumCmp(char *, CmpOp, int, int);
Predicate *makeStateCmp(char *, CmpOp, StateKind, int);
Predicate *makeTimeRange(int, int, int, int, int);
Predicate *makeTimePoint(int, int, int);
BoolExpr *makeAndOr(BoolKind, BoolExpr *, BoolExpr *);
BoolExpr *makeNot(BoolExpr *);
BoolExpr *makePred(Predicate *);
Rule *makeRule(char *, int, BoolExpr *, Action *);

extern Device *deviceHead;
extern Rule *ruleHead;

void appendDevice(Device *d);
void appendRule(Rule *r);

#endif