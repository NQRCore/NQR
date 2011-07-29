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

    ######################################################
    ## GSL functions with . in the names in the R wrapper:

    my sub whichmax ($arg) {
      my @ans := pir::new("ResizableIntegerArray");
      if (pir::typeof($arg[0]) eq 'Float') {
        my $fun :=
          Q:PIR { %r = get_global ['GSL'], 'gsl_stats_max_index' };
        @ans[0] := $fun($arg, 1, length($arg)[0]);
        return @ans;
      } else {
        print("which.max() not implemented for Integer data yet");
      }
    }

    my sub whichmin ($arg) {
      my @ans := pir::new("ResizableIntegerArray");
      if (pir::typeof($arg[0]) eq 'Float') {
        my $fun :=
          Q:PIR { %r = get_global ['GSL'], 'gsl_stats_min_index' };
        @ans[0] := $fun($arg, 1, length($arg)[0]);
        return @ans;
      } else {
        print("which.min() not implemented for Integer data yet");
      }
    }

    ####################################################
    ## R functions with . in the names in the R wrapper:

    my sub setseed(*@args) {
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

    # Should be true for everything I might give it, currently.
    my sub isarray($arg) {
        my $ans := pir::new("ResizableIntegerArray");
        $ans[0] := pir::does($arg, "array");
        return $ans;
    }

    # Use of the ! in this way prevents NQR from being able
    # to call these directly.  Probably get rid of array, and
    # at least change hash.
    Q:PIR {
        $P0 = find_lex 'array'
        set_global '!array', $P0
        $P0 = find_lex 'hash'
        set_global '!hash', $P0
        $P0 = find_lex 'intarray'
        set_global '!intarray', $P0
        $P0 = find_lex 'floatarray'
        set_global '!floatarray', $P0
        $P0 = find_lex 'whichmax'
        set_global 'which.max', $P0
        $P0 = find_lex 'whichmin'
        set_global 'which.min', $P0
        $P0 = find_lex 'setseed'
        set_global 'set.seed', $P0
        $P0 = find_lex 'isarray'
        set_global 'is.array', $P0
    }
}

######################################################################
# say(): do not modify this!
# The following was from Squaak, but I changed it to 'say' and
# changed all the tests as a result; should only be used internally
# if at all, but let's leave it for now.

sub say(*@args) {
    pir::say(pir::join('', @args));
    pir::return();
}

########################################
# length()

# Simple if we always have a Resizable*Array, right?
# Wouldn't work if we had literals, and be careful when you
# use this internally, might need length($arg)[0].
sub length($arg) {
   my @ans := pir::new("ResizableIntegerArray");
   @ans[0] := pir::elements($arg);
   return @ans;
}

#################################################################
# print() for the first argument only.  Maybe could also be done
# with multiple dispatch, see SCRATCH.

# Accepts an array, hash, or literal (incomplete checking)
# Could be simplified if all my NQR objects are some *Array
# objects, anyway?  Except it's nice for internal usage.
sub print(*@args) {
    my $len := length(@args)[0];
    if ($len > 1) {
        warning("only first argument is printed.");
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
# Looping starts at the end to avoid resizing, rather
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
    # Could also have been used:
    #  @sargs[@sargs] := pir::set__sN($arg);
  }
  @ans[0] := pir::join(' ', @sargs);
  return @ans;
}

#######################################################
# c():

