#include "check.h"
#include "ast.h"
#include <string.h>
#include <stdio.h>

int errorCount = 0;

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