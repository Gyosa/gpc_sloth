#!/usr/bin/perl
#
# script à exécuter à chaque fois que la structure de la base de données change
#
#    perl SQL/schema-dumper.pl
#
use strict;
use warnings;
use lib "lib";
use DBIx::Class::Schema::Loader qw/make_schema_at/;

warn "INC: @INC\n";

my $classe_base     = 'DB::Sloth';
my $repertoire_base = 'lib';
my $dsn             = 'dbi:Pg:dbname=gpcsloth;host=sgbd-eleves.mines-albi.fr';
my $user            = 'slothadmin';
my $password        = 'slothadm19';

make_schema_at(
	       $classe_base,
	       {
		#constraint  => qr/client|commande|produit/,
		relationships  => 1,
		components     => [qw/FromValidators InflateColumn::DateTime Core/],
		debug          => 1,
		dump_directory => $repertoire_base,
		skip_load_external => 0,
	       },
	       [ $dsn, $user, $password],
	      );

__END__
