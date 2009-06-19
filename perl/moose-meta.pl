#!/local/bin/perl-nms

=head1 NAME

moose-meta.pl - Print meta information about Moose class

=head1 USAGE

 $ moose-meta.pl My::Class
 $ moose-meta.pl /path/to/My/Class.pm
 $ moose-meta.pl -I path/to/lib ...;

=head1 DESCRIPTION

Will traverse the C<class_precedence_list()> and print all attributes,
class attributes and methods.

A "*" (star) infront of the method/attr means that it has been overridden
by a superclass.

=head1 EXAMPLE OUTPUT

 =head1 NAME

 Foo::Bar - /path/to/Foo/Bar.pm

 =head1 OBJECT ATTRIBUTES

   attr_foo
   attr_bar

 =head1 CLASS ATTRIBUTES

   class_attr_foo
   class_attr_bar

 =head1 METHODS

   method_foo
   method_bar

=cut

use strict;
use warnings;
use Getopt::Long;
use List::Util qw/first/;

my(%ARGS, %cache);

{
    my($file, $class);

    GetOptions(\%ARGS, qw/I=s@/);

    unshift @INC, @{ $ARGS{'I'} } if($ARGS{'I'});

    $file  = shift @ARGV or exec perldoc => $0;
    $class = get_class_name($file);

    $class->can('meta') or die "Class $class has no 'meta' attribute\n";

    print_attribute_and_methods($class);

    exit 0;
}

=head1 FUNCTIONS

=head2 print_attribute_and_methods

 print_attribute_and_methods($class_name);

=cut

sub print_attribute_and_methods  {
    my $class = shift;

    for my $p ($class->meta->class_precedence_list) {
        my $meta = $p->meta;
        my $file = $p;

        $file   =~ s,::,/,g;
        $file  .=  ".pm";
        $file   =  first { /$file/ } values %INC;
        $file ||=  q(/dev/null);

        print "=head1 NAME\n\n$p - $file\n\n";

        if(my @attr = $meta->get_attribute_list) {
            print_list(object_attributes => \@attr);
        }

        if($meta->can('get_class_attribute_list')) {
            if(my @class_attr = $meta->get_class_attribute_list) {
                print_list(class_attributes => \@class_attr);
            }
        }

        if(my @methods = $meta->get_method_list) {
            print_list(methods => \@methods);
        }
    }
}

=head2 print_list

 print_list($list_type => [...]);

=cut

sub print_list {
    my $type = shift;
    my $list = shift;
    my $id   = uc $type;

    $id =~ s/_/ /g;

    print "=head1 $id\n\n";

    for my $name (sort @$list) {
        if($cache{$type}->{$name}++) {
            print "* $name\n";
        }
        else {
            print "  $name\n";
        }
    }

    print "\n";
}

=head2 get_class_name

 $class_name = get_class_name($file);
 $class_name = get_class_name($class_name);

=cut

sub get_class_name {
    my $file = shift || q(NOT_AVAILABLE);
    my $class;

    if(-e $file) { # file
        my $name;

        open(my $CLASS, "<", $file) or die $!;
        while(<$CLASS>) {
            next unless(/package\s+([^;]+)/);
            $class = $1;
            last;
        }

        unless($class) {
            die "Could not find class name from $file\n";
        }

        do $file or die $@;

        $name =  $class;
        $name =~ s,::,/,g;
        $name .= ".pm";

        $INC{$name} = $file;
    }
    else { # if($file =~ /::/) { # classname
        $class = $file;
        eval "require $class" or die $@;
    }

    return $class;
}

=head1 AUTHOR

Jan Henning Thorsen

=cut
