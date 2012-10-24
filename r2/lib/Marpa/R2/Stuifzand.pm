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

package Marpa::R2::Stuifzand;

use 5.010;
use strict;
use warnings;

use integer;
use utf8;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '2.023_002';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R2::Internal::Stuifzand;

use English qw( -no_match_vars );

sub do_arg0 { return $_[1]; }

sub do_rules {
    shift;
    return [ map { @{$_} } @_ ];
}

sub do_priority_rule {
    my ( undef, $lhs, undef, $priorities ) = @_;
    my $priority_count = scalar @{$priorities};
    my @rules          = ();
    for my $priority_ix ( 0 .. $priority_count - 1 ) {
        my $priority = $priority_count - ( $priority_ix + 1 );
        for my $alternative ( @{ $priorities->[$priority_ix] } ) {
            push @rules, [ $priority, @{$alternative} ];
        }
    } ## end for my $priority_ix ( 0 .. $priority_count - 1 )
    if ( scalar @rules <= 1 ) {

        # If there is only one rule,
        my ( $priority, $assoc, $rhs, $action ) = @{ $rules[0] };
        my @action_kv;
        push @action_kv, action => $action if defined $action;
        return [ { lhs => $lhs, rhs => $rhs, @action_kv } ];
    } ## end if ( scalar @rules <= 1 )
    my $do_arg0_full_name = __PACKAGE__ . q{::} . 'do_arg0';
    my @xs_rules          = (
        {   lhs    => $lhs,
            rhs    => [ $lhs . '_0' ],
            action => $do_arg0_full_name
        },
        (   map {
                ;
                {   lhs => ( $lhs . '_' . ( $_ - 1 ) ),
                    rhs => [ $lhs . '_' . ($_) ],
                    action => $do_arg0_full_name
                }
            } 1 .. $priority_count - 1
        )
    );
    RULE: for my $rule (@rules) {
        my ( $priority, $assoc, $rhs, $action ) = @{$rule};
        my @action_kv = ();
        push @action_kv, action => $action if defined $action;
        my @new_rhs       = @{$rhs};
        my @arity         = grep { $new_rhs[$_] eq $lhs } 0 .. $#new_rhs;
        my $length        = scalar @{$rhs};
        my $current_exp   = $lhs . '_' . $priority;
        my $next_priority = $priority + 1;
        $next_priority = 0 if $next_priority >= $priority_count;
        my $next_exp = $lhs . '_' . $next_priority;

        if ( not scalar @arity ) {
            push @xs_rules,
                {
                lhs => $current_exp,
                rhs => \@new_rhs,
                @action_kv
                };
            next RULE;
        } ## end if ( not scalar @arity )

        if ( scalar @arity == 1 ) {
            die 'Unnecessary unit rule in priority rule' if $length == 1;
            $new_rhs[ $arity[0] ] = $current_exp;
        }
        DO_ASSOCIATION: {
            if ( $assoc eq 'L' ) {
                $new_rhs[ $arity[0] ] = $current_exp;
                for my $rhs_ix ( @arity[ 1 .. $#arity ] ) {
                    $new_rhs[$rhs_ix] = $next_exp;
                }
                last DO_ASSOCIATION;
            } ## end if ( $assoc eq 'L' )
            if ( $assoc eq 'R' ) {
                $new_rhs[ $arity[-1] ] = $current_exp;
                for my $rhs_ix ( @arity[ 0 .. $#arity - 1 ] ) {
                    $new_rhs[$rhs_ix] = $next_exp;
                }
                last DO_ASSOCIATION;
            } ## end if ( $assoc eq 'R' )
            if ( $assoc eq 'G' ) {
                for my $rhs_ix ( @arity[ 0 .. $#arity ] ) {
                    $new_rhs[$rhs_ix] = $lhs . '_0';
                }
                last DO_ASSOCIATION;
            } ## end if ( $assoc eq 'G' )
            die qq{Unknown association type: "$assoc"};
        } ## end DO_ASSOCIATION:
        push @xs_rules, { lhs => $current_exp, rhs => \@new_rhs, @action_kv };
    } ## end RULE: for my $rule (@rules)
    return [@xs_rules];
} ## end sub do_priority_rule

sub do_empty_rule {
    my ( undef, $lhs, undef, $action ) = @_;
    return [ { lhs => $lhs, rhs => [], @{ $action || [] } } ];
}

sub do_quantified_rule {
    my ( undef, $lhs, undef, $rhs, $quantifier, $action ) = @_;
    my @action_kv;
    push @action_kv, action => $action if defined $action;
    return [
        {   lhs => $lhs,
            rhs => [$rhs],
            min => ( $quantifier eq q{+} ? 1 : 0 ),
            @action_kv
        }
    ];
} ## end sub do_quantified_rule

sub do_simple_rule {
    shift;
    return {
        @{ $_[0] },
        rhs => [ $_[2] ],
        @{ $_[3] || [] }
    };
} ## end sub do_simple_rule

sub do_priority1 {
    shift;
    return [ $_[0] ];
}

sub do_priority3 {
    shift;
    return [ $_[0], @{ $_[2] } ];
}
sub do_full_alternative { shift; return [ ( $_[0] // 'L' ), $_[1], $_[2] ]; }
sub do_bare_alternative { shift; return [ ( $_[0] // 'L' ), $_[1], undef ] }

sub do_alternatives_1 {
    shift;
    return [ $_[0] ];
}

sub do_alternatives_3 {
    shift;
    return [ $_[0], @{ $_[2] } ];
}
sub do_lhs { shift; return $_[0]; }
sub do_array { shift; return [@_]; }
sub do_arg1         { return $_[2]; }
sub do_right_adverb { return 'R' }
sub do_left_adverb  { return 'L' }
sub do_group_adverb { return 'G' }

sub do_what_I_mean {

    # Throw away the per-parse variable.
    shift;

    # Throw away any undef's
    my @children = grep {defined} @_;

    # Return what's left
    return scalar @children > 1 ? \@children : shift @children;
} ## end sub do_what_I_mean

# Given a recognizer, an input,
# a reference to an array
# mapping Earley sets to input positions,
# and symbol,
# return the start and end earley sets
# of the last such symbol completed,
# undef if there was none.
sub last_completed_range {
    my ( $grammar, $recce, $symbol ) = @_;
    my @sought_rules =
        grep { my ($lhs) = $grammar->rule($_); $lhs eq $symbol; }
        $grammar->rule_ids();
    die "Looking for completion of non-existent rule lhs: $symbol"
        if not scalar @sought_rules;
    my $latest_earley_set = $recce->latest_earley_set();
    my $earley_set        = $latest_earley_set;

    # Initialize to one past the end, so we can tell if there were no hits
    my $first_origin = $latest_earley_set + 1;
    EARLEY_SET: while ( $earley_set >= 0 ) {
        my $report_items = $recce->progress($earley_set);
        ITEM: for my $report_item ( @{$report_items} ) {
            my ( $rule_id, $dot_position, $origin ) = @{$report_item};
            next ITEM if $dot_position != -1;
            next ITEM if not scalar grep { $_ == $rule_id } @sought_rules;
            next ITEM if $origin >= $first_origin;
            $first_origin = $origin;
        } ## end ITEM: for my $report_item ( @{$report_items} )
        last EARLEY_SET if $first_origin <= $latest_earley_set;
        $earley_set--;
    } ## end EARLEY_SET: while ( $earley_set >= 0 )
    return if $earley_set < 0;
    return ( $first_origin, $earley_set );
} ## end sub last_completed_range

# Given a string, an earley set to position mapping,
# and two earley sets, return the slice of the string
sub input_slice {
    my ( $input, $positions, $start, $end ) = @_;
    return if not defined $start;
    my $start_position = $positions->[$start];
    my $length         = $positions->[$end] - $start_position;
    return substr $input, $start_position, $length;
} ## end sub input_slice

sub parse_rules {
    my ($string) = @_;

    # Track earley set positions in input,
    # for debuggging
    my @positions = (0);

    my $grammar = Marpa::R2::Grammar->new(
        {   start          => 'rules',
            actions        => __PACKAGE__,
            default_action => 'do_what_I_mean',
            rules          => [
                {   lhs    => 'rules',
                    rhs    => [qw/rule/],
                    action => 'do_rules',
                    min    => 1
                },
                {   lhs    => 'rule',
                    rhs    => [qw/lhs op_declare priorities/],
                    action => 'do_priority_rule'
                },
                {   lhs    => 'rule',
                    rhs    => [qw/lhs op_declare action/],
                    action => 'do_empty_rule'
                },
                {   lhs    => 'rule',
                    rhs    => [qw/lhs op_declare name quantifier action/],
                    action => 'do_quantified_rule'
                },

                {   lhs    => 'priorities',
                    rhs    => [qw(alternatives)],
                    action => 'do_priority1'
                },
                {   lhs    => 'priorities',
                    rhs    => [qw(alternatives op_tighter priorities)],
                    action => 'do_priority3'
                },

                {   lhs    => 'alternatives',
                    rhs    => [qw(alternative)],
                    action => 'do_alternatives_1',
                },
                {   lhs    => 'alternatives',
                    rhs    => [qw(alternative op_eq_pri alternatives)],
                    action => 'do_alternatives_3',
                },

                {   lhs    => 'alternative',
                    rhs    => [qw(adverb rhs action)],
                    action => 'do_full_alternative'
                },
                {   lhs    => 'alternative',
                    rhs    => [qw(adverb rhs)],
                    action => 'do_bare_alternative'
                },

                {   lhs    => 'adverb',
                    rhs    => [qw/op_group/],
                    action => 'do_group_adverb'
                },
                {   lhs    => 'adverb',
                    rhs    => [qw/op_right/],
                    action => 'do_right_adverb'
                },
                {   lhs    => 'adverb',
                    rhs    => [qw/op_left/],
                    action => 'do_left_adverb'
                },
                { lhs => 'adverb', rhs => [] },

                { lhs => 'action', rhs => [] },
                {   lhs    => 'action',
                    rhs    => [qw/op_arrow action_name/],
                    action => 'do_arg1'
                },
                {   lhs    => 'action',
                    rhs    => [qw/op_arrow name/],
                    action => 'do_arg1'
                },

                { lhs => 'lhs', rhs => [qw/name/], action => 'do_lhs' },

                { lhs => 'rhs',        rhs => [qw/names/] },
                { lhs => 'quantifier', rhs => [qw/op_plus/] },
                { lhs => 'quantifier', rhs => [qw/op_star/] },

                {   lhs    => 'names',
                    rhs    => [qw/name/],
                    min    => 1,
                    action => 'do_array'
                },
            ],
        }
    );
    $grammar->precompute;

    my $thin_grammar = $grammar->thin();
    my $recce = Marpa::R2::Thin::R->new($thin_grammar);
    $recce->start_input();
    $recce->ruby_slippers_set(1);
    # Zero position must not be used
    my @token_values = (0);

    # Order matters !!!
    my @terminals = (
        [ 'op_right',      qr/:right\b/xms ],
        [ 'op_left',       qr/:left\b/xms ],
        [ 'op_group',      qr/:group\b/xms ],
        [ 'op_declare',    qr/::=/xms ],
        [ 'op_arrow',      qr/=>/xms ],
        [ 'op_tighter',    qr/[|][|]/xms ],
        [ 'op_eq_pri',     qr/[|]/xms ],
        [ 'reserved_name', qr/(::(whatever|undef))/xms ],
        [ 'op_plus',       qr/[+]/xms ],
        [ 'op_star',       qr/[*]/xms ],
        [ 'name',          qr/\w+/xms ],
        [ 'name',          qr/['][^']+[']/xms ],
    );

    my $length = length $string;
    pos $string = 0;
    my $latest_earley_set_ID = 0;
    TOKEN: while ( pos $string < $length ) {

        # skip whitespace
        next TOKEN if $string =~ m/\G\s+/gcxms;

        # read other tokens
        TOKEN_TYPE: for my $t (@terminals) {
            next TOKEN_TYPE if not $string =~ m/\G($t->[1])/gcxms;
            my $value_number = 1 + push @token_values, $1;
            my $string_position = pos $string;
            if ($recce->alternative( $grammar->thin_symbol( $t->[0] ),
                    $value_number, 1 ) != $Marpa::R2::Error::NONE
                )
            {
                die die q{Problem before position }, $string_position, ': ',
                    ( substr $string, $string_position, 40 ),
                    qq{\nToken rejected, "}, $t->[0], qq{", "$1"},
                    ;
            } ## end if ( $recce->alternative( $grammar->thin_symbol( $t->...)))
            $recce->earleme_complete();
            $latest_earley_set_ID = $recce->latest_earley_set();
            $positions[$latest_earley_set_ID] = $string_position;
            next TOKEN;
        } ## end TOKEN_TYPE: for my $t (@terminals)

        die q{No token at "}, ( substr $string, pos $string, 40 ),
            q{", position }, pos $string;
    } ## end TOKEN: while ( pos $string < $length )

    $thin_grammar->throw_set(0);
    my $bocage        = Marpa::R2::Thin::B->new( $recce, $latest_earley_set_ID );
    $thin_grammar->throw_set(1);
    if ( !defined $bocage ) {
        say $recce->show_progress() or die "say failed: $ERRNO";
        say input_slice( $string, \@positions,
            last_completed_range( $grammar, $recce, 'rule' ) )
            // 'No rule was completed';
        die 'Parse failed';
    } ## end if ( !defined $parse_ref )

    my $order         = Marpa::R2::Thin::O->new($bocage);
    my $tree          = Marpa::R2::Thin::T->new($order);
    $tree->next();
    my $valuator = Marpa::R2::Thin::V->new($tree);
    my @actions_by_rule_id;
    for my $rule_id ( grep { $thin_grammar->rule_length($_); }
        0 .. $thin_grammar->highest_rule_id() )
    {
        $valuator->rule_is_valued_set( $rule_id, 1 );
        $actions_by_rule_id[$rule_id] = $grammar->action($rule_id);
    }

    my @stack = ();
    STEP: while (1) {
        my ( $type, @step_data ) = $valuator->step();
        last STEP if not defined $type;
        if ( $type eq 'MARPA_STEP_TOKEN' ) {
            my ( undef, $token_value_ix, $arg_n ) = @step_data;
            $stack[$arg_n] = $token_values[$token_value_ix];
            next STEP;
        }
        if ( $type eq 'MARPA_STEP_RULE' ) {
            my ( $rule_id, $arg_0, $arg_n ) = @step_data;
            my $action = $actions_by_rule_id[$rule_id] // 'do_what_I_mean';
            if ( $action eq 'do_arg0' ) {
                $stack[$arg_0] = do_arg0( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_rules' ) {
                $stack[$arg_0] =
                    do_rules( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_priority_rule' ) {
                $stack[$arg_0] =
                    do_priority_rule( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_empty_rule' ) {
                $stack[$arg_0] =
                    do_empty_rule( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_quantified_rule' ) {
                $stack[$arg_0] =
                    do_quantified_rule( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_simple_rule' ) {
                $stack[$arg_0] =
                    do_simple_rule( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_priority1' ) {
                $stack[$arg_0] =
                    do_priority1( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_priority3' ) {
                $stack[$arg_0] =
                    do_priority3( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_full_alternative' ) {
                $stack[$arg_0] =
                    do_full_alternative( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_bare_alternative' ) {
                $stack[$arg_0] =
                    do_bare_alternative( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_alternatives_1' ) {
                $stack[$arg_0] =
                    do_alternatives_1( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_alternatives_3' ) {
                $stack[$arg_0] =
                    do_alternatives_3( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_lhs' ) {
                $stack[$arg_0] = do_lhs( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_array' ) {
                $stack[$arg_0] =
                    do_array( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_arg1' ) {
                $stack[$arg_0] = do_arg1( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_right_adverb' ) {
                $stack[$arg_0] =
                    do_right_adverb( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_left_adverb' ) {
                $stack[$arg_0] =
                    do_left_adverb( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            if ( $action eq 'do_group_adverb' ) {
                $stack[$arg_0] =
                    do_group_adverb( undef, @stack[ $arg_0 .. $arg_n ] );
                next STEP;
            }
            $stack[$arg_0] =
                do_what_I_mean( undef, @stack[ $arg_0 .. $arg_n ] );
            next STEP;
        } ## end if ( $type eq 'MARPA_STEP_RULE' )
        if ( $type eq 'MARPA_STEP_NULLING_SYMBOL' ) {
            my ( $symbol_id, $arg_0 ) = @step_data;
            $stack[$arg_0] = undef;
            next STEP;
        }
        die "Unexpected step type: $type";
    } ## end STEP: while (1)

    my $parse = $stack[0];

    return $parse;
} ## end sub parse_rules

1;

# vim: expandtab shiftwidth=4: