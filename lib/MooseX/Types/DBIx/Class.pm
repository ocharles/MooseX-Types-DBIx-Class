package MooseX::Types::DBIx::Class;
# ABSTRACT: MooseX::Types for DBIx::Class objects

use strict;
use warnings;

use MooseX::Types -declare => [qw(
    BaseResultSet
    BaseResultSource
    BaseRow
    BaseSchema

    ResultSet
    ResultSource
    Row
    Schema
)];

use MooseX::Types::Moose qw(Maybe Str RegexpRef);
use MooseX::Types::Parameterizable qw(Parameterizable);
use Moose::Util::TypeConstraints;

class_type BaseResultSet, { class => 'DBIx::Class::ResultSet' };

class_type BaseResultSource, { class => 'DBIx::Class::ResultSource' };

class_type BaseRow, { class => 'DBIx::Class::Row' };

class_type BaseSchema, { class => 'DBIx::Class::Schema' };

subtype ResultSet,
    as Parameterizable[BaseResultSet, Maybe[Str]],
    where {
        my($rs, $source_name) = @_;
        return is_BaseResultSet($rs) && (!$source_name || $rs->result_source->source_name eq $source_name);
    };

subtype ResultSource,
    as Parameterizable[BaseResultSource, Maybe[Str]],
    where {
        my($rs, $source_name) = @_;
        return is_BaseResultSource($rs) && (!$source_name || $rs->source_name eq $source_name);
    };

subtype Row,
    as Parameterizable[BaseRow, Maybe[Str]],
    where {
        my($row, $source_name) = @_;
        return is_BaseRow($row) && (!$source_name || $row->result_source->source_name eq $source_name);
    };

subtype Schema,
    as Parameterizable[BaseSchema, Maybe[RegexpRef|Str]],
    where {
        my($schema, $pattern) = @_;
        return is_BaseSchema($schema) && (!$pattern || ref($schema) =~ m/$pattern/);
    };
1;

=head1 SYNOPSIS

    # in your Moose class
    use MooseX::Types::DBIx::Class qw(ResultSet Row);

    # non-parameterized usage
    has any_resultset => (
        is  => 'ro',
        isa => ResultSet
    );

    # this attribute must be a DBIx::Class::ResultSet object from your "Album" ResultSet class
    has albums_rs => (
        is  => 'ro',
        isa => ResultSet['Album']
    );

    # this attribute must be a DBIx::Class::Row object from your "Album" Result class
    has album => (
        is  => 'ro',
        isa => Row['Album']
    );

    # subtyping works as expected
    use MooseX::Types -declare => [qw(RockAlbum DecadeAlbum)];
    use Moose::Util::TypeConstraints;

    subtype RockAlbum,
        as Row['Album'],
        where { $_->genre eq 'Rock' };

    # Further parameterization!
    use MooseX::Types::Parameterizable qw(Parameterizable);

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

This simply provides some L<MooseX::Types> style types for often
shared L<DBIx::Class> objects.

=head1 TYPES

Each of the types below first ensures the appropriate C<isa>
relationship. If the (optional) parameter is specified, it constrains
the value further in some way.  These types do not define any coercions.

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
