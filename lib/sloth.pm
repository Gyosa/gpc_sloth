package sloth;
use strict;
use utf8;
use Dancer2;
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
use Data::FormValidator;       # pour valider les formulaires
use Data::Dumper;
use CGI::Carp qw/fatalsToBrowser/;
use Messages;
use constant DEBUG => 1;

# chargement du module gérant les routes commençant par '/utilisateur'
use sloth::utilisateur;
# chargement du module gérant les routes commençant par '/revues'
use sloth::revues;
# chargement du module gérant les routes commençant par '/groupe'
use sloth::groupes;
# chargement du module gérant les routes commençant par '/conferences'
use sloth::conferences;
# chargement du module gérant les routes commençant par '/articles'
use sloth::articles;
# chargement du module gérant les routes commençant par '/dashboard'
use sloth::dashboard;
# chargement du module gérant les routes commençant par '/dashboard'
use sloth::mes_articles;
# chargement du module gérant les routes commençant par '/fichiers'
use sloth::fichiers;
# chargement du module gérant les routes commençant par '/hors_series'
use sloth::hors_serie;
# chargement du module gérant les routes commençant par '/hors_series'
use sloth::edition_conf;

# les routes de ce fichier n'ont pas de préfixe
prefix undef;

our $VERSION = '0.1';

# our $schema = schema "model_sloth"; # chargement classes DBIx::Class du schéma model_sloth

get '/' => sub {
  my @utilisateur = schema->resultset('Utilisateur')->search({utilisateur_auth => $ENV{'REMOTE_USER'}});
  my $utilisateur = @utilisateur[0];
  var 'utilisateur' => $utilisateur;
  return vue_accueil();
};

get '' => sub {
  my @utilisateur = schema->resultset('Utilisateur')->search({utilisateur_auth => $ENV{'REMOTE_USER'}});
  my $utilisateur = @utilisateur[0];
  var 'utilisateur' => $utilisateur;
  return vue_accueil();
};

get '/dedicace' => sub {
  return vue_dedicace();
};

get '/about' => sub {
  return vue_about();
};

# --- route par défaut: déclenchée si URL non reconnue
any qr{.*} => sub {
  return vue_route_non_trouvee();
};

hook before => sub {
my $login = $ENV{'REMOTE_USER'};
if ( my $utilisateur = schema->resultset('Utilisateur')->search({utilisateur_auth => $login})->next) {

  } else {
    use Net::LDAP;
    my $server = "ldap.mines-albi.fr";
    my $ldap = Net::LDAP->new( $server ) or die $@;
    $ldap->bind;
    my $mesg = $ldap->search(
    base => "ou=People,dc=enstimac,dc=fr",
    filter => "(uid=$login)");

    my $entry  =$mesg->pop_entry;
    my $givenName = $entry->get_value('givenName');
    my $sn = $entry->get_value('sn');

    my $utilisateur = schema->resultset('Utilisateur')->create({
      utilisateur_auth => $login,
      utilisateur_nom => $sn,
      utilisateur_prenom => $givenName,
      });

  }

};
# -----------------------------------------------------------------------------
# --- appelé juste avant la génération du HTML par le template
#   transmission de données complémentaires (messages, menus, ...) au template
hook before_template => sub {
  my $tokens = shift;

  # uri_base représente l'URI de l'application (on supprime un éventuel '/' final)
  $tokens->{uri_base} = request->uri_base;
  $tokens->{uri_base} = $1 if $tokens->{uri_base} =~ m{^(.*)/$};

  # pour connaître la route courante
  $tokens->{path_info} = request->path_info;

  # pour connaître le user connecté
  my $remote_user = request->user;
  $tokens->{remote_user} = $remote_user;

  my $user = schema->resultset('Utilisateur')->search({utilisateur_auth => $ENV{'REMOTE_USER'} })->next;
  $tokens->{user_nom} = $user->utilisateur_nom;
  $tokens->{user_prenom} = $user->utilisateur_prenom;


  # --- éléments du menu, pourraient dépendre du contexte... ici on laisse fixe
  $tokens->{menu} = [
      {texte => 'Tableau de bord', route => '/dashboard' },
      {texte => 'Mes articles', route => '/mes_articles/liste' },
      {texte => 'Revues', route => '/revues/liste' },
      {texte => 'Conférences', route => '/conferences/liste' },
      {texte => 'Articles', route => '/articles/liste' },
      {texte => 'Groupes', route => '/groupes/liste' },
     # {texte => 'Mes fichiers', route => '/fichiers/liste' },
    ];
  };

#------------------------------------------------------------
# Les vues générales
#------------------------------------------------------------
sub vue_accueil {
  my $utilisateur = var 'utilisateur';
  template 'accueil',{
    utilisateur => $utilisateur,
    titre => 'Accueil',
  };
}

sub vue_route_non_trouvee {
  status 404;
  template 'erreur', { path => request->path };
}

sub vue_about {
  template 'about', {
    titre => "À propos de sloth",
  };
}

sub vue_dedicace {
  template 'dedicace', {titre => 'Dédicace'};
}

# fin du package (la compilation s'est bien passé)
true;

__END__
