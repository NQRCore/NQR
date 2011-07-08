# Copyright (C) 2010, Parrot Foundation.
# Copyright (C) 2011, Michael Kane and John Emerson.

=head1 TITLE

nqr.pir - A Not Quite R compiler.

=head2 Description

This is the entry point for the Not Quite R compiler.

=head2 Functions

=over 4

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the Not Quite R compiler.

=cut

.sub 'main' :main
    .param pmc args

    load_language 'nqr'

    $P0 = compreg 'nqr'
    $P1 = $P0.'command_line'(args)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

