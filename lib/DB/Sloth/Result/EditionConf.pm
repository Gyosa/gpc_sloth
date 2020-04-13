use utf8;
package DB::Sloth::Result::EditionConf;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::EditionConf

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

=head1 TABLE: C<edition_conf>

=cut

__PACKAGE__->table("edition_conf");

=head1 ACCESSORS

=head2 edition_conf_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'edition_conf_edition_conf_id_seq'

=head2 edition_conf_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 edition_conf_description

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=head2 edition_conf_conference_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 edition_conf_ville

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 edition_conf_date_debut

  data_type: 'date'
  is_nullable: 1

=head2 edition_conf_date_fin

  data_type: 'date'
  is_nullable: 1

=head2 edition_conf_date_limite_soumission

  data_type: 'date'
  is_nullable: 1

=head2 edition_conf_consignes

  data_type: 'varchar'
  is_nullable: 1
  size: 10000

=head2 edition_conf_langue

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 edition_conf_pays

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 edition_conf_site

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=cut

__PACKAGE__->add_columns(
  "edition_conf_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "edition_conf_edition_conf_id_seq",
  },
  "edition_conf_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "edition_conf_description",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
  "edition_conf_conference_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "edition_conf_ville",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "edition_conf_date_debut",
  { data_type => "date", is_nullable => 1 },
  "edition_conf_date_fin",
  { data_type => "date", is_nullable => 1 },
  "edition_conf_date_limite_soumission",
  { data_type => "date", is_nullable => 1 },
  "edition_conf_consignes",
  { data_type => "varchar", is_nullable => 1, size => 10000 },
  "edition_conf_langue",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "edition_conf_pays",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "edition_conf_site",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
);

=head1 PRIMARY KEY

=over 4

=item * L</edition_conf_id>

=back

=cut

__PACKAGE__->set_primary_key("edition_conf_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<edition_conf_edition_conf_nom_key>

=over 4

=item * L</edition_conf_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("edition_conf_edition_conf_nom_key", ["edition_conf_nom"]);

=head1 RELATIONS

=head2 edition_conf_conference

Type: belongs_to

Related object: L<DB::Sloth::Result::Conference>

=cut

__PACKAGE__->belongs_to(
  "edition_conf_conference",
  "DB::Sloth::Result::Conference",
  { conference_id => "edition_conf_conference_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-20 17:59:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OTdaxJXf7vVR9Id7ZRQdXw


sub dfv_profil_creation {
    return {
        required => [ qw/edition_conf_nom edition_conf_conference_id/ ],
        optional => [ qw/edition_conf_consignes 
                      edition_conf_description 
                      edition_conf_ville
                      edition_conf_date_debut
                      edition_conf_date_fin
                      edition_conf_date_limite_soumission
                      edition_conf_consignes
                      edition_conf_langue
                      edition_conf_pays
                      edition_conf_site/
                      ],
        filters => 'trim',
        constraint_methods => {
            edition_conf_nom => [{
                constraint_method => qr/^([\s\S]){1,60}([\s\.])?/,
                name => 'Nom du hors série',
            }],
            edition_conf_description => [{
                constraint_method => qr/^([\s\S]){1,10000}([\s\.])?/,
                name => 'Description',
            }],
            edition_conf_langue => [{
                constraint_method => qr/^([\s\S]){1,60}([\s\.])?/,
                name => 'Langue',
            }],
            edition_conf_consignes => [{
                constraint_method => qr/^([\s\S]){0,10000}([\s\.])?/,
                name => 'Consignes de rédaction',
            }],
            edition_conf_conference_id => [{ 
                constraint_method => qr/^([\d])*/,
                name => 'Id de la conference auquel est rattaché le hors série',
            }]
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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
