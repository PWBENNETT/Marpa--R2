#!perl
use 5.010;
use strict;
use warnings;

use Marpa::XS;
use MarpaX::Simple::Rules 'parse_rules';

my $basic_pascal_rules = parse_rules(<<"RULES");
     A ::= a
     A ::= E
     E ::= Null
RULES

sub do_pascal {
    my ( $g, $n ) = @_;
    my $parse_count = 0;
    my $recce = Marpa::XS::Recognizer->new( { grammar => $g } );

    # Just in case
    $recce->set( { max_parses => 999, end => $n } );
    for my $token_ix ( 0 .. $n - 1 ) {
        defined $recce->read('a') or die "Cannot read char $token_ix";
    }
    $parse_count++ while $recce->value();
    return $parse_count;
} ## end sub do_pascal

my @pascal_numbers = (
    '1',
    '1 1',
    '1 2 1',
    '1 3 3 1',
    '1 4 6 4 1',
    '1 5 10 10 5 1',
    '1 6 15 20 15 6 1',
    '1 7 21 35 35 21 7 1',
    '1 8 28 56 70 56 28 8 1',
    '1 9 36 84 126 126 84 36 9 1',
    '1 10 45 120 210 252 210 120 45 10 1',
);

for my $n ( 0 .. 10 ) {

    my $variable_rule = parse_rules( 'S ::=' . ($n ? (' A' x $n) : ' Null'));
    my $grammar = Marpa::XS::Grammar->new(
        {   start => 'S',
            rules => [ map { @{$_} } $basic_pascal_rules, $variable_rule ],
	    lhs_terminals => 0,
            warnings => ( $n ? 1 : 0 ),
        }
    );

    $grammar->precompute();

    my $expected = join q{ }, $pascal_numbers[$n];
    my $actual = join q{ }, 0, map { do_pascal( $grammar, $_ ) } 0 .. $n;
    say "Expected: $expected";
    say "  Actual: $actual";
    say( $actual eq $expected ? 'OK' : 'MISMATCH' );

} ## end for my $n ( 0 .. 10 )
