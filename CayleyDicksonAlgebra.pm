package CayleyDicksonAlgebra;

use strict;
use warnings;

use overload 
    '~' => \&conjugate;

sub new {
    my ($class, $order) = (@_);
    die("Please specify the order of the construction\n") if (!defined($order));
    $class = ref($class) || $class;
    my $self = {
        order => $order,
    };
    return bless $self, $class;
}

sub conjugate {
    my ($self, $other, $swap) = (@_);
    return $self;
}

1;
