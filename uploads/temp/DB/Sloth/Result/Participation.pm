use utf8;
package DB::Sloth::Result::Participation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Participation

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

=head1 TABLE: C<participation>

=cut

__PACKAGE__->table("participation");

=head1 ACCESSORS

=head2 participation_utilisateur_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 participation_article_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 participation_ordre

  data_type: 'integer'
  is_nullable: 0

=head2 participation_fonction

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=cut

__PACKAGE__->add_columns(
  "participation_utilisateur_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "participation_article_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "participation_ordre",
  { data_type => "integer", is_nullable => 0 },
  "participation_fonction",
  { data_type => "varchar", is_nullable => 0, size => 60 },
);

=head1 PRIMARY KEY

=over 4

=item * L</participation_utilisateur_id>

=item * L</participation_article_id>

=back

=cut

__PACKAGE__->set_primary_key("participation_utilisateur_id", "participation_article_id");

=head1 RELATIONS

=head2 participation_article

Type: belongs_to

Related object: L<DB::Sloth::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "participation_article",
  "DB::Sloth::Result::Article",
  { article_id => "participation_article_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 participation_utilisateur

Type: belongs_to

Related object: L<DB::Sloth::Result::Utilisateur>

=cut

__PACKAGE__->belongs_to(
  "participation_utilisateur",
  "DB::Sloth::Result::Utilisateur",
  { utilisateur_id => "participation_utilisateur_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-08 09:11:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CNCE6k7S70mdQWb8mebuyA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
