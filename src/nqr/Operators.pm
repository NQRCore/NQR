#! nqp
# Copyright (C) 2011, Michael Kane and John Emerson.

# Vectorized operators

# This while-looping avoids resizing after the first one...
# Avoiding the swap of $a and $b would require extra versions
# of the code... maybe worth it eventually for performance.

# The use of the pir operators are important for performance
# because NQP would put things in PMCs, operate, then unpack...

sub &infix:<+>($a, $b) {
  my $i;
  if (length($a) == 1) {
    $i := length($b) - 1;
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
  if (length($b) == 1) {
    $i := length($a) - 1;
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
  if (length($a) == length($b)) {
    $i := length($a) - 1;
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
    print("Vector recycling not allowed in infix:<+>\n");
    return 0;
  }
}

sub &infix:<->($a, $b) {
  my $i;
  if (length($a) == 1) {
    $i := length($b) - 1;
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
  if (length($b) == 1) {
    $i := length($a) - 1;
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
  if (length($a) == length($b)) {
    $i := length($a) - 1;
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
    print("Vector recycling not allowed in infix:<->\n");
    return 0;
  }
}


sub &infix:<*>($a, $b) {
  my $i;
  if (length($a) == 1) {
    $i := length($b) - 1;
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
  if (length($b) == 1) {
    $i := length($a) - 1;
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
        @ans[$i] := pir::mul__III($a[$i], $b[$i]);
        $i--;
      }
      return @ans;
    }
  }
  # Below, equal sized, or else in trouble.
  if (length($a) == length($b)) {
    $i := length($a) - 1;
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
    print("Vector recycling not allowed in infix:<*>\n");
    return 0;
  }
}

## Result will always be Float, as with R.
sub &infix:</>($a, $b) {
  my $i;
  if (length($a) == 1) {
    $i := length($b) - 1;
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::div__NNN($a[0], $b[$i]);
      $i--;
    }
    return @ans;
  }
  if (length($b) == 1) {
    $i := length($a) - 1;
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::div__NNN($a[$i], $b[0]);
      $i--;
    }
    return @ans;
  }
  # Below, equal sized, or else in trouble.
  if (length($a) == length($b)) {
    $i := length($a) - 1;
    my @ans := pir::new("ResizableFloatArray");
    while ($i >= 0) {
      @ans[$i] := pir::div__NNN($a[$i], $b[$i]);
      $i--;
    }
    return @ans;
  } else {
    print("Vector recycling not allowed in infix:</>\n");
    return 0;
  }
}

sub &infix:<:>($a, $b) {
  if (length($a) != 1) {
    warning("(:) first numerical expression > 1 element, only the first used");
  }
  if (length($b) != 1) {
    warning("(:) second numerical expression > 1 element, only the first used");
  }
  my $by := [1];      # This is a gotcha...
  return seq($a, $b, $by);
}


