#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use BasedNumber;

use Term::ReadLine;

our ($a,$b,$c,$d,$e,$f,$g,$h,$i,$j,$k,$l,$m,$n,$o,$p,$q,$r,$s,$t,$u,$v,$w,$x,$y,$z);
my $term = Term::ReadLine->new('CayleyDickson Input');
my $prompt = ">> ";
my $out = \*STDOUT;

my $welcome = <<'WELCOME';
=== Cayley-Dickson Perl Shell ===
This is pretty much just a perl eval loop so: if you can perl-it you can do it.


Element
    * Elements can be specified as real numbers or pairs of the form [a,b] where a and b are elemnts of the same dimension
    * Note: In a pair, you must pair an element with another element of the same dimension

Function
    * mult - multiplies two elements
    * conj - conjugates an element
    * neg  - returns negation of an element
    * add  - adds two elements

Notation
    ei is used as the basis of the i'th dimension in a vector space with e0 being the real part

Example
    Basics:
        >> our $a = mult(2,2)
        4e0
        >> mult([1,2],[3,$a])
        -5e0 + 10e1

    Observing loss of commutitivty in quaternions:
        >> our $a = [[1,2],[3,4]]
        1e0 + 2e1 + 3e2 + 4e3

        >> our $b = [[5,6],[7,8]]
        5e0 + 6e1 + 7e2 + 8e3

        >> mult($a, $b)
        9e0 + 12e1 + 13e2 + 24e3 

        >> mult($b, $a)
        9e0 + 20e1 + 29e2 + 32e3

WELCOME


print $welcome;


my $line;
while(defined($line = $term->readline($prompt))) {
    print eval "Dumper($line)","\n";
    if($@) {
        print "Last command died: ".$@;
    }
}

sub human {
    my ($element) = (@_);
    my $list = [];
    decend($element, $list);
    my $string = "";
    my $count = 0;
    foreach my $mag (@$list) {
        $string .= " + " if($string);
        $string .= $mag->string();
        ++$count;
    }
    return $string;
}

sub decend {
    my ($element, $list) = (@_);
    #print "Got element ".Dumper($element);
    my $list2 = [];
    use Carp qw(longmess);
    die "Got non-ref element ".Dumper($element)."\n".longmess() if(!ref($element));
    if(ref($element) eq 'BasedNumber') {
        push(@$list, $element);
    }
    else {
        foreach my $part (@$element) {
            push(@$list2, decend($part, $list));
        }
    }
    return @$list2;
}

sub taged {
    my ($element) = (@_);
    my $ref = ref($element);
    if($ref eq 'BasedNumber') {
        return 1;
    }
    elsif($ref eq 'ARRAY') {
        foreach my $part (@$element) {
            return taged($part);
        }
    }
    return 0;
}

sub tag {
    my ($input, $basis) = (@_);
    $basis ||= 0;

    my $helper;
    $helper = sub {
        my ($element, $depth, $num) = (@_);
        
        if(!ref($element)) {
            my $result = BasedNumber->new($element,$num % 2**$depth);
	    return $result;
        }
        else {
	    my $count = 0;
            foreach my $part (@$element) {
	        $element->[$count] = $helper->($part, $depth + 1, $count);
		$count++;
            }
	    return $element;
        }
    };
    my $result = $helper->($input, $basis);
    return $result;
}

sub mult {
    my ($el1, $el2) = (@_);
    if(!taged($el1)) {
        $el1 = tag($el1);
    }
    if(!taged($el2)) {
        $el2 = tag($el2);
    }
    print "(".human($el1).") * (".human($el2).") = ";
    if(ref($el1) eq 'BasedNumber') {
        if(ref($el2) eq 'BasedNumber') {
	    # print "Multiplying ".Dumper($el1)." with ".Dumper($el2);
	    my $sign = basis_prod($el1->base(),$el2->base());
	    my $base = $el1->base() ^ $el2->base();
            my $result = BasedNumber->new($sign*$el1->num()*$el2->num(), $base);
	    print "(".human($result).")\n";
	    return $result;
        }
        else {
            die "Mismatched dimensions between elemnts\n"."left side: ".Dumper($el1)."right side: ".Dumper($el2);
        }
    }

    if(scalar(@$el1) != scalar(@$el2)) {
        die "Mismatched dimensions between elemnts\n"."left side: ".Dumper($el1)."right side: ".Dumper($el2);
    }

    my $a = $el1->[0];
    my $b = $el1->[1];
    my $c = $el2->[0];
    my $d = $el2->[1];

    if(ref($a) ne ref($b) || ref($a) ne ref($c) || ref($a) ne ref($d)) {
        die "Inconsistant references between multiplication elements\n"."left side: ".Dumper($el1)."right side: ".Dumper($el2);
    }

    print "\nNext level of recursion\n";
    my $result = [add(mult($a, $c), neg(mult($d,conj($b)))), add(mult(conj($a),$d), mult($c, $b))];

    print "(".human($result).")\n";
    return $result;
}

