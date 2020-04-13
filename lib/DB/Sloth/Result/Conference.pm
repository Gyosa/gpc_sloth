use utf8;
package DB::Sloth::Result::Conference;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Conference

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

=head1 TABLE: C<conference>

=cut

__PACKAGE__->table("conference");

=head1 ACCESSORS

=head2 conference_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'conference_conference_id_seq'

=head2 conference_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 conference_site_web

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=head2 conference_description

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=cut

__PACKAGE__->add_columns(
  "conference_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "conference_conference_id_seq",
  },
  "conference_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "conference_site_web",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
  "conference_description",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
);

=head1 PRIMARY KEY

=over 4

=item * L</conference_id>

=back

=cut

__PACKAGE__->set_primary_key("conference_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<conference_conference_nom_key>

=over 4

=item * L</conference_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("conference_conference_nom_key", ["conference_nom"]);

=head1 RELATIONS

=head2 edition_confs

Type: has_many

Related object: L<DB::Sloth::Result::EditionConf>

=cut

__PACKAGE__->has_many(
  "edition_confs",
  "DB::Sloth::Result::EditionConf",
  { "foreign.edition_conf_conference_id" => "self.conference_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-08 09:11:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HjWjFT+csLN4faEoEM88GA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub dfv_profil_creation {
    return {
        required => [ qw/conference_nom/ ],
        optional => [ qw/conference_description conference_site_web / ],
        filters => 'trim',
        constraint_methods => {
            conference_nom => [{
                constraint_method => qr/^([\s\S]){1,60}([\s\.])?/,
                name => 'Nom de la conference',
            }],
            conference_description => [{
                constraint_method => qr/^([\s\S]){0,500}([\s\.])?/,
                name => 'Description de la conference',
            }],
            conference_site_web => [{
                constraint_method => qr/^([\s\S]){0,1000}([\s\.])?/,
                name => 'Site web de la conference',
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
