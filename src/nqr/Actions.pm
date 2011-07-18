#! nqp
# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

class nqr::Actions is HLL::Actions;

method begin_TOP ($/) {
    our $?BLOCK := PAST::Block.new(:blocktype<declaration>, :node($/),
                                   :hll<nqr>);
    our @?BLOCK;
    @?BLOCK.unshift($?BLOCK);
}

method TOP($/) {
    our @?BLOCK;
    my $past := @?BLOCK.shift();
    $past.push($<statementlist>.ast);
    make $past;
}

method statementlist($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<stat_or_def> { $past.push( $_.ast ); }
    make $past;
}

method stat_or_def($/) {
    if $<statement> {
        make $<statement>.ast;
    }
    else { # Must be a def
        make $<function_definition>.ast;
    }
}

# This is parsed before the function definition, so this is where the
# new block is created and placed on the scope stack:
method parameters($/) {
    our $?BLOCK;
    our @?BLOCK;
    my $past := PAST::Block.new( :blocktype('declaration'), :node($/) );

    # now add all parameters to this block
    for $<identifier> {
        my $param := $_.ast;
        $param.scope('parameter');
        $past.push($param);

        # register the parameter as a local symbol
        $past.symbol($param.name(), :scope('lexical'));
    }

    # now put the block into place on the scope stack
    $?BLOCK := $past;
    @?BLOCK.unshift($past);

    make $past;
}

method function_definition($/) {
     our $?BLOCK;
     our @?BLOCK;
     my $past := $<parameters>.ast;
     my $name := $<identifier>.ast;

     # set the function's name
     $past.name($name.name);

     # add all statements to the function's body
     for $<statement> {
         $past.push($_.ast);
     }

     # and remove the block from the scope stack and restore
     # the current block
     @?BLOCK.shift();
     $?BLOCK := @?BLOCK[0];

     # JAY: this is so that the return works.
     $past.control('return_pir');

     make $past;
}

# This might need to be broken up for assignment to subsets.
# Doesn't work for assignment to arrays.  See:
# a <- seq(1,10,1)
# a[5] <- 99
# RESULT: 1 2 3 4 5 1 7 8 9 10
# Because 99 is length 1 I think, as a FixedIntegerArray.
method statement:sym<assignment>($/) {
    my $lhs := $<primary>.ast;
    my $rhs := $<EXPR>.ast;
    $lhs.lvalue(1);
    make PAST::Op.new($lhs, $rhs, :pasttype<bind>, :node($/));
}

############ begin working on 'for' actions...

# A different attempt in one method, very close to matrixy:
method statement:sym<myfor>($/) {
    our $?BLOCK;
    our @?BLOCK;

    my $body := PAST::Block.new( :blocktype('immediate'),
                                 :node($/) );
    $?BLOCK := $body;
    @?BLOCK.unshift($?BLOCK);

    my $iter := $<identifier>.ast;
    $iter.isdecl(1);
    $iter.scope('parameter');
    $body.symbol($iter.name(), :scope('lexical'));
    $body.push($iter);

    for $<statement> {
        $body.push($_.ast);
    }

    @?BLOCK.shift();
    $?BLOCK  := @?BLOCK[0];

    my $set := $<EXPR>.ast;
    my $loop := PAST::Op.new( $set, $body, :pasttype('for'), :node($/) );

    make PAST::Stmts.new( $loop, :node($/) );
}



method statement:sym<myfor2>($/) {
    our $?BLOCK;
    our @?BLOCK;

    $?BLOCK := PAST::Block.new( :blocktype('immediate'),
                                :node($/) );
    @?BLOCK.unshift($?BLOCK);

    my $iter := $<identifier>.ast;
    $iter.isdecl(1);
    $iter.scope('parameter');
    $?BLOCK.symbol($iter.name(), :scope('lexical'));

    for $<statement> {
        $?BLOCK.push($_.ast);
    }

    ## Trying to figure out the parameters?  This causes fatal problems:
    #my $param := PAST::Op.new( $iter.name(),
    #                           :pirop('get_params'), :node($/) );
    #$?BLOCK.push($param);

    my $body := @?BLOCK.shift();
    $?BLOCK  := @?BLOCK[0];

    my $set := $<EXPR>.ast;

    my $loop := PAST::Op.new( $set, $body, :pasttype('for'), :node($/) );

    make PAST::Stmts.new( $loop, :node($/) );
}

