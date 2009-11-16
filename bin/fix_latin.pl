#!/usr/bin/perl

=head1 NAME

fix_latin.pl - A perl script that renames latin files to utf8

=head1 USAGE

 $ fix_latin.pl <file> [file2] ...;

=head1 DESCRIPTION

Rename files with latin "æøå" to utf8 "æøå".

=cut

for(@ARGV) {
    my $old = $_;
    my $new = $_;

    $new = s/\xE6/æ/g;
    $new = s/\xF8/ø/g;
    $new = s/\xE5/å/g;
    $new = s/\xC6/Æ/g;
    $new = s/\xD8/Ø/g;
    $new = s/\xC5/Å/g;

    if($old ne $new) {
        link $old, $new;
        unlink $old;
    }
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