# Modified for Resizable(Float_or_Integer)Array, but no
# longer uses strings.  Benchmarks indicated this was
# pretty slow.  It was one of my first, and could have
# lots of resizing.
sub c(*@args) {
    my @ans;
    my @arg;
    my @this;
    my $type := 'Integer';
    for @args -> @arg {
        if ( ($type eq 'Integer') &&
             (pir::typeof(@arg[0]) eq 'Float') ) {
            $type := 'Float';
        }
        if (pir::typeof(@arg[0]) eq 'String') {
            $type := 'String';
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
    }
    if ($type eq 'Float') {
        my @ans := pir::new("ResizableFloatArray");
        for @args -> @this {
            for (@this) {
                @ans[@ans] := $_;
            }
        }
        return @ans;
    }
    if ($type eq 'String') {
        my @ans := pir::new("ResizableStringArray");
        for @args -> @this {
            for (@this) {
                @ans[@ans] := $_;
            }
        }
        return @ans;
    }
}


# Was very inefficient using c(), rebuilt for Float only,
# still could be better.
sub rep($arg, $times) {
    my $len := length($arg)[0];
    my $i := 0;
    my $j;
    if (pir::typeof($arg[0]) eq 'Float') {
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
    if (pir::typeof($arg[0]) eq 'Integer') {
      my @ans := pir::new("ResizableIntegerArray");
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
    if (pir::typeof($arg[0]) eq 'String') {
      my @ans := pir::new("ResizableStringArray");
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


# Note, see below: can't assign rexp(arg) directly to
# P1[0] because that seems to screw up the signature for
# the function call.
sub rexpsingle($rate) {
    return Q:PIR {
        .local num arg, ans
        $P0 = find_lex '$rate'
        arg = $P0[0]
        .local pmc libRmath, rexp
        libRmath = loadlib 'libRmath'
        rexp = dlfunc libRmath, 'rexp', 'dd'
        ans = rexp(arg) # See note above
        $P1 = new ["ResizableFloatArray"]
        $P1[0] = ans
        %r = $P1
    };
}

sub rexp($n, $rate) {
    return Q:PIR {
        .local num rate, ans
        .local int i, N
        $P0 = find_lex '$rate'
        $P1 = find_lex '$n'
        rate = $P0[0]
        N = $P1[0]
        i = N - 1
        .local pmc libRmath, rexp
        libRmath = loadlib 'libRmath'
        rexp = dlfunc libRmath, 'rexp', 'dd'
        #$P2 = new ["ResizableFloatArray"]
        $P2 = new ["FixedFloatArray"], N
  LOOP: if i < 0 goto DONE
        ans = rexp(rate)
        $P2[i] = ans
        i = i - 1
        goto LOOP
  DONE: %r = $P2
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


# $arg will be a Resizable*Array, but we don't seem to get
# a real gsl_stats_int_max function, for some reason.
sub max($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_max' };
    @ans[0] := $fun($arg, 1, length($arg)[0]);
    return @ans;
  } else {
    print("Only min(Float) is available at this time");
  }
  if (pir::typeof($arg[0]) eq 'Integer') {
    print("max(Integer) is buggy, sorry: testing:");
    my @ans := pir::new("ResizableIntegerArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_int_max' };
    @ans[0] := $fun($arg, 1, length($arg)[0]);
    return @ans;
  }
}

sub min($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_min' };
    @ans[0] := $fun($arg, 1, length($arg)[0]);
    return @ans;
  } else {
    print("Only min(Float) is available at this time");
  }
}

sub var($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_variance' };
    @ans[0] := $fun($arg, 1, length($arg)[0]);
    return @ans;
  } else {
    print("Only var(Float) is available at this time");
  }
}

sub sd($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_sd' };
    @ans[0] := $fun($arg, 1, length($arg)[0]);
    return @ans;
  } else {
    print("Only sd(Float) is available at this time");
  }
}

sub order($arg) {
  warning("order() is not working; expect integer passing problem.");
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableIntegerArray");
    my $i;
    $i := length($arg)[0] - 1;
    while ($i >= 0) {
      @ans[$i] := $i;
      $i := $i - 1;
    }
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_sort_index' };
    #$fun(@ans, $arg, 1, length($arg)[0]);
    return @ans;
  } else {
    print("Only order(Float) is available at this time");
  }
}

# deep copy: pir assign
# Need decreasing option, too.
sub sort($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $i;
    $i := length($arg)[0] - 1;
    while ($i >= 0) {
      @ans[$i] := $arg[$i];
      $i := $i - 1;
    }
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_sort' };
    $fun(@ans, 1, length($arg)[0]);
    return @ans;
  } else {
    print("Only sort of floats is available at this time");
  }
}

sub cov($a, $b) {
  if (length($a)[0] != length($b)[0]) {
    return "Error: lengths must be equal";
  }
  if ( (pir::typeof($a[0]) eq 'Float') &&
       (pir::typeof($a[0]) eq 'Float') ) {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_covariance' };
    @ans[0] := $fun($a, 1, $b, 1, length($a)[0]);
    return @ans;
  } else {
    print("Only cov(float, float) is available at this time");
  }
}

sub cor($a, $b) {
  if (length($a)[0] != length($b)[0]) {
    return "Error: lengths must be equal";
  }
  if ( (pir::typeof($a[0]) eq 'Float') &&
       (pir::typeof($a[0]) eq 'Float') ) {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_stats_correlation' };
    @ans[0] := $fun($a, 1, $b, 1, length($a)[0]);
    return @ans;
  } else {
    print("Only cor(float, float) is available at this time");
  }
}

sub log($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_sf_log' };
    my $i;
    $i := length($arg)[0] - 1;
    while ($i >= 0) {
      @ans[$i] := $fun($arg[$i]);
      $i := $i - 1;
    }
    return @ans;
  } else {
    print("Only log(Float) is available at this time");
  }
}

sub exp($arg) {
  if (pir::typeof($arg[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    my $fun :=
      Q:PIR { %r = get_global ['GSL'], 'gsl_sf_exp' };
    my $i;
    $i := length($arg)[0] - 1;
    while ($i >= 0) {
      @ans[$i] := $fun($arg[$i]);
      $i := $i - 1;
    }
    return @ans;
  } else {
    print("Only exp(Float) is available at this time");
  }
}