# Attempted modification of the original squaak construct:

method for_init($/) {
    our $?BLOCK;
    our @?BLOCK;

    ## create a new scope here, so that we can
    ## add the loop variable
    ## to this block here, which is convenient.
    $?BLOCK := PAST::Block.new( :blocktype('immediate'),
                                :node($/) );
    @?BLOCK.unshift($?BLOCK);

    my $iter := $<identifier>.ast;
    ## set a flag that this identifier is being declared
    $iter.isdecl(1);
    $iter.scope('lexical');
    ## the identifier is initialized with this expression

    $iter.viviself( $<forint>.ast );   # was $<EXPR>.ast
    
    ## enter the loop variable into the symbol table.
    $?BLOCK.symbol($iter.name(), :scope('lexical'));

    make $iter;
}

# Hacked to force usage of literals for the start and end
# values rather than letting them be trivial arrays.
method statement:sym<for>($/) {
    our $?BLOCK;
    our @?BLOCK;

    my $init := $<for_init>.ast;
    ## cache the name of the loop variable
    my $itername := $init.name();
    my $iter := PAST::Var.new( :name($itername),
                               :scope('lexical'),   # Was lexical
                               :node($/) );

    ## the body of the loop consists of the statements written
    ## by the user and the increment instruction of the loop iterator.

    my $body := @?BLOCK.shift();
    $?BLOCK  := @?BLOCK[0];
    for $<statement> {
        $body.push($_.ast);
    }

    # NOTE: simplified, got rid of the more general step

    my $step := PAST::Op.new( $iter, :pirop('inc'), :node($/) );
    $body.push($step);

    # while loop iterator <= end-expression
    my $cond := PAST::Op.new( :pirop<isle__IPP>,
                              $iter,
                              $<forint>.ast );   # was $<EXPR>.ast
    my $loop := PAST::Op.new( $cond, $body, :pasttype('while'),
                              :node($/) );

    make PAST::Stmts.new( $init, $loop, :node($/) );
}

# This was the additional rule/action to support that, above:
method forint($/) {
    make PAST::Val.new(:value($<integer>.ast), :returns<Integer>);
}

############ end working on 'for' actions...

# NOTE: our action is R-consistent, but if the condition has
# length > 1 we would like to throw a warning.
# moritz++ on this one, extracting the literal from the PMC:
method statement:sym<if>($/) {
    my $cond := PAST::Op.new( :pirop<set__iQi>,      ## NEW
                              $<EXPR>.ast, 0 );
    #my $cond := $<EXPR>.ast;
    my $past := PAST::Op.new( $cond, $<then>.ast,
                              :pasttype('if'),
                              :node($/) );
    if $<else> {
        $past.push($<else>[0].ast);
    }
    make $past;
}

method statement:sym<function_call>($/) {
    my $invocant := $<primary>.ast;
    my $past     := $<arguments>.ast;
    $past.unshift($invocant);
    make $past;
}

method statement:sym<return>($/) {
    my $expr := $<EXPR>.ast;
    make PAST::Op.new( $expr, :pasttype('return'), :node($/) );
}

method arguments($/) {
    my $past := PAST::Op.new( :pasttype('call'), :node($/) );
    for $<EXPR> {
        $past.push($_.ast);
    }
    make $past;
}

# NOTE: out action is R-consistent, but if the condition has
# length > 1 we would like to throw a warning.
method statement:sym<while>($/) {
    my $cond := PAST::Op.new( :pirop<set__iQi>,        ## NEW
                              $<EXPR>.ast, 0 );
    #my $cond := $<EXPR>.ast;
    my $body := $<block>.ast;
    make PAST::Op.new( $cond, $body, :pasttype('while'), :node($/) );
}

