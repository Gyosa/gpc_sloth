use utf8;
package DB::Sloth::Result::Fichier;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Fichier

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

=head1 TABLE: C<fichier>

=cut

__PACKAGE__->table("fichier");

=head1 ACCESSORS

=head2 fichier_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'fichier_fichier_id_seq'

=head2 fichier_nom

  data_type: 'varchar'
  is_nullable: 0
  size: 1024

=head2 fichier_type

  data_type: 'varchar'
  is_nullable: 0
  size: 1024

=head2 fichier_contenu

  data_type: 'bytea'
  is_nullable: 0

=head2 fichier_commentaire

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 fichier_date

  data_type: 'date'
  is_nullable: 0

=head2 fichier_article_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "fichier_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "fichier_fichier_id_seq",
  },
  "fichier_nom",
  { data_type => "varchar", is_nullable => 0, size => 1024 },
  "fichier_type",
  { data_type => "varchar", is_nullable => 0, size => 1024 },
  "fichier_contenu",
  { data_type => "bytea", is_nullable => 0 },
  "fichier_commentaire",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "fichier_date",
  { data_type => "date", is_nullable => 0 },
  "fichier_article_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</fichier_id>

=back

=cut

__PACKAGE__->set_primary_key("fichier_id");

=head1 RELATIONS

=head2 fichier_article

Type: belongs_to

Related object: L<DB::Sloth::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "fichier_article",
  "DB::Sloth::Result::Article",
  { article_id => "fichier_article_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 versions

Type: has_many

Related object: L<DB::Sloth::Result::Version>

=cut

__PACKAGE__->has_many(
  "versions",
  "DB::Sloth::Result::Version",
  { "foreign.version_fichier_id" => "self.fichier_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-20 18:37:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rqgrPibyZ5wbxeXwoj58fQ

# le profil de creation d'un fichier (demande par Data::FormValidator)
  sub dfv_profil_fichier {
  return {
    required => [ qw/fichier_nom fichier_contenu fichier_article_id fichier_type/ ],
    optional => [ qw/fichier_commentaire fichier_date/ ],
    filters => 'trim',
    constraint_methods => {
	
	fichier_nom => [{
	    constraint_method => qr/([\d\w\s])*/,
	    name => "Nom du fichier",
			}],
	fichier_article_id => [{
	    constraint_method => qr/\d*/,
	    name => "ID de l'article",
			 }],
       
	fichier_commmentaire => [{
	    constraint_method => qr/^([\s\S]){0,1000}([\s\.])/,
	    name => "commentaire du fichier",
			   }]
    },
    msgs => {
        format => '%s',
        prefix => '',
        missing => 'obligatoire',
        invalid => 'valeur incorrecte',
    }
  },
};


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
