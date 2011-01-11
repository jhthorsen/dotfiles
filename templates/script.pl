#!/usr/bin/env perl

=head1 NAME

myapp.pl - Executable for App

=head1 SEE ALSO

=cut

use App;

exit App->new_with_options->run;
