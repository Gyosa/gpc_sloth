use utf8;
package DB::Sloth::Result::Version;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Version

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

=head1 TABLE: C<version>

=cut

__PACKAGE__->table("version");

=head1 ACCESSORS

=head2 version_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'version_version_id_seq'

=head2 version_nom

  data_type: 'varchar'
  is_nullable: 0
  size: 1024

=head2 version_type

  data_type: 'varchar'
  is_nullable: 0
  size: 1024

=head2 version_contenu

  data_type: 'bytea'
  is_nullable: 0

=head2 version_nb

  data_type: 'integer'
  is_nullable: 1

=head2 version_commentaire

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 version_date

  data_type: 'date'
  is_nullable: 0

=head2 version_fichier_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "version_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "version_version_id_seq",
  },
  "version_nom",
  { data_type => "varchar", is_nullable => 0, size => 1024 },
  "version_type",
  { data_type => "varchar", is_nullable => 0, size => 1024 },
  "version_contenu",
  { data_type => "bytea", is_nullable => 0 },
  "version_nb",
  { data_type => "integer", is_nullable => 1 },
  "version_commentaire",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "version_date",
  { data_type => "date", is_nullable => 0 },
  "version_fichier_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</version_id>

=back

=cut

__PACKAGE__->set_primary_key("version_id");

=head1 RELATIONS

=head2 version_fichier

Type: belongs_to

Related object: L<DB::Sloth::Result::Fichier>

=cut

__PACKAGE__->belongs_to(
  "version_fichier",
  "DB::Sloth::Result::Fichier",
  { fichier_id => "version_fichier_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-20 18:04:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TNhungs0l3SnT7NclnKn9Q

# le profil de creation d'une version (demande par Data::FormValidator)
  sub dfv_profil_version {
  return {
    required => [ qw/version_nom version_contenu version_fichier_id version_type version_nb/ ],
    optional => [ qw/version_commentaire version_date/ ],
    filters => 'trim',
    constraint_methods => {
	
	version_nom => [{
	    constraint_method => qr/([\d\w\s])*/,
	    name => "Nom de la version du fichier",
			}],
	
	version_fichier_id => [{
	    constraint_method => qr/\d*/,
	    name => "ID du fichier",
			 }],
       
	version_commmentaire => [{
	    constraint_method => qr/^([\s\S]){0,1000}([\s\.])/,
	    name => "commentaire du version",
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
