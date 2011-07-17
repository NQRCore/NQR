#! nqp
# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

# Note: I'm doing essentially no friendly error-checking
# at this point.  Bigger fish to fry...

# JAY: my @ans[@ans] trick is pretty speed-inefficient,
# so use it with care.  Can be avoided in places.

# language-specific runtime functions go here

{
    my sub array (*@args) { @args; }
    my sub hash (*%args) { %args; }
    my sub intarray (*@args) {
      my @ans := pir::new("ResizableIntegerArray");
      for (@args) { @ans[@ans] := $_; }
      @ans;
    }
    my sub floatarray (*@args) {
      my @ans := pir::new("ResizableFloatArray");
      for (@args) { @ans[@ans] := $_; }
      @ans;
    }


    # Use of the ! in this way prevents NQR from being able
    # to call these directly.
    Q:PIR {
        $P0 = find_lex 'array'
        set_global '!array', $P0
        $P0 = find_lex 'hash'
        set_global '!hash', $P0
        $P0 = find_lex 'intarray'
        set_global '!intarray', $P0
        $P0 = find_lex 'floatarray'
        set_global '!floatarray', $P0
    }
}

######################################################################
# say(): do not modify this!
# The following was from Squaak, but I changed it to 'say' and
# changed all the tests as a result; should only be used internally
# if at all.

sub say(*@args) {
    pir::say(pir::join('', @args));
    pir::return();
}


########################################
# length()

# Accepts an array, hash, or literal (incomplete checking),
# though checking a literal shouldn't be needed unless the
# query is length(5), perhaps?  Not sure even then...

# Simple if we always have a Resizable*Array, right?
sub length($arg) {
   return pir::elements($arg);
   #if (pir::does($arg, "array") || pir::does($arg, "hash")) {
   #    return pir::elements($arg);
   #}
   #return 1;
}

#################################################################
# print() for the first argument only.  Maybe could also be done
# with multiple dispatch, see SCRATCH.

# Accepts an array, hash, or literal (incomplete checking)
# Could be simplified if all my NQR objects are some *Array
# objects, anyway?
sub print(*@args) {
    my $len := length(@args);
    if ($len > 1) {
        say("Warning: only first argument is printed.");
    }
    my $arg := @args[0];
    if (pir::does($arg, "array") || pir::does($arg, "hash")) {
        say(pir::join(' ', $arg));
    } else {
        say($arg);
    }
}

sub warning($msg) {
    my $m := ["Warning:", $msg];
    print($m);
}

######################################################
# seq(): using only NQP; there is a PIR version 
# in SCRATCH.

# Modified for Resizable(Float_or_Integer)Array
# Looping starts at the end to avoid resizing, rathe
# than starting at 0.
sub seq($from, $to, $by) {
  my $f := $from[0];
  my $t := $to[0];
  my $b := $by[0];
  if ( (pir::typeof($f) eq 'Integer') &&
       (pir::typeof($b) eq 'Integer') ) { 
    my @ans := pir::new("ResizableIntegerArray");
    while ($f <= $t) {
      @ans[@ans] := $f;
      $f := $f + $b;
    }
    return @ans;
  } else {
    my @ans := pir::new("ResizableFloatArray");
    while ($f <= $t) {
      @ans[@ans] := $f;
      $f := $f + $b;
    }
    return @ans;
  }
}

sub paste(*@args) {
  my @ans := pir::new("ResizableStringArray");
  my @sargs := pir::new("ResizableStringArray");
  my $arg;
  for @args -> $arg {
    if (pir::does($arg, "array")) { $arg := $arg[0]; }
    @sargs[@sargs] := ~$arg;
    #if (pir::typeof($arg) ne 'String') {
    #  @sargs[@sargs] := pir::set__sN($arg);
    #} else {
    #  @sargs[@sargs] := $arg;
    #}
  }
  @ans[0] := pir::join(' ', @sargs);
  return @ans;
}

#######################################################
# c():

# Modified for Resizable(Float_or_Integer)Array, but no
# longer uses strings.
sub c(*@args) {
    my @ans;
    my @arg;
    my @this;
    my $type := 'Integer';
    for @args -> @arg {
        if (pir::typeof(@arg[0]) eq 'Float') {
            $type := 'Float';
            break;
        }
    }
    if ($type eq 'Integer') {
        my @ans := pir::new("ResizableIntegerArray");
        for @args -> @this {
            for (@this) {
                @ans[@ans] := $_;
            }
        }
        return @ans;
    } else {
        my @ans := pir::new("ResizableFloatArray");
        for @args -> @this {
            for (@this) {
                @ans[@ans] := $_;
            }
        }
        return @ans;
    }
}