#method statement:sym<terminus>($/) {
#    print("TERMINUS!");
#    #print($<term>);
#}

method begin_block($/) {
    our $?BLOCK;
    our @?BLOCK;
    $?BLOCK := PAST::Block.new(:blocktype('immediate'),
                                   :node($/));
    @?BLOCK.unshift($?BLOCK);
}

method block($/) {
    our $?BLOCK;
    our @?BLOCK;
    my $past := @?BLOCK.shift();
    $?BLOCK  := @?BLOCK[0];

    for $<statement> {
        $past.push($_.ast);
    }
    make $past;
}

# Check when this is used.  Might need to wrap the returned
# value if on the right side.  If on the left?  Hmm...
method primary($/) {
    my $past := $<identifier>.ast;

    for $<postfix_expression> {
        my $expr := $_.ast;
        $expr.unshift( $past );
        $past := $expr;
    }

    make $past;
}


### Modifed by JWE to strip out the literal.  But we really 
### want this to extract many values at a time, potentially,
### and there are other issues.
### (1) we want to search to see if something exists, and if
### not, create it with the right type.  If it exists
### (2) if it does exist and something is extracted, we want
### it to be a Resizable*Array, not a literal.
### (3) might need different ones for assignment from
### extraction.
method postfix_expression:sym<index>($/) {
    #print("In postfix_expression:index");
    my $index := PAST::Op.new( :pirop<set__iQi>,        ## NEW
                               $<EXPR>.ast, 0 );
    #my $index := $<EXPR>.ast;
    my $past  := PAST::Var.new( $index,
                                :scope('keyed'),
                                :viviself('Undef'),
                                :vivibase('ResizablePMCArray'),
                                :node($/) );

    make $past;
}

method postfix_expression:sym<key>($/) {
    my $key := $<EXPR>.ast;

    make PAST::Var.new( $key, :scope('keyed'),
                              :vivibase('Hash'),
                              :viviself('Undef'),
                              :node($/) );
}

method postfix_expression:sym<member>($/) {
    my $member := $<identifier>.ast;
    ## x.y is syntactic sugar for x{"y"},
    ## so stringify the identifier:
    my $key := PAST::Val.new( :returns('String'),
                              :value($member.name),
                              :node($/) );

    ## the rest of this method is the same
    ## as method key() above.
    make PAST::Var.new( $key, :scope('keyed'),
                        :vivibase('Hash'),
                        :viviself('Undef'),
                        :node($/) );
}

method identifier($/) {
     our @?BLOCK;
     my $name  := ~$<ident>;
     my $scope := 'package'; # default value
     # go through all scopes and check if the symbol
     # is registered as a local. If so, set scope to
     # local.
     for @?BLOCK {
         if $_.symbol($name) {
             $scope := 'lexical';
         }
     }

     make PAST::Var.new( :name($name),
                         :scope($scope),
                         :viviself('Undef'),
                         :node($/) );
}

# I was playing around with only using arrays, but stopped.
method term:sym<integer_constant>($/) {
    my $past := PAST::Op.new( :name('!intarray'), #'!array'),
                              :pasttype('call'),
                              :node($/) );
    $past.push($<integer>.ast);
    make $past;
    #make PAST::Val.new(:value($<integer>.ast), :returns<Integer>);
}

method term:sym<forint>($/) {
    make PAST::Val.new(:value($<integer>.ast), :returns<Integer>);
}

# Need to figure out how to make this ResizableStringArray:
method term:sym<string_constant>($/) { make $<string_constant>.ast; }
method string_constant($/) {
    my $past := $<quote>.ast;
    $past.returns('String');
    make $past;
}

# Ditto on playing with arrays and no literals.
# What is the role of the + sign below?
method term:sym<float_constant_long>($/) { # name worksaround lack of LTM
    my $past := PAST::Op.new( :name('!floatarray'), #'!array'),
                              :pasttype('call'),
                              :node($/) );
    $past.push(+$/);
    make $past;
    #make PAST::Val.new(:value(+$/), :returns<Float>);
}

