use utf8;
package DB::Sloth::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Article

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

=head1 TABLE: C<article>

=cut

__PACKAGE__->table("article");

=head1 ACCESSORS

=head2 article_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'article_article_id_seq'

=head2 article_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 article_revue_id

  data_type: 'integer'
  is_nullable: 1

=head2 article_hors_serie_id

  data_type: 'integer'
  is_nullable: 1

=head2 article_statut_id

  data_type: 'integer'
  is_nullable: 0

=head2 article_edition_conf_id

  data_type: 'integer'
  is_nullable: 1

=head2 article_lien

  data_type: 'varchar'
  is_nullable: 1
  size: 2000

=head2 article_mot_cle

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 article_resume

  data_type: 'varchar'
  is_nullable: 1
  size: 2000

=head2 article_date_limite_soumission

  data_type: 'date'
  is_nullable: 1

=head2 article_date_archivage

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "article_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "article_article_id_seq",
  },
  "article_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "article_revue_id",
  { data_type => "integer", is_nullable => 1 },
  "article_hors_serie_id",
  { data_type => "integer", is_nullable => 1 },
  "article_statut_id",
  { data_type => "integer", is_nullable => 0 },
  "article_edition_conf_id",
  { data_type => "integer", is_nullable => 1 },
  "article_lien",
  { data_type => "varchar", is_nullable => 1, size => 2000 },
  "article_mot_cle",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "article_resume",
  { data_type => "varchar", is_nullable => 1, size => 2000 },
  "article_date_limite_soumission",
  { data_type => "date", is_nullable => 1 },
  "article_date_archivage",
  { data_type => "date", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</article_id>

=back

=cut

__PACKAGE__->set_primary_key("article_id");

=head1 RELATIONS

=head2 fichiers

Type: has_many

Related object: L<DB::Sloth::Result::Fichier>

=cut

__PACKAGE__->has_many(
  "fichiers",
  "DB::Sloth::Result::Fichier",
  { "foreign.fichier_article_id" => "self.article_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participations

Type: has_many

Related object: L<DB::Sloth::Result::Participation>

=cut

__PACKAGE__->has_many(
  "participations",
  "DB::Sloth::Result::Participation",
  { "foreign.participation_article_id" => "self.article_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-18 16:08:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v9ktsdpbxPF/6+x08AZ/Ig

__PACKAGE__->belongs_to(
  "article_statut",
  "DB::Sloth::Result::Statut",
  { statut_id => "article_statut_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
    );

__PACKAGE__->belongs_to(
  "article_hors_serie",
  "DB::Sloth::Result::HorsSerie",
  { hors_serie_id => "article_hors_serie_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

__PACKAGE__->belongs_to(
  "article_edition_conf",
  "DB::Sloth::Result::EditionConf",
  { edition_conf_id => "article_edition_conf_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

__PACKAGE__->belongs_to(
  "article_revue",
  "DB::Sloth::Result::Revue",
  { revue_id => "article_revue_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
    
=head2 participation_utilisateurs

Type: many_to_many

Composing rels: L</participations> ->participations_utilisateur

=cut

__PACKAGE__->many_to_many(
  "participations_utilisateurs",
  "participations",
  "participation_utilisateur",
);

# le profil de creation d'une communication (demande par Data::FormValidator)
sub dfv_profil_creation_communication {
  return {
    required => [ qw/article_nom article_statut_id article_edition_conf_id article_date_limite_soumission/ ],
    optional => [ qw/article_lien article_mot_cle article_resume article_date_archivage/ ],
    filters => 'trim',
    constraint_methods => {

      statut_defini => [{
        constraint_method => sub ([qw/article_statut_id/]) {
          my $article_statut_id = @_;
          my $statut = schema->resultset('Statut')->find($article_statut_id);
          if (defined $statut and not $statut eq ""){
            return 1;
          };
        },
        name => "Statut non existant",
      }],

      # edition_conf_definie => [{
      #   constraint_method => sub ([qw/article_edition_conf_id/]) {
      #     my $article_edition_conf_id = @_;
      #     if (defined $article_edition_conf_id and not $article_edition_conf_id eq "") {
      #       my $edition_conf = schema->resultset('EditionConf')->find($article_edition_conf_id);
      #         if (defined $edition_conf and not $edition_conf eq ""){
      #           return 1;
      #         };
      #     }
      #     return 0;
      #   },
      #   name => "Édition de conférence non existante",
      # }],

      # isNotPublication => [{
      #   constraint_method => sub ([qw/article_revue_id article_hors_serie_id/]) {
      #     my $article_revue_id = shift;
      #     my $article_hors_serie_id = shift;
      #     if (defined $article_revue_id or not $article_revue_id eq "") {
      #       return 0;
      #     }
      #     if (defined $article_hors_serie_id or not $article_hors_serie_id eq "") {
      #       return 0;
      #     }
      #     return 1;
      #   },
      #   name => "Champs pour publications saisis",
      # }],

      # dateLimiteValide => [{
      #   constraint_method => sub ([qw/article_date_limite_soumission article_edition_conf_id/]) {
      #     my $date_limite = shift;
      #     my $article_edition_conf_id = shift;
      #     my $edition_conf = schema->resultset('EditionConf')->find($article_edition_conf_id);
      #     if (defined $edition_conf and not $edition_conf eq ""){
      #       my $date_limite_conf = $edition_conf->edition_conf_date_limite_soumission;
      #       if ($date_limite <= $date_limite_conf){
      #         return 1;
      #       }
      #     }
      #     return 0;
      #   },
      #   name => "Date limite de soumission"
      # }],

      article_nom => [{
        constraint_method => qr/^([\s\S]){0,60}([\s\.])?/,
        name => "Nom de l'article",
      }],
      article_lien => [{
        constraint_method => qr/^([\s\S]){0,2000}([\s\.])?/,
        name => "Lien vers l'article",
      }],
      article_mot_cle => [{
        constraint_method => qr/^([\s\S]){0,60}([\s\.])?/,
        name => "Lien vers l'article",
      }],
      article_resume => [{
        constraint_method => qr/^([\s\S]){0,1000}([\s\.])?/,
        name => "Résumé de l'article",
      }],
      article_date_limite_soumission => [{
      constraint_method => qr/\d{4}-\d{2}-\d{2}/,
      name => "date limite de soumission: mauvais format",
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

  # le profil de creation d'une  publication (demande par Data::FormValidator)
  sub dfv_profil_publication {
  return {
    required => [ qw/article_nom article_statut_id article_revue_id article_date_limite_soumission/ ],
    optional => [ qw/article_hors_serie_id article_lien article_date_archivage article_mot_cle article_resume / ],
    filters => 'trim',
    constraint_methods => {

	statut_defini => [{
	    constraint_method => sub ([qw/article_statut_id/]) {
		my $article_statut_id = @_;
		my $statut = schema->resultset('Statut')->find($article_statut_id);
		if (defined $statut and not $statut eq ""){
		    return 1;
		};
	    },
	    name => "Statut non existant",
			  }],
	
	# article_revue_id => [{
	#     constraint_method => qr/\d*/,
	#     name => "id de la revue correspondante",
	# 		     }],
	# article_hors_serie_id => [{
	#     constraint_method => qr/\d*/,
	#     name => "id du hors serie correspondant",
	# 		     }],

	article_date_limite_soumission => [{
	    constraint_method => qr/\d{4}-\d{2}-\d{2}/,
	    name => "date limite de soumission: mauvais format",
					   }],
	article_nom => [{
	    constraint_method => qr/^([\s\S_]){0,100}([\s\.])?/,
	    name => "Nom de l'article",
			}],
	article_lien => [{
	    constraint_method => qr/^([\s\S]){0,2000}([\s\.])?/,
	    name => "Lien vers l'article",
			 }],
	article_mot_cle => [{
	    constraint_method => qr/^([\s\S_]){0,1000}([\s\.])?/,
	    name => "Lien vers l'article",
			    }],
	article_resume => [{
	    constraint_method => qr/^([\s\S]){0,1000}([\s\.])?/,
	    name => "Résumé de l'article",
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
