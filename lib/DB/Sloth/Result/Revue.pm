use utf8;
package DB::Sloth::Result::Revue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Revue

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

=head1 TABLE: C<revue>

=cut

__PACKAGE__->table("revue");

=head1 ACCESSORS

=head2 revue_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'revue_revue_id_seq'

=head2 revue_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 revue_description

  data_type: 'varchar'
  is_nullable: 1
  size: 500

=head2 revue_theme

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 revue_site_web

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=head2 revue_consignes

  data_type: 'varchar'
  is_nullable: 1
  size: 10000

=cut

__PACKAGE__->add_columns(
  "revue_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "revue_revue_id_seq",
  },
  "revue_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "revue_description",
  { data_type => "varchar", is_nullable => 1, size => 500 },
  "revue_theme",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "revue_site_web",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
  "revue_consignes",
  { data_type => "varchar", is_nullable => 1, size => 10000 },
);

=head1 PRIMARY KEY

=over 4

=item * L</revue_id>

=back

=cut

__PACKAGE__->set_primary_key("revue_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<revue_revue_nom_key>

=over 4

=item * L</revue_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("revue_revue_nom_key", ["revue_nom"]);

=head1 RELATIONS

=head2 hors_series

Type: has_many

Related object: L<DB::Sloth::Result::HorsSerie>

=cut

__PACKAGE__->has_many(
  "hors_series",
  "DB::Sloth::Result::HorsSerie",
  { "foreign.hors_serie_revue_id" => "self.revue_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-20 17:59:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mRDEAbW1X921kN8O1MTiIw

__PACKAGE__->has_many(
  "articles",
  "DB::Sloth::Result::Article",
  { "foreign.article_revue_id" => "self.revue_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# le profil de creation d'une revue (demande par Data::FormValidator)
sub dfv_profil_creation {
    return {
        required => [ qw/revue_nom/ ],
        optional => [ qw/revue_description revue_theme revue_site_web revue_consignes/ ],
        filters => 'trim',
        constraint_methods => {
            revue_nom => [{
                constraint_method => qr/^([\s\S]){1,60}([\s\.])?/,
                name => 'Nom de la revue',
            }],
            revue_description => [{
                constraint_method => qr/^([\s\S]){0,500}([\s\.])?/,
                name => 'Description de la revue',
            }],
            revue_theme => [{
                constraint_method => qr/^([\s\S]){0,60}([\s\.])?/,
                name => 'Thème de la revue',
            }],
            revue_site_web => [{
                constraint_method => qr/^([\s\S]){0,1000}([\s\.])?/,
                name => 'Site web de la revue',
            }],
            revue_consignes => [{
                constraint_method => qr/^([\s\S]){0,10000}([\s\.])?/,
                name => 'Consignes de la revue',
            }],
        },
        msgs => {
            format => '%s',
            prefix => '',
            missing => 'obligatoire',
            invalid => 'valeur incorrecte',
            constraints => {
                usr_nom => 'doit contenir au moins un carac.',
            }
        },
    };
}


1;
