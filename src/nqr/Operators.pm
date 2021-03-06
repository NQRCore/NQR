#! nqp
# Copyright (C) 2011, John Emerson and Michael Kane.

# Vectorized operators

# This while()-looping avoids resizing after the first one...
# Avoiding the swap of $a and $b would require extra versions
# of the code... maybe worth it eventually for performance.

# The use of the pir operators are important for performance
# because NQP would put things in PMCs, operate, then unpack...

# See RANDOM.NOTES for pmichaud's comments on i vs I in the ops,
# this might be very important.

########################
# Basic operators first:

sub &infix:<+>($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::add__NNN($a[0], $b[$i]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::add__III($a[0], $b[$i]);
        $i--;
      }
      return @ans;
    }
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::add__NNN($a[$i], $b[0]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::add__III($a[$i], $b[0]);
        $i--;
      }
      return @ans;
    }
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::add__NNN($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::add__III($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    }
  } else {
    print("Vector recycling not allowed in infix: +\n");
    return 0;
  }
}

sub &infix:<->($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::sub__NNN($a[0], $b[$i]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::sub__III($a[0], $b[$i]);
        $i--;
      }
      return @ans;
    }
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::sub__NNN($a[$i], $b[0]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::sub__III($a[$i], $b[0]);
        $i--;
      }
      return @ans;
    }
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::sub__NNN($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::sub__III($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    }
  } else {
    print("Vector recycling not allowed in infix: -\n");
    return 0;
  }
}


sub &infix:<*>($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::mul__NNN($b[$i], $a[0]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::mul__III($b[$i], $a[0]);
        $i--;
      }
      return @ans;
    }
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::mul__NNN($a[$i], $b[0]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::mul__III($a[$i], $b[0]);
        $i--;
      }
      return @ans;
    }
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      while ($i >= 0) {
        @ans[$i] := pir::mul__NNN($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      while ($i >= 0) {
        @ans[$i] := pir::mul__III($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    }
  } else {
    print("Vector recycling not allowed in infix: *\n");
    return 0;
  }
}

## Result will always be Float, as with R.
sub &infix:</>($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::div__NNN($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::div__NNN($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::div__NNN($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: /\n");
    return 0;
  }
}

####################
# Sequence operator:

sub &infix:<:>($a, $b) {
  if (pir::elements($a) != 1) {
    warning("(:) first numerical expression > 1 element, only the first used");
  }
  if (pir::elements($b) != 1) {
    warning("(:) second numerical expression > 1 element, only the first used");
  }
  my $by := [1];      # This is a gotcha...
  return seq($a, $b, $by);
}

#######################
# Relational operators:

sub &infix:«==»($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::iseq__iPP($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::iseq__iPP($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::iseq__iPP($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: == ");
    return 0;
  }
}

sub &infix:«!=»($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isne__iPP($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isne__iPP($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isne__iPP($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: !=");
    return 0;
  }
}

sub &infix:«<»($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::islt__iPP($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::islt__iPP($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::islt__iPP($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: <");
    return 0;
  }
}

sub &infix:«<=»($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isle__iPP($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isle__iPP($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isle__iPP($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: <=");
    return 0;
  }
}

sub &infix:«>»($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isgt__iPP($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isgt__iPP($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isgt__iPP($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: >");
    return 0;
  }
}

sub &infix:«>=»($a, $b) {
  my $i;
  if (pir::elements($a) == 1) {
    $i := pir::elements($b) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isge__iPP($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::elements($b) == 1) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isge__iPP($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (pir::elements($a) == pir::elements($b)) {
    $i := pir::elements($a) - 1;
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::isge__iPP($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix: >=");
    return 0;
  }
}

sub &prefix:<!>($a) {
  my $i;
  $i := pir::elements($a) - 1;
  my @ans := pir::new("ResizableIntegerArray");
  while ($i >= 0) {
    @ans[$i] := pir::isfalse__iP($a[$i]);
    $i--;
  }
  return @ans;
}

sub &prefix:<->($a) {
  my $i;
  $i := pir::elements($a) - 1;
  if (pir::typeof($a[0]) eq 'Float') {
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::neg__NN($a[$i]);
      $i--;
    }
    return @ans;
  }
  if (pir::typeof($a[0]) eq 'Integer') {
    my @ans := pir::new("ResizableIntegerArray");
    while ($i >= 0) {
      @ans[$i] := pir::neg__II($a[$i]);
        $i--;
      }
    return @ans;
  }
  print("invalid argument to unary operator: -\n");
  return 0;
}




