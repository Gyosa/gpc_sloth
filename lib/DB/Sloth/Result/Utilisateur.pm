use utf8;
package DB::Sloth::Result::Utilisateur;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Utilisateur

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

=head1 TABLE: C<utilisateur>

=cut

__PACKAGE__->table("utilisateur");

=head1 ACCESSORS

=head2 utilisateur_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'utilisateur_utilisateur_id_seq'

=head2 utilisateur_auth

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 utilisateur_nom

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=head2 utilisateur_prenom

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=cut

__PACKAGE__->add_columns(
  "utilisateur_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "utilisateur_utilisateur_id_seq",
  },
  "utilisateur_auth",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "utilisateur_nom",
  { data_type => "varchar", is_nullable => 0, size => 60 },
  "utilisateur_prenom",
  { data_type => "varchar", is_nullable => 0, size => 60 },
);

=head1 PRIMARY KEY

=over 4

=item * L</utilisateur_id>

=back

=cut

__PACKAGE__->set_primary_key("utilisateur_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<utilisateur_utilisateur_auth_key>

=over 4

=item * L</utilisateur_auth>

=back

=cut

__PACKAGE__->add_unique_constraint("utilisateur_utilisateur_auth_key", ["utilisateur_auth"]);

=head1 RELATIONS

=head2 est_membres

Type: has_many

Related object: L<DB::Sloth::Result::EstMembre>

=cut

__PACKAGE__->has_many(
  "est_membres",
  "DB::Sloth::Result::EstMembre",
  { "foreign.est_membre_utilisateur_id" => "self.utilisateur_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participations

Type: has_many

Related object: L<DB::Sloth::Result::Participation>

=cut

__PACKAGE__->has_many(
  "participations",
  "DB::Sloth::Result::Participation",
  { "foreign.participation_utilisateur_id" => "self.utilisateur_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 est_membre_groupes

Type: many_to_many

Composing rels: L</est_membres> -> est_membre_groupe

=cut

__PACKAGE__->many_to_many("est_membre_groupes", "est_membres", "est_membre_groupe");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-20 18:04:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Q+mNOh08Lo7UfVg8OL/46Q


__PACKAGE__->many_to_many("participation_articles", "participations", "participation_article");

# le profil de creation d'un utilisateur (demande par Data::FormValidator)
sub dfv_profil_creation {
    return {
        required => [ qw/utilisateur_auth utilisateur_nom utilisateur_prenom / ],
        #optional => [ qw/cli_adresse/ ],
        filters => 'trim',
        constraint_methods => {
            utilisateur_nom => [{
                constraint_method => qr/^\D+/,
                name => 'usr_nom',
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


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
