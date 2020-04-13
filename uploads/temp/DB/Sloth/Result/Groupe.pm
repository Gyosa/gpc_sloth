use utf8;
package DB::Sloth::Result::Groupe;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Groupe

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

=head1 TABLE: C<groupe>

=cut

__PACKAGE__->table("groupe");

=head1 ACCESSORS

=head2 groupe_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'groupe_groupe_id_seq'

=head2 groupe_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 groupe_description

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=cut

__PACKAGE__->add_columns(
  "groupe_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "groupe_groupe_id_seq",
  },
  "groupe_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "groupe_description",
  { data_type => "varchar", is_nullable => 1, size => 150 },
);

=head1 PRIMARY KEY

=over 4

=item * L</groupe_id>

=back

=cut

__PACKAGE__->set_primary_key("groupe_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<groupe_groupe_nom_key>

=over 4

=item * L</groupe_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("groupe_groupe_nom_key", ["groupe_nom"]);

=head1 RELATIONS

=head2 est_membres

Type: has_many

Related object: L<DB::Sloth::Result::EstMembre>

=cut

__PACKAGE__->has_many(
  "est_membres",
  "DB::Sloth::Result::EstMembre",
  { "foreign.est_membre_groupe_id" => "self.groupe_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 est_membre_utilisateurs

Type: many_to_many

Composing rels: L</est_membres> -> est_membre_utilisateur

=cut

__PACKAGE__->many_to_many(
  "est_membre_utilisateurs",
  "est_membres",
  "est_membre_utilisateur",
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-08 09:11:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t+j9otxzQnXg2e6LqBM/Jg

#__PACKAGE__->many_to_many('user_membre','est_membre','est_membre_utilisateur_id');

# le profil de creation d'un groupe (demande par Data::FormValidator)
sub dfv_profil_creation {
    return {
        required => [ qw/groupe_nom/ ],
        optional => [ qw/groupe_description/ ],
        filters => 'trim',
        constraint_methods => {
            groupe_nom => [{
                constraint_method => qr/[a-zA-Z]{*}/,
                name => 'grp_nom',
			   }],
	    groupe_description => [{
		constraint_method => qr/[a-zA-Z0-9]{*}/,
		name => 'grp_description',
				   }]
        },
        msgs => {
            format => '%s',
            prefix => '',
            missing => 'obligatoire',
            invalid => 'valeur incorrecte',
            constraints => {
                grp_nom => 'doit commencer par au moins trois caractère alphabétique',
		grp_description => 'doit contenir uniquement des caractère alpanumérique',
            }
        },
    };
}

# le profil de modification d'un groupe (demande par Data::FormValidator)
sub dfv_profil_modification {
    return {
        #required => [ qw/groupe_nom/ ],
        optional => [ qw/groupe_description/ ],
        filters => 'trim',
        constraint_methods => {
	    groupe_description => [{
		constraint_method => qr/\d*/,
		name => 'grp_description',
				   }]
        },
        msgs => {
            format => '%s',
            prefix => '',
            missing => 'obligatoire',
            invalid => 'valeur incorrecte',
            constraints => {
		grp_description => 'doit contenir uniquement des caractère alpanumérique',
            }
        },
    };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
