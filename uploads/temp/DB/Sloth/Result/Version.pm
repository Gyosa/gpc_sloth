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

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=head2 version_nom

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=cut

__PACKAGE__->add_columns(
  "version_id",
  { data_type => "varchar", is_nullable => 0, size => 60 },
  "version_nom",
  { data_type => "varchar", is_nullable => 0, size => 60 },
);

=head1 PRIMARY KEY

=over 4

=item * L</version_id>

=back

=cut

__PACKAGE__->set_primary_key("version_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-02-03 01:17:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bHzN5Kg5ezmEh8JdY9GA9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
