#! nqp
# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

=begin overview

This is the grammar for Not Quite R in Perl 6 rules.
It is adapted from the squaak language tutorial of
Parrot 3.3.0.

=end overview

grammar nqr::Grammar is HLL::Grammar;

token begin_TOP {
    <?>
}

token TOP {
    <.begin_TOP>
    <statementlist>
    [ $ || <.panic: "Syntax error"> ]
}

## Lexer items

token ws {
    <!ww>
    [ '#' \N* \n? | \s+ ]*
}

## Statements

rule statementlist {
    <stat_or_def>*
}

# JAY: I placed sub_definition first, because otherwise it might
# be picked up as an assignment:
rule stat_or_def {
    | <function_definition>
    | <statement>
}

rule function_definition {
    <identifier> ['<-' | '='] 'function' <parameters>
    '{'
    <statement>*
    '}'
}

rule parameters {
   '(' [<identifier> ** ',']? ')'
}

proto rule statement { <...> }

rule statement:sym<assignment> {
    | <primary> '=' <EXPR>
    | <primary> '<-' <EXPR>
}

############################## start of 'for' attempts

##############################################################
# JAY: the action isn't quite right for this attempt of 'for':
rule statement:sym<myfor> {
    <sym> '(' <identifier> 'in' <EXPR> ')' '{'
        <statement>*
    '}'
}

rule statement:sym<myfor2> {
    <sym> '(' <identifier> 'in' <EXPR> ')' '{'
        <statement>*
    '}'
}

###################################################################
# JAY: minor modification of original syntax:

rule statement:sym<for> {
    <sym> <for_init> <forint> ')'
    '{' <statement>* '}'
}

rule for_init {
    '(' <identifier> 'in' <forint> 'to'
}

rule forint { <integer> }

############################## end of 'for' attempts

rule statement:sym<if> {
    <sym> '(' <EXPR> ')' '{' $<then>=<block> '}'
    ['else' '{' $<else>=<block> '}' ]?
}

rule statement:sym<return> {
    'return' '(' <EXPR> ')'
}

rule statement:sym<function_call> {
    <primary> <arguments>
}

rule arguments {
    '(' [<EXPR> ** ',']? ')'
}

# JAY: this is interesting as we explore scope issues so I leave it.
#rule statement:sym<var> {
#    <sym> <identifier> ['=' <EXPR>]?
#}

rule statement:sym<while> {
    <sym> '(' <EXPR> ')' '{' <block> '}'
}

# Possible start to getting a terminal expression to print.
#rule statement:sym<terminus> {
#    <term>
#}

token begin_block {
    <?>
}

rule block {
    <.begin_block>
    <statement>*
}

## Terms

rule primary {
    <identifier> <postfix_expression>*
}

proto rule postfix_expression { <...> }

rule postfix_expression:sym<index> { '[' <EXPR> ']' }
rule postfix_expression:sym<key> { '{' <EXPR> '}' }

# JAY: probably want to get rid of this:
rule postfix_expression:sym<member> { '.' <identifier> }

# JAY: probably want to customize this to all '.' and perhaps '_'?
token identifier {
    <!keyword> <ident>
}

# JAY: added function and return and removed sub,
# added '&' and '|' and '!'
token keyword {
    [ '&' |'else' |'for' |'if' | 'function' | 'return'
    | '!' |  '|'  |'var' |'while']>>
}

token term:sym<integer_constant> { <integer> }
token term:sym<string_constant> { <string_constant> }

# JAY: fixed up so our returns work, but perhaps not ideal solution:
token term:sym<termfunction_call> { <primary> <arguments> }

token string_constant { <quote> }
token term:sym<float_constant_long> { # longer to work-around lack of LTM
    [
    | \d+ '.' \d*
    | \d* '.' \d+
    ]
}
token term:sym<primary> {
    <primary>
}

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }

## Operators

## JAY: Tried to add sequence for ':'
INIT {
    nqr::Grammar.O(':prec<x>, :assoc<unary>', '%unary-negate');
    nqr::Grammar.O(':prec<w>, :assoc<unary>', '%unary-not');
    nqr::Grammar.O(':prec<v>, :assoc<left>',  '%sequence');
    nqr::Grammar.O(':prec<u>, :assoc<left>',  '%multiplicative');
    nqr::Grammar.O(':prec<t>, :assoc<left>',  '%additive');
    nqr::Grammar.O(':prec<s>, :assoc<left>',  '%relational');
    nqr::Grammar.O(':prec<r>, :assoc<left>',  '%conjunction');
    nqr::Grammar.O(':prec<q>, :assoc<left>',  '%disjunction');
}

token circumfix:sym<( )> { '(' <.ws> <EXPR> ')' }

rule circumfix:sym<[ ]> {
    '[' [<EXPR> ** ',']? ']'
}

rule circumfix:sym<{ }> {
    '{' [<named_field> ** ',']? '}'
}

rule named_field {
    <string_constant> '=>' <EXPR>
}

# Need to be vectorized, too:
token prefix:sym<-> { <sym> <O('%unary-negate, :pirop<neg>')> }
token prefix:sym<!> { <sym> <O('%unary-not, :pirop<isfalse>')> }


# Vectorized:
token infix:sym<:>  { <sym> <O('%sequence')> }
token infix:sym<*>  { <sym> <O('%multiplicative')> }

# Not vectorized:
token infix:sym<%>  { <sym> <O('%multiplicative, :pirop<mod>')> }

# Vectorized:
token infix:sym</>  { <sym> <O('%multiplicative')> }
token infix:sym<+>  { <sym> <O('%additive')> }
token infix:sym<->  { <sym> <O('%additive')> }

# Not valid R syntax, but perhaps needed for tests?
#token infix:sym<..> { <sym> <O('%additive, :pirop<concat>')> }

# Vectorized:
token infix:sym«<» { <sym> <O('%relational')> }
token infix:sym«<=» { <sym> <O('%relational')> }
token infix:sym«>» { <sym> <O('%relational')> }
token infix:sym«>=» { <sym> <O('%relational')> }

# Vectorized:
token infix:sym«==» { <sym> <O('%relational')> }
token infix:sym«!=» { <sym> <O('%relational')> }

# Probably won't need changing, but check with vectors:
token infix:sym<&> { <sym> <O('%conjunction, :pasttype<if>')> }
token infix:sym<|> { <sym> <O('%disjunction, :pasttype<unless>')> }


