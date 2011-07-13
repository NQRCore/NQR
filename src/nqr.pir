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
#.loadlib 'squaak_group'            # JAY: Unchanged at the moment

.namespace []

.sub '' :anon :load
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash'
    parrotns.'export_to'(hllns, imports)

  # ATTEMPTED LIBRARY LOADING UP FRONT?
  .local pmc lib, nci
  loadlib lib, 'libgsl'
  dlfunc nci, lib, 'gsl_ran_gaussian_pdf', 'ddd'
  set_global 'gsl_ran_gaussian_pdf', nci

.end

.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'
.include 'src/gen_compiler.pir'
.include 'src/gen_classes.pir'
.include 'src/gen_runtime.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

