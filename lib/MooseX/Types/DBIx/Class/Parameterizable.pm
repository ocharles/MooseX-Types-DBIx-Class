package MooseX::Types::DBIx::Class::Parameterizable;

# ABSTRACT: Parameterizable MooseX::Types for DBIx::Class objects

use strict;
use warnings;
use MooseX::Types -declare => [qw(
    Schema
    ResultSource
    ResultSet
    Row
)];
use MooseX::Types::Moose qw(Maybe Str RegexpRef);

use MooseX::Types::DBIx::Class (
    Schema       => { -as => 'BaseSchema' },
    ResultSet    => { -as => 'BaseResultSet' },
    ResultSource => { -as => 'BaseResultSource' },
    Row          => { -as => 'BaseRow' }
);

use MooseX::Types::Parameterizable qw(Parameterizable);
use Moose::Util::TypeConstraints;
use namespace::autoclean;

subtype ResultSet,
    as Parameterizable[BaseResultSet, Maybe[Str]],
    where {
        my($rs, $source_name) = @_;
        return MooseX::Types::DBIx::Class::is_ResultSet($rs) && (!$source_name || $rs->result_source->source_name eq $source_name);
    };

subtype ResultSource,
    as Parameterizable[BaseResultSource, Maybe[Str]],
    where {
        my($rs, $source_name) = @_;
        return MooseX::Types::DBIx::Class::is_ResultSource($rs) && (!$source_name || $rs->source_name eq $source_name);
    };

subtype Row,
    as Parameterizable[BaseRow, Maybe[Str]],
    where {
        my($row, $source_name) = @_;
        return MooseX::Types::DBIx::Class::is_Row($row) && (!$source_name || $row->result_source->source_name eq $source_name);
    };

subtype Schema,
    as Parameterizable[BaseSchema, Maybe[RegexpRef|Str]],
    where {
        my($schema, $pattern) = @_;
        return MooseX::Types::DBIx::Class::is_Schema($schema) && (!$pattern || ref($schema) =~ m/$pattern/);
    };
1;

=head1 SYNOPSIS

    # in your Moose class
    use MooseX::Types::DBIx::Class::Parameterizable qw(ResultSet Row);

    # this attribute must be a DBIx::Class::Row object from your "Album" Result class
    has album => (
        is  => 'ro',
        isa => Row['Album']
    );

    # this attribute must be a DBIx::Class::ResultSet object from your "Album" ResultSet class
    has other_albums => (
        is  => 'ro',
        isa => ResultSet['Album']
    );

    # for convenience, these types can act like their non-parameterized base types too
    has any_resultset => (
        is  => 'ro',
        isa => ResultSet
    );

    # subtyping works as expected
    use MooseX::Types -declare => [qw(RockAlbum DecadeAlbum)];
    use Moose::Util::TypeConstraints;
    subtype RockAlbum,
        as Row['Album'],
        where { $_->genre eq 'Rock' };

    # Further parameterization!
    use MooseX::Types::Parameterizable;
    subtype DecadeAlbum,
        as Parameterizable[Row['Album'], Str],
        where {
             my($album, $decade) = @_;
             return Row(['Album'])->check($album) && substr($album->year, -2, 1) eq substr($decade, 0, 1);
        };

    subtype EightiesRock,
        as DecadeAlbum[80],
        where { $_->genre eq 'Rock' };

    has eighties_rock_album => (
        is  => 'ro',
        isa => EightiesRock,
    );

=head1 DESCRIPTION

This module provides parameterizable versions of the same types provided
by L<MooseX::Types::DBIx::Class>.

=head1 TYPES

=over 4

=item ResultSet[$source_name]

This type constraint requires the object to be an instance of
L<DBIx::Class::ResultSet> and to have the specified C<$source_name> (if specified).

=item ResultSource[$source_name]

This type constraint requires the object to be an instance of
L<DBIx::Class::ResultSource> and to have the specified C<$source_name> (if specified).

=item Row[$source_name]

This type constraint requires the object to be an instance of
L<DBIx::Class::Row> and to have the specified C<$source_name> (if specified).

=item Schema[$class_name | qr/pattern_to_match/]

This type constraint is present mostly for completeness and requires the
object to be an instance of L<DBIx::Class::Schema> and to have a class
name that matches C<$class_name> or the regular expression if specified.

=back

=cut
