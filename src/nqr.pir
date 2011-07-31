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
    loadlib lib, '/usr/local/lib/libgsl.so'
    dlfunc nci, lib, 'gsl_ran_gaussian_pdf', 'ddd'
    set_global ['GSL'], 'gsl_ran_gaussian_pdf', nci
    dlfunc nci, lib, 'gsl_cdf_gaussian_P', 'ddd'
    set_global ['GSL'], 'gsl_cdf_gaussian_P', nci
    dlfunc nci, lib, 'gsl_cdf_gaussian_Pinv', 'ddd'
    set_global ['GSL'], 'gsl_cdf_gaussian_Pinv', nci

  dlfunc nci, lib, 'gsl_stats_mean', 'dpll'
  set_global ['GSL'], 'gsl_stats_mean', nci
  dlfunc nci, lib, 'gsl_stats_variance', 'dpll'
  set_global ['GSL'], 'gsl_stats_variance', nci
  dlfunc nci, lib, 'gsl_stats_sd', 'dpll'
  set_global ['GSL'], 'gsl_stats_sd', nci
  dlfunc nci, lib, 'gsl_stats_covariance', 'dplpll'
  set_global ['GSL'], 'gsl_stats_covariance', nci
  dlfunc nci, lib, 'gsl_stats_correlation', 'dplpll'
  set_global ['GSL'], 'gsl_stats_correlation', nci

  # log, exp, sort
  dlfunc nci, lib, 'gsl_sf_log', 'dd'
  set_global ['GSL'], 'gsl_sf_log', nci
  dlfunc nci, lib, 'gsl_sf_exp', 'dd'
  set_global ['GSL'], 'gsl_sf_exp', nci
  dlfunc nci, lib, 'gsl_sort', 'vpll'
  set_global ['GSL'], 'gsl_sort', nci
  dlfunc nci, lib, 'gsl_sort_index', 'vppll'
  set_global ['GSL'], 'gsl_sort_index', nci

  dlfunc nci, lib, 'gsl_stats_min', 'dpll'
  set_global ['GSL'], 'gsl_stats_min', nci
  dlfunc nci, lib, 'gsl_stats_min_index', 'lpll'
  set_global ['GSL'], 'gsl_stats_min_index', nci

  dlfunc nci, lib, 'gsl_stats_max', 'dpll'
  set_global ['GSL'], 'gsl_stats_max', nci

  #say "Example GLS loading diagnostics:"
  dlfunc nci, lib, 'gsl_stats_max_index', 'lpll'
  #if nci goto true1
  #  say "  False gsl_stats_max_index"
  #  goto done1
  #true1:
  #  say "  Loaded gsl_stats_max_index"
  #done1:
  set_global ['GSL'], 'gsl_stats_max_index', nci

  dlfunc nci, lib, 'gsl_stats_int_max', 'ipll'
  #if nci goto true2
  #  say "  False gsl_stats_int_max"
  #  goto done2
  #true2:
  #  say "  Loaded gsl_stats_int_max"
  #done2:
  set_global ['GSL'], 'gsl_stats_int_max', nci
#  dlfunc nci, lib, 'gsl_stats_int_max_index', 'lpll'
#  set_global ['GSL'], 'gsl_stats_int_max_index', nci


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

