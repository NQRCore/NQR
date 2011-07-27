#! nqp
# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

class nqr::Compiler is HLL::Compiler;

INIT {
    my $version := Q:PIR { # Surely this could be done better in NQP
        .local string filename
        .local pmc data_file
        .local string version
        filename = 'VERSION'
        data_file = open filename, 'r'
        version = readline data_file
        close data_file
        %r = box version
    };

    nqr::Compiler.language('nqr');
    nqr::Compiler.parsegrammar(nqr::Grammar);
    nqr::Compiler.parseactions(nqr::Actions);
    nqr::Compiler.commandline_banner("\nNot Quite R for Parrot VM, Version $version\nTo exit, use <ctrl>-D.\nPlease see t/00-sanity.t for currently-supported syntax.\n\n");
    nqr::Compiler.commandline_prompt('> ');
}

# Added to suppress the annoying non-R-like printing on things that
# we aren't used to printing; thanks pmichaud!
method autoprint($value) { }

