#!/usr/bin/perl
# Copyright 2012 Jeffrey Kegler
# This file is part of Marpa::R2.  Marpa::R2 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R2.  If not, see
# http://www.gnu.org/licenses/.

# Synopsis for Stuizand interface

use 5.010;
use strict;
use warnings;
use Test::More tests => 3;

use lib 'inc';
use Marpa::R2::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R2::Display
# name: Stuifzand Synopsis

use Marpa::R2;

my $grammar = Marpa::R2::Grammar->new(
    {   start          => 'Expression',
        actions        => 'My_Actions',
        default_action => 'do_first_arg',
        rules          => [ <<'END_OF_RULES' ]
Expression ::=
    Number
    | <op_lparen> Expression <op_rparen> action => do_parens assoc => group
   || Expression op_pow Expression action => do_pow assoc => right
   || Expression op_times Expression action => do_multiply
    | Expression op_divide Expression action => do_divide
   || Expression op_add Expression action => do_add
    | Expression op_subtract Expression action => do_subtract
END_OF_RULES
    }
);

$grammar->precompute();

my @terminals = (
    [ Number    => qr/\d+/xms,    "Number" ],
    [ op_lparen => qr/[(]/xms,    'Left parenthesis' ],
    [ op_rparen => qr/[)]/xms,    'Right parenthesis' ],
    [ op_pow    => qr/[*][*]/xms, 'Exponentiation' ],         # order matters!
    [ op_times  => qr/[*]/xms,    'Multiplication operator' ],
    [ op_divide => qr/[\/]/xms,   'Division operator' ],
    [ op_add    => qr/[+]/xms,    'Addition operator' ],
    [ op_subtract => qr/[-]/xms,  'Subtraction operator' ],
    [ op_pow      => qr/[\^]/xms, 'Exponentiation operator' ],
);

sub my_parser {
    my ( $grammar, $string ) = @_;
    my $recce         = Marpa::R2::Recognizer->new( { grammar => $grammar } );
    my $length        = length $string;
    my $last_position = 0;
    pos $string = $last_position;
    TOKEN: while (1) {
        $last_position = pos $string;
        last TOKEN if $last_position >= $length;
        next TOKEN if $string =~ m/\G\s+/gcxms;    # skip whitespace
        TOKEN_TYPE: for my $t (@terminals) {
            my ( $token_name, $regex, $long_name ) = @{$t};
            next TOKEN_TYPE if not $string =~ m/\G($regex)/gcxms;
            next TOKEN if defined $recce->read( $token_name, $1 );
            die
                qq{Parser rejected token "$long_name" at position $last_position, before "},
                substr( $string, $last_position, 40 ), q{"};
        } ## end TOKEN_TYPE: for my $t (@terminals)
        die qq{No token found at position $last_position, before "},
            substr( $string, pos $string, 40 ), q{"};
    } ## end TOKEN: while (1)
    my $value_ref = $recce->value;
    return $value_ref ? ${$value_ref} : 'No Parse';
} ## end sub my_parser

say my_parser($grammar, '42*2+7/3');
say my_parser($grammar, '42*(2+7)/3');
say my_parser($grammar, '2**7-3');
say my_parser($grammar, '2**(7-3)');

# First arg is per-parse variable
sub My_Actions::do_parens { shift; return $_[1] }
sub My_Actions::do_add { shift; return $_[0] + $_[2] }
sub My_Actions::do_subtract { shift; return $_[0] - $_[2] }
sub My_Actions::do_multiply { shift; return $_[0] * $_[2] }
sub My_Actions::do_divide { shift; return $_[0] / $_[2] }
sub My_Actions::do_pow { shift; return $_[0] ** $_[2] }
sub My_Actions::do_first_arg { shift; return shift; }

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4: