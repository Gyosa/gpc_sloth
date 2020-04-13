use utf8;
package DB::Sloth::Result::EstMembre;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::EstMembre

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

=head1 TABLE: C<est_membre>

=cut

__PACKAGE__->table("est_membre");

=head1 ACCESSORS

=head2 est_membre_groupe_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 est_membre_utilisateur_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "est_membre_groupe_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "est_membre_utilisateur_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</est_membre_groupe_id>

=item * L</est_membre_utilisateur_id>

=back

=cut

__PACKAGE__->set_primary_key("est_membre_groupe_id", "est_membre_utilisateur_id");

=head1 RELATIONS

=head2 est_membre_groupe

Type: belongs_to

Related object: L<DB::Sloth::Result::Groupe>

=cut

__PACKAGE__->belongs_to(
  "est_membre_groupe",
  "DB::Sloth::Result::Groupe",
  { groupe_id => "est_membre_groupe_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 est_membre_utilisateur

Type: belongs_to

Related object: L<DB::Sloth::Result::Utilisateur>

=cut

__PACKAGE__->belongs_to(
  "est_membre_utilisateur",
  "DB::Sloth::Result::Utilisateur",
  { utilisateur_id => "est_membre_utilisateur_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-08 09:11:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lluvg6KN7MXozLYSlcrTHw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
