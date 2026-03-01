/*gcc lex.yy.c -L/opt/homebrew/opt/flex/lib -lfl -o scanner*/
%%
[0-9]    { printf("Found a number\n"); }
[a-zA-Z]  { printf("Found a word\n"); }
.           { /* Ignore everything else */ }
%%

int main() {
    yylex();
    return 0;
}