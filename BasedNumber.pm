package BasedNumber;

sub new {
    my ($proto, $num, $base) = (@_);
    $base ||= 0;
    my $proto = ref($proto) || $proto;
    my $self = {
    	number => $num,
	base => $base,
    };

    return bless $self, $proto;
}

sub base {
    my ($self) = (@_);
    return $self->{base};
}

sub num {
    my ($self) = (@_);
    return $self->{number};
}

sub string {
    my ($self) = (@_);
    return "$self->{number}e$self->{base}";
}

1;
