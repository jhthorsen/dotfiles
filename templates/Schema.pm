package My::Module;

=head1 NAME

My::Module - Schema module for DBIx::Class

=head1 VERSION

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Moose;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    #default_resultset_class => 'ResultSet',
);

=head1 ATTRIBUTES

=head1 METHODS

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<My::App>.

=cut

1;
