use utf8;
package DB::Sloth::Result::Journal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Sloth::Result::Journal

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

=head1 TABLE: C<journal>

=cut

__PACKAGE__->table("journal");

=head1 ACCESSORS

=head2 journal_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'journal_journal_id_seq'

=head2 journal_nom

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 journal_description

  data_type: 'varchar'
  is_nullable: 1
  size: 500

=head2 journal_theme

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 journal_site_web

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=head2 journal_consignes

  data_type: 'varchar'
  is_nullable: 1
  size: 10000

=cut

__PACKAGE__->add_columns(
  "journal_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "journal_journal_id_seq",
  },
  "journal_nom",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "journal_description",
  { data_type => "varchar", is_nullable => 1, size => 500 },
  "journal_theme",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "journal_site_web",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
  "journal_consignes",
  { data_type => "varchar", is_nullable => 1, size => 10000 },
);

=head1 PRIMARY KEY

=over 4

=item * L</journal_id>

=back

=cut

__PACKAGE__->set_primary_key("journal_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<journal_journal_nom_key>

=over 4

=item * L</journal_nom>

=back

=cut

__PACKAGE__->add_unique_constraint("journal_journal_nom_key", ["journal_nom"]);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-08 09:11:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JPnwK9hh1SJlc4Ihng9JAg

__PACKAGE__->has_many(
  "revue_hors_serie",
  "DB::Sloth::Result::HorsSerie",
  {  "foreign.hors_serie_journal_id" => "self.journal_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
