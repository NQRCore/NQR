#! nqp
# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

# language-specific runtime functions go here

{
    my sub array (*@args) { @args; }
    my sub hash (*%args) { %args; }

    Q:PIR {
        $P0 = find_lex 'array'
        set_global '!array', $P0
        $P0 = find_lex 'hash'
        set_global '!hash', $P0
    }
}

######################################################################
# say(): do not modify this!
# The following was from Squaak, but I changed it to 'say' and
# changed all the tests as a result:

sub say(*@args) {
    pir::say(pir::join('', @args));
    pir::return();
}

########################################
# length()

# A version from Andrew Whitworth:
sub length($arg) {
   if (pir::does($arg, "array") || pir::does($arg, "hash")) {
       return pir::elements($arg);
   }
   return 1;
}

#################################################################
# print() for the first argument only.  Maybe could also be done
# with multiple dispatch, see SCRATCH.

sub print(*@args) {
    my $len := length(@args);
    if ($len > 1) {
        say("Warning: only first argument is printed.");
    }
    my $arg := @args[0];
    if pir::does($arg, "array") {
        say(pir::join(' ', $arg));
    } else {
        say($arg);
    }
}

######################################################
# seq(): using only NQP; there is a PIR version 
# in SCRATCH.

sub seq(*@args) {
  my $from := @args[0];
  my $to := @args[1];
  my $by := @args[2];
  my @ans;
  while ($from<=$to) {
    @ans[@ans] := $from;
    $from := $from + $by;
  }
  pir::return(@ans);
}

#######################################################
# c(): should take either scalars or arrays

sub c(*@args) {
    my $len := length(args);
    my @ans;
    my @this;
    for (@args) {
        if pir::does($_, "array") {
            @this := $_;
            for (@this) {
                @ans[@ans] := $_;
            }
        } else {
            @ans[@ans] := $_;
        }
    }
    return @ans;
}

############
# is.array()

sub isarray($arg) {
    return pir::does($arg, "array");
}

#######
# str()

sub str($arg) {
    return pir::typeof($arg);
}

#################################
# For working on the class stuff:

sub classtest() {
    my $abc := ABC.new();
    my $xyz := XYZ.new();

    $abc.foo();
    $xyz.foo();
    $xyz.bar();

}

sub test() {
    my $a := vector.new();
    $a.foo();
    $a[0] := 2;
    $a[1] := 5;
    print($a);
    print(length($a));
    print(str($a));
}

############################################
# NCI starting point:


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
    %r = box 0
  };
}

sub rexpworks(*@args) {
  return Q:PIR {
    $P0 = find_lex '@args'
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

sub rexp(*@args) {
    return Q:PIR {
        .local num arg, ans
        $P0 = find_lex '@args'
        arg = $P0[0]
        .local pmc libRmath, rexp
        libRmath = loadlib 'libRmath'
        if libRmath goto HAVELIBRARY
        say 'Could not load the libRmath library'
      HAVELIBRARY:
        rexp = dlfunc libRmath, 'rexp', 'dd'
        ans = rexp(arg)
        %r = box ans
    };
}

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

# Ok, try the same thing in NQP.  Then consider Winxed.
sub mean2(*@args) {
    my $vec := pir::new("ResizableFloatArray");
    #my $vec := pir::new("FixedFloatArray", 2);
    # Using Fixed... rather than Resizable... generates:
    #   "init_pmc() not implemented in class 'FixedFloatArray'

    $vec[0] := 1.234;
    $vec[1] := 5.678;
    return $vec[0] + $vec[1];
}





