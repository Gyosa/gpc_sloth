use utf8;
package DB::Sloth::Result::Statut;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Statut

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::FromValidators>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Core>

=back

=cut

__PACKAGE__->load_components("FromValidators", "InflateColumn::DateTime", "Core");

=head1 TABLE: C<statut>

=cut

__PACKAGE__->table("statut");

=head1 ACCESSORS

=head2 statut_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'statut_statut_id_seq'

=head2 statut_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 statut_description

  data_type: 'varchar'
  is_nullable: 1
  size: 500

=cut

__PACKAGE__->add_columns(
  "statut_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "statut_statut_id_seq",
  },
  "statut_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "statut_description",
  { data_type => "varchar", is_nullable => 1, size => 500 },
);

=head1 PRIMARY KEY

=over 4

=item * L</statut_id>

=back

=cut

__PACKAGE__->set_primary_key("statut_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<statut_statut_nom_key>

=over 4

=item * L</statut_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("statut_statut_nom_key", ["statut_nom"]);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-20 17:59:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TA/HuRnPzHoNrRhn0HVTvQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
