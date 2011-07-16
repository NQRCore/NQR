#! nqp
# Copyright (C) 2011, Michael Kane and John Emerson.

# Vectorized operators

# This while-looping avoids resizing after the first one...
# Avoiding the swap of $a and $b would require extra versions
# of the code... maybe worth it eventually for performance.
sub &infix:<+>($a, $b) {
  my $tmp;
  my $i;
  if (length($a) == 1) {
      $tmp := $a;
      $a := $b;
      $b := $tmp;
  } # So now if one is length 1, it is the $b
  if (length($b) == 1) {
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      $i := length($a) - 1;
      while ($i >= 0) {
        @ans[$i] := $a[$i] + $b[0];
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      $i := length($a) - 1;
      while ($i >= 0) {
        @ans[$i] := $a[$i] + $b[0];
        $i--;
      }
      return @ans;
    }
  } else { # Equal-length vectors (this could be some linear
           # algebra library call, eventually?):
    if (length($a) == length($b)) {
    if ( (pir::typeof($a[0]) eq 'Float') ||
         (pir::typeof($b[0]) eq 'Float') ) {
      my @ans := pir::new("ResizableFloatArray");
      $i := length($a) - 1;
      while ($i >= 0) {
        @ans[$i] := $a[$i] + $b[$i];
        $i--;
      }
      return @ans;
    } else {
      my @ans := pir::new("ResizableIntegerArray");
      $i := length($a) - 1;
      while ($i >= 0) {
        @ans[$i] := $a[$i] + $b[$i];
        $i--;
      }
      return @ans;
    }
    } else {
      print("Vector recycling not allowed in infix:<+>\n");
      return 0;
    }
  }
}