sub rep($arg, $times) {
    my $len := length($arg);           # Eventually might be a PMC
    my $i := 0;
    my $j;
    my @ans := pir::new("ResizableFloatArray");
    while ($i < $times[0]) {
      $j := 0;
      while ($j < $len) {
        @ans[$i*$len+$j] := $arg[$j];
        $j++;
      }
      $i++;
    }
    return @ans;
}


############
# is.array()

# Should be true for everything I might give it, currently.
sub isarray($arg) {
    return pir::does($arg, "array");
}

#######
# str()

sub str($arg) {
    return pir::typeof($arg);
}



############################################
# NCI starting point with libRmath:


#sub myrexp($arg) {
#  my $ans;
#  my $libRmath := pir::loadlib("libRmath");
#  my $rexp := pir::dlfunc__PPSP($libRmath, "rexp", "dd");
#  $ans := pir::rexp($arg);
#  return $ans;
#}
# SEE notes in SCRATCH...
#https://github.com/letolabs/parrot-libgit2/blob/master/src/git2.nci
#https://github.com/letolabs/parrot-libgit2/blob/master/src/git2.pir
# set_global ['Git'], 'git_treebuilder_get', nci
#jay: and then it can be accessed through that key in that namespace, here, #Git::git_treebuilder_get

sub setseed(*@args) {
  return Q:PIR {
    $P0 = find_lex '@args'
    .local int arg1, arg2
    arg1 = $P0[0]
    arg1 = $P0[1]
    .local pmc libRmath, setseed
    libRmath = loadlib "libRmath"
    if libRmath goto HAVELIBRARY
      die "Could not load the library"
    HAVELIBRARY:
    setseed = dlfunc libRmath, "set_seed", "vii"
    setseed(arg1, arg2)
    %r = box 1
  };
}


sub rexpworks($rate) {
  return Q:PIR {
    $P0 = find_lex '$rate'
    .local num arg1
    arg1 = $P0[0]
    .local pmc libRmath, rexp
    .local num ans
    libRmath = loadlib "libRmath"
    rexp = dlfunc libRmath, "rexp", "dd"
    ans = rexp(arg1)
    %r = box ans
  };
}


# Note, see below: can't assign rexp(arg) directly to
# P1[0] because that seems to screw up the signature for
# the function call.
sub rexp($rate) {
    return Q:PIR {
        .local num arg, ans
        $P0 = find_lex '$rate'
        arg = $P0[0]
        .local pmc libRmath, rexp
        libRmath = loadlib 'libRmath'
        if libRmath goto HAVELIBRARY
        say 'Could not load the libRmath library'
      HAVELIBRARY:
        rexp = dlfunc libRmath, 'rexp', 'dd'
        ans = rexp(arg) # See note above
        $P1 = new ["ResizableFloatArray"]
        $P1[0] = ans
        %r = $P1
    };
}

#######################################
# GSL... and learning about the loading

sub dnorm(*@args) {
    return Q:PIR {
        .local num ans
        .local pmc gsl_ran_gaussian_pdf
        gsl_ran_gaussian_pdf = get_global ['GSL'], 'gsl_ran_gaussian_pdf'
        ans = gsl_ran_gaussian_pdf(0.5, 1.0)
        %r = box ans
    };
}

sub mean(*@args) {
    my $vec := Q:PIR { %r = new ["FixedFloatArray"], 2 };
    $vec[0] := 1.234;
    $vec[1] := 5.678;
    my $gsl_stats_mean :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_mean' };
    return $gsl_stats_mean($vec, 1, 2);
}

sub meanPIR(*@args) {
    return Q:PIR {
        .local num ans
        .local pmc gsl_stats_mean
        $P0 = new ["FixedFloatArray"], 2
        $P0[0] = 2.71828
        $P0[1] = 3.14159
        gsl_stats_mean = get_global ['GSL'], 'gsl_stats_mean'
        ans = gsl_stats_mean($P0, 1, 2)
        %r = box ans
    };
}

# Don't understand this one;
# my $x := 'foo'; pir::upcase($x)

sub sillytest(*@args) {
    # This works, but is Resizable:
    #my $vec := pir::new("ResizableFloatArray");

    # This works, but... argh.
    my $vec := Q:PIR { %r = new ["FixedFloatArray"], 2 };

    # Does not work:
    #my $vec := pir::new__psi("FixedFloatArray", 2);

    # Sees to work, but seems kind of mysterious:
    #my $vec := pir::new("FixedFloatArray");
    #$vec := pir::set__Pi(2);

    #my $vec := pir::new("FixedFloatArray", 2);
    # Using Fixed... rather than Resizable... generates:
    #   "init_pmc() not implemented in class 'FixedFloatArray'

    $vec[0] := 1.234;
    $vec[1] := 5.678;
    return $vec[0] + $vec[1];
}