method term:sym<primary>($/) {
    make $<primary>.ast;
}

# JAY: to support the return (perhaps not ideal):
method term:sym<termfunction_call>($/) {
    my $invocant := $<primary>.ast;
    my $past     := $<arguments>.ast;
    $past.unshift($invocant);
    make $past;
}

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }

method circumfix:sym<( )>($/) { make $<EXPR>.ast; }

method named_field($/) {
    my $past := $<EXPR>.ast;
    my $name := $<string_constant>.ast;
    ## the passed expression is in fact a named argument,
    ## use the named() accessor to set that name.
    $past.named($name);
    make $past;
}

### JAY: Probably not supported at all:
method circumfix:sym<[ ]>($/) {
    ## use the parrot calling conventions to
    ## create an array,
    ## using the "anonymous" sub !array
    ## (which is not a valid nqr name)
    my $past := PAST::Op.new( :name('!array'),   # was !array
                              :pasttype('call'),
                              :node($/) );
    for $<EXPR> {
        $past.push($_.ast);
    }
    make $past;
}

method circumfix:sym<{ }>($/) {
    ## use the parrot calling conventions to
    ## create a hash, using the "anonymous" sub
    ## !hash (which is not a valid nqr name)
    my $past := PAST::Op.new( :name('!hash'),
                              :pasttype('call'),
                              :node($/) );
    for $<named_field> {
        $past.push($_.ast);
    }
    make $past;
}

####
#### Old stuff we might want to refer to easily, below
####

#method statement:sym<throw>($/) {
#    make PAST::Op.new( $<EXPR>.ast,
#                       :pirop('die'),
#                       :node($/) );
#}

#method statement:sym<try>($/) {
#    ## get the try block
#    my $try := $<try>.ast;
#
#    ## create a new PAST::Stmts node for
#    ## the catch block; note that no
#    ## PAST::Block is created, as this
#    ## currently has problems with the
#    ## exception object. For now this will
#    ## do.
#    my $catch := PAST::Stmts.new( :node($/) );
#    $catch.push($<catch>.ast);#
#
#    ## get the exception identifier;
#    ## set a declaration flag, the scope,
#    ## and clear the viviself attribute.
#    my $exc := $<exception>.ast;
#    $exc.isdecl(1);
#    $exc.scope('lexical');
#    $exc.viviself(0);
#    ## generate instruction to retrieve the exception object (and the
#    ## exception message, that is passed automatically in PIR, this is stored
#    ## into $S0 (but not used).
#    my $pir := "    .get_results (\%r, \$S0)\n"
#             ~ "    store_lex '" ~ $exc.name()
#             ~ "', \%r";
#
#    $catch.unshift( PAST::Op.new( :inline($pir), :node($/) ) );
#
#    ## do the declaration of the exception object as a lexical here:
#    $catch.unshift( $exc );
#    make PAST::Op.new( $try, $catch, :pasttype('try'), :node($/) );
#}

#method exception($/) {
#    my $past := $<identifier>.ast;
#    make $past;
#}

#method statement:sym<var>($/) {
#    our $?BLOCK;
#    # get the PAST for the identifier
#    my $past := $<identifier>.ast;
#
#    # this is a local (it is being defined)
#    $past.scope('lexical');
#
#    # set a declaration flag
#    $past.isdecl(1);
#
#    # check for the initialization expression
#    if $<EXPR> {
#        # use the viviself clause to add a
#        # an initialization expression
#        $past.viviself($<EXPR>[0].ast);
#    }
#    else { # no initialization, default to "Undef"
#        $past.viviself('Undef');
#    }
#
#    my $name := $past.name();
#
#    if $?BLOCK.symbol( $name ) {
#        # symbol is already present
#        $/.CURSOR.panic("Error: symbol " ~ $name ~ " was already defined.\n");
#    }
#    else {
#        $?BLOCK.symbol( $name, :scope('lexical') );
#    }
#    make $past;
#}