sub basis_prod {
    my ($base1, $base2) = (@_);
    # print "Calculating base product for $base1 and $base2\n";
    my $twist = twist_entry($base1,$base2);
    return $twist;
}

sub twist_entry {
    my ($base1, $base2) = (@_);
    my $dimension = (sort ($base1, $base2))[1];
    if($dimension == 0) {
    	return 1;
    }
    my $table = generate_cayley_table($dimension);
    return $table->[$base1]->[$base2];
}

sub add {
    my ($el1, $el2) = (@_);
    print "(".human($el1).") + (".human($el2).")";

    if(!taged($el1)) {
        $el1 = tag($el1);
    }
    if(!taged($el2)) {
        $el2 = tag($el2);
    }
    if(ref($el1) eq 'BasedNumber') {
        if(ref($el2) eq 'BasedNumber') {
	    if($el1->base() eq $el2->base()) {
		my $base = $el1->base();
                my $result = BasedNumber->new($el1->num() + $el2->num(),$base);
                print " = ".human($result)."\n";
		return $result;
	    }
	    else {
	        my $result = [$el1, $el2];
                print " = ".human($result)."\n";
		return $result;
	    }
        }
        else {
            die "Mismatched dimensions between elemnts\n"."left side: ".Dumper($el1)."right side: ".Dumper($el2);
        }
    }

    my $a = $el1->[0];
    my $b = $el1->[1];
    my $c = $el2->[0];
    my $d = $el2->[1];
    if(ref($a) ne ref($b) || ref($a) ne ref($c) || ref($a) ne ref($d)) {
        die "Inconsistant references between addition elements\n"."left side: ".Dumper($el1)."right side: ".Dumper($el2);
    }
    print "\nNext level of recursion\n";
    my $result = [add($a, $c), add($b, $d)];
    print " = ".human($result)."\n";
    return $result;
}

sub neg {
    my ($element) = (@_);
    print "-(".human($element).") = ";
    if(ref($element) eq 'ARRAY') {
        my $a = $element->[0];
        my $b = $element->[1];
	my $result = [neg($a), neg($b)];
	print "(".human($result).")\n";
	return $result;
    }
    else {
	my $result = BasedNumber->new(-$element->num(), $element->base());
	print " (".human($result).")\n";
	return $result;
    }
}

sub conj {
    my ($element) = (@_);
    if(ref($element) eq 'ARRAY') {
        if(!taged($element)) {
            $element = tag($element);
        }
        my $a = $element->[0];
        my $b = $element->[1];
	my $result = [conj($a), neg($b)];
	return $result;
    }
    else {
        return $element;
    }
}

sub generate_cayley_table {
    my ($dimension) = (@_);
    my $table = [['A0']];
    if($dimension == 0) {
        return [1];
    }
    else {
        decompose($table, $dimension - 1);
    }
}


sub decompose {

our $map = {
    'A0' =>[['A0', 'A'], ['B', '-B']],
    A => [['A', 'A'], ['C', '-C']],
    B => [['B', '-C'], ['B', 'C']],
    '-B' => [['-B', 'C'], ['-C', '-B']],
    'C' =>  [['C', '-C'], ['-C', '-C']],
    '-C' => [['-C', 'C'], ['C', 'C']],
};

our $final = {
    A0 => [[1, 1], [1,-1]],
    A => [[1,1], [1,-1]],
    B => [[1,-1], [1,1]],
    '-B' => [[-1,1],[-1,-1]],
    'C' => [[1,-1],[-1,-1]],
    '-C' => [[-1,1],[1,1]],
};

    my ($table, $dimension) = (@_);
    my $new_table = [];
    my $current_row = 0;

    if($dimension == 0) {
        for my $col (@$table) {
            $new_table->[$current_row] ||= [];
            $new_table->[$current_row+1] ||= [];
            for my $row (@$col) {
                my $matrix = $final->{$row};
                my $row1 = $matrix->[0];
                my $row2 = $matrix->[1];
                push(@{$new_table->[$current_row]}, @{$row1});
                push(@{$new_table->[$current_row+1]}, @{$row2});
            }
            $current_row += 2;
        }
        return $new_table;
    }
    else {
        for my $col (@$table) {
            $new_table->[$current_row] ||= [];
            $new_table->[$current_row+1] ||= [];
            for my $row (@$col) {
                my $matrix = $map->{$row};
                my $row1 = $matrix->[0];
                my $row2 = $matrix->[1];
                push(@{$new_table->[$current_row]}, @{$row1});
                push(@{$new_table->[$current_row+1]}, @{$row2});
            }
            $current_row += 2;
        }
        decompose($new_table, $dimension - 1);
    }
}
