#! nqp
# Copyright (C) 2011, Michael Kane and John Emerson.

# This file is intended for class definitions.  For now,
# we'll leave the class ABC and XYZ example, which are used
# in the classtest() function and t/nqr.t.

# Class vector is a more serious attempt at something, but
# the 'is' approach (inheritance?) isn't succeeed and we
# fell back on the 'delegation' approach recommended by
# whiteknight as a workaround.  We might need >= 3.5.0.


# Attempts to get the 'is' inheritance working
#INIT { 
#    pir::load_bytecode('P6object.pbc');
#    pir::get_hll_global__PS("P6metaclass").register("FixedFloatArray");
#}

# Alternative is 'delegating'
#class vector {
#    has $!array;
#    method foo() {
#        say('Hello from vector');
#    }
#    method init() is pirflags<:vtable("init")> {
#        $!array := pir::new__PS("ResizablePMCArray");
#    }
#}

#class vector is FixedFloatArray;
#INIT {
#  class vector is Integer {
#
#  }
#}

#####################################################################
# Delete once we have other stable examples up and running.
# See also classtest() in Runtime.pm and t/nqr.t

#class ABC {
#    method foo() {
#        say('ok 7');
#    }

#    method bar() {
#        say('ok 9');
#    }
#}

#class XYZ is ABC {
#    method foo() {
#        say('ok 8');
#    }
#}




