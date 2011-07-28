# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

=head1 TITLE

nqr.pir - A Not Quite R compiler.

=head2 Description

This is the base file for the Not Quite R compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PCT libraries,
and registers the compiler under the name 'nqr'.

=head2 Functions

=over 4

=item onload()

Creates the Note Quite R compiler using a C<PCT::HLLCompiler>
object.

=cut

.HLL 'nqr'
.loadlib 'io_ops'
#.loadlib 'squaak_group'            # JAY: Unchanged at the moment

.namespace []

.sub '' :anon :load
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash'
    parrotns.'export_to'(hllns, imports)

    # Load a subset of GSL functions:
    .local pmc lib, nci, Rlib
    loadlib lib, 'libgsl'
    dlfunc nci, lib, 'gsl_ran_gaussian_pdf', 'ddd'
   #set_global ['GSL'], 'gsl_ran_gaussian_pdf', nci
    dlfunc nci, lib, 'gsl_stats_mean', 'dpll'
    set_global ['GSL'], 'gsl_stats_mean', nci

  dlfunc nci, lib, 'gsl_stats_max', 'dpll'
  set_global ['GSL'], 'gsl_stats_max', nci
  dlfunc nci, lib, 'gsl_stats_max_index', 'lpll'
  set_global ['GSL'], 'gsl_stats_max_index', nci


    loadlib Rlib, 'libRmath'
    dlfunc nci, Rlib, 'R_rexp', 'dd'
    set_global ['R'], 'R_rexp', nci

.end

.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'
.include 'src/gen_compiler.pir'
.include 'src/gen_classes.pir'
.include 'src/gen_operators.pir'
.include 'src/gen_runtime.pir'
.include 'src/gen_runtimewinxed.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

