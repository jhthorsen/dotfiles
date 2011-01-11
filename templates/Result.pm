package My::Module;

=head1 NAME

My::Module - Result class for table my_table

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

use Moose;

extends 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw/ Core /);
__PACKAGE__->table('my_table');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
        is_auto_increment => 1,
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('id');
#__PACKAGE__->add_unique_constraint([qw/ foo_column /]);
#__PACKAGE__->has_many(
#    foos => 'My::Schema::Result::OtherResult',
#    { 'foreign.id' => 'self.foo_id' },
#    { 'cascade_delete' => 0, is_foreign_key_constraint => 0 },
#);

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Top::Module>.

=cut

1;
