#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

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


print Dumper(generate_cayley_table(1));
#print $welcome;
#
#
#my $line;
#while(defined($line = $term->readline($prompt))) {
#    print eval "human($line)","\n";
#    if($@) {
#        print "Last command died: ".$@;
#    }
#}

sub human {
    my ($element) = (@_);
    my $list = [];
    decend($element, $list);
    my $string = "";
    my $count = 0;
    foreach my $mag (@$list) {
        $string .= " + " if($string);
        $string .= "$mag"."e$count";
        ++$count;
    }
    return $string;
}

sub decend {
    my ($element, $list) = (@_);
    my $list2 = [];
    if(!ref($element)) {
        push(@$list, $element);
    }
    else {
        foreach my $part (@$element) {
            push(@$list2, decend($part, $list));
        }
    }
    return @$list2;
}

sub mult {
    my ($el1, $el2) = (@_);
    if(!ref($el1)) {
        if(!ref($el2)) {
            return $el1 * $el2;
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

    # how are we handling negation
    return [add(mult($a, $c), neg(mult(conj($d),$b))), add(mult($d, $a), mult($b, conj($c)))];
}

sub add {
    my ($el1, $el2) = (@_);
    if(!ref($el1)) {
        if(!ref($el2)) {
            return $el1 + $el2;
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
        die "Inconsistant references between multiplication elements\n"."left side: ".Dumper($el1)."right side: ".Dumper($el2);
    }
    return [add($a, $b), add($b, $d)];
}

sub neg {
    my ($element) = (@_);
    if(ref($element)) {
        my $a = $element->[0];
        my $b = $element->[1];
        return [neg($a), neg($b)];
    }
    else {
        return -$element;
    }
}

sub conj {
    my ($element) = (@_);
    if(ref($element)) {
        my $a = $element->[0];
        my $b = $element->[1];
        return [conj($a), neg($b)];
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
