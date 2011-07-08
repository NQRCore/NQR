#! nqp
# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

class nqr::Compiler is HLL::Compiler;

INIT {

    nqr::Compiler.language('nqr');
    nqr::Compiler.parsegrammar(nqr::Grammar);
    nqr::Compiler.parseactions(nqr::Actions);
    nqr::Compiler.commandline_banner("\nNot Quite R for Parrot VM.\n\n");
    nqr::Compiler.commandline_prompt('> ');
}

# Added to suppress the annoying non-R-like printing on things that
# we aren't used to printing; thanks pmichaud!
method autoprint($value) { }

