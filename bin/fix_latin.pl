#!/usr/bin/perl

for(@ARGV) {
    my $old = $_;

    s/\xE6/æ/g;
    s/\xF8/ø/g;
    s/\xE5/å/g;
    s/\xC6/Æ/g;
    s/\xD8/Ø/g;
    s/\xC5/Å/g;

    link $old, $_;
    unlink $old if($old ne $_);
}

exit;
__END__

=head1 NAME

fix_latin.pl - A perl script that renames latin files to utf8

=head1 USAGE

 $ fix_latin.pl *

=head1 DESCRIPTION

Renames æøå from latin encoding to utf8

=head1 AUTHOR

Jan Henning Thorsen

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
