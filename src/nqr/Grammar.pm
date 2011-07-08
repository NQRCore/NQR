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

###################################################################
# JAY: again, the action isn't quite right for this attempt either:
rule statement:sym<for> {
    <sym> <for_init>
    '{' <statement>* '}'
}

rule for_init {
    '(' <identifier> 'in' <EXPR> ')'
}

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
rule postfix_expression:sym<member> { '.' <identifier> }

token identifier {
    <!keyword> <ident>
}

# JAY: added function and return and removed sub, added '&' and '|' and '!'
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
    nqr::Grammar.O(':prec<w>, :assoc<unary>', '%unary-negate');
    nqr::Grammar.O(':prec<v>, :assoc<unary>', '%unary-not');
    # JAY added trying to do ':'
    #nqr::Grammar.O(':prec<v>, :assoc<left>',  '%sequence');
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

token prefix:sym<-> { <sym> <O('%unary-negate, :pirop<neg>')> }
token prefix:sym<!> { <sym> <O('%unary-not, :pirop<isfalse>')> }

# JAY: Added trying to do ':'
#token infix:sym<:>  { <sym> <O('%sequence')> }
token infix:sym<*>  { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym<%>  { <sym> <O('%multiplicative, :pirop<mod>')> }
token infix:sym</>  { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+>  { <sym> <O('%additive, :pirop<add>')> }
token infix:sym<->  { <sym> <O('%additive, :pirop<sub>')> }
token infix:sym<..> { <sym> <O('%additive, :pirop<concat>')> }

token infix:sym«<» { <sym> <O('%relational, :pirop<islt iPP>')> }
token infix:sym«<=» { <sym> <O('%relational, :pirop<isle iPP>')> }
token infix:sym«>» { <sym> <O('%relational, :pirop<isgt iPP>')> }
token infix:sym«>=» { <sym> <O('%relational, :pirop<isge iPP>')> }
token infix:sym«==» { <sym> <O('%relational, :pirop<iseq iPP>')> }
token infix:sym«!=» { <sym> <O('%relational, :pirop<isne iPP>')> }

token infix:sym<&> { <sym> <O('%conjunction, :pasttype<if>')> }
token infix:sym<|> { <sym> <O('%disjunction, :pasttype<unless>')> }
