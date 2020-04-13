use utf8;
package DB::Sloth::Result::HorsSerie;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::HorsSerie

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

=head1 TABLE: C<hors_serie>

=cut

__PACKAGE__->table("hors_serie");

=head1 ACCESSORS

=head2 hors_serie_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'hors_serie_hors_serie_id_seq'

=head2 hors_serie_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 hors_serie_revue_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 hors_serie_consignes

  data_type: 'varchar'
  is_nullable: 1
  size: 10000

=head2 hors_serie_date_limite_soumission

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "hors_serie_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "hors_serie_hors_serie_id_seq",
  },
  "hors_serie_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "hors_serie_revue_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "hors_serie_consignes",
  { data_type => "varchar", is_nullable => 1, size => 10000 },
  "hors_serie_date_limite_soumission",
  { data_type => "date", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</hors_serie_id>

=back

=cut

__PACKAGE__->set_primary_key("hors_serie_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<hors_serie_hors_serie_nom_key>

=over 4

=item * L</hors_serie_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("hors_serie_hors_serie_nom_key", ["hors_serie_nom"]);

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<DB::Sloth::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "DB::Sloth::Result::Article",
  { "foreign.article_hors_serie_id" => "self.hors_serie_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hors_serie_revue

Type: belongs_to

Related object: L<DB::Sloth::Result::Revue>

=cut

__PACKAGE__->belongs_to(
  "hors_serie_revue",
  "DB::Sloth::Result::Revue",
  { revue_id => "hors_serie_revue_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


use utf8;

# le profil de creation d'une commande (demande par Data::FormValidator)
use Data::FormValidator::Constraints::DateTime qw(:all);
use Regexp::Common;

sub dfv_profil_creation {
    return {
        required => [ qw/hors_serie_nom hors_serie_revue_id hors_serie_date_limite_soumission/ ],
        optional => [ qw/hors_serie_consignes hors_serie_date_publication/ ],
        filters => 'trim',
        constraint_methods => {
            hors_serie_nom => [{
                constraint_method => qr/^([\s\S]){1,60}([\s\.])?/,
                name => 'Nom du hors série',
            }],
            hors_serie_consignes => [{
                constraint_method => qr/^([\s\S]){0,10000}([\s\.])?/,
                name => 'Consignes de rédaction',
            }],
            hors_serie_revue_id => [{
                constraint_method => qr/^([\d])*/,
                name => 'Id de la revue auquel est rattaché le hors série',
            }],
            hors_serie_date_limite_soumission => to_datetime('%Y-%m-%d'),
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
