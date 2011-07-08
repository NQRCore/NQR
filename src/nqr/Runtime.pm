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

