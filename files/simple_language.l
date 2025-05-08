%option noyywrap          /* no necesitamos yywrap() */

%{
#include <cstdio>
#include <cstdlib>
#include <string>
#include "y.tab.h"        /* tokens y union de yylval */

int yylineno = 1;         /* contar líneas para mensajes de error */
%}

/* ─────────  Patrones auxiliares  ───────── */
DIGIT    [0-9]
ID       [a-zA-Z][a-zA-Z0-9]*

%%  /* ───────────────  Reglas  ─────────────── */

/* números */
{DIGIT}+        { yylval.num = strtol(yytext,nullptr,10); return NUMBER; }

/* identificadores */
{ID}            { yylval.str = new std::string(yytext);   return ID;     }

/* operadores y símbolos */
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"="             { return '='; }
":"             { return ':'; }
"("             { return '('; }
")"             { return ')'; }

/* espacios, TABs y retorno de carro: simplemente descártalos */
[ \t\r]+        ;

/* uno o más saltos de línea ⇒ un solo token '\n' */
\n+             { ++yylineno; return '\n'; }

/* ------------------------------------------------------------------
   Cualquier otro carácter se considera token inválido.
   Se imprime mensaje, se consume hasta fin de línea y se devuelve
   el token INVALID para que el parser pueda sincronizar.
------------------------------------------------------------------- */
.               {
                  fprintf(stderr,
                          "Token inválido \"%s\" en línea %d\n",
                          yytext, yylineno);

                  /* descartar hasta el próximo '\n' o EOF */
                  int c;
                  while ( (c = input()) != 0 && c != '\n' )
                      /* nada */;
                  unput('\n');        /* dejamos el NL para Bison */
                  return INVALID;
                }

%%  /* ───────────────────────────────────────── */