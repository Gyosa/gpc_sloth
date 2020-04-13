package sloth::conferences;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;
use DateTime;
use DateTime::Format::Pg;

# toutes les routes de ce module commencent implicitement par "/conferences"
prefix "/conferences";

get '/liste' => sub {
  Messages::developpement("Affichage liste des conferences") if DEBUG;

  # --- obtention et controle des paramètres
  my $params = request->params;
  Messages::developpement("Paramètres:", Dumper($params)) if DEBUG;

  # --- profil de validation des parametres pouvant etre transmis
  my $dfv_profil = {
    optional => [ qw/critere_conference_nom/ ],
    filters => 'trim',
    msgs => {
      format => '%s',
      prefix => '',
      missing => 'obligatoire',
      invalid => 'valeur incorrecte',
    },
  };

  my $resultats = Data::FormValidator->check( $params, $dfv_profil );
  Messages::developpement("Résultat validation:",
	 	  Dumper($resultats)) if DEBUG;

   # --- Si pb sur paramètres....
  if ( $resultats->has_invalid or $resultats->has_missing ) {
    Messages::danger("Paramètres manquants ou invalides:",
	    Dumper($resultats->has_missing));
  }
  if ( $resultats->has_unknown()) {
      Messages::avertissement("Paramètres inconnus:",
	 	    $resultats->unknown());
  }

  # on passe ces paramètres à la vue
  var 'critere_conference_nom' => $resultats->valid('critere_conference_nom');

  return vue_liste_conference();
};

# ---------- route GET /conference/afficher : afficher infos conference 
get '/afficher/:conference_id' => sub {
  my $c_id = param('conference_id');
  my $conference = schema->resultset('Conference')->find($c_id);
  if (not defined $conference or $conference eq "") {
    Messages::danger("cette conference n'existe pas (numero = $c_id)");
    return vue_liste_conference();
  };
  var 'conference' => $conference;
  var 'c_id' => $c_id;
  return vue_detail_conference();
};


# ---------- route GET /conference/formulaire : afficher formulaire conference 
get '/creer' => sub {
  var 'conference' => schema->resultset('Conference')->new({conference_id => 0});
  return vue_formulaire_conference();
};

# ---------- route POST /conference/formualire : réaliser création conference,
post '/creer' => sub {
  Messages::developpement("Création d'un nouveau conference") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Conference')->dfv_profil_creation;

  my $donnees_formulaire = request->params;   # obtenir les paramètres
  # --- check valide l'ensemble des donnees passees dans la query
  #     en fonction des contraintes exprimées dans le profil de validation.
  
  my $resultats = Data::FormValidator->check( $donnees_formulaire, $profil );
  Messages::developpement("Résultat validation:",
			  Dumper($resultats)) if DEBUG;

  # --- L'objet retourne par check a des methodes generales
  #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
  if ( $resultats->has_invalid or $resultats->has_missing ) {
      # ----- Si des erreurs sont détectées par la validation:
      if($resultats->has_missing){Messages::danger("has missing");}
      if($resultats->has_invalid){Messages::danger("has invalid");}
    Messages::danger("Il y a des erreurs");

    # --- après erreur, on revient en modification sur les donnees saisies
    $donnees_formulaire->{conference_id} = 0;
    var 'conference' =>  schema->resultset('Conference')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_conference();

  }

  warn Dumper($resultats);
  
  # ----- Si aucune erreur n'est détectée par la validation:
  # on doit créer le nouveau conference
  my $nouveau_conference = schema->resultset('Conference')->create_from_fv($resultats);
  if (defined $nouveau_conference) {
    Messages::succes("conference (numero=". $nouveau_conference->conference_id() . ") ajouté");
    var 'critere_conference_nom' => $nouveau_conference->conference_nom;
  } else {
    Messages::danger("Création de la nouvelle conference impossible");
  }
  return vue_liste_conference();

};

### modifier les variables pour correspondre a la DBB### 
# ---------- route GET /conference/modifier : afficher formulaire modification conference
get '/modifier/:conference_id' => sub {
  my $conference_id = param('conference_id');
  my $conference = schema->resultset('Conference')->find($conference_id);
  if (not defined $conference) {
    Messages::danger("cette conference n'existe pas (numero = $conference_id)");
    return vue_liste_conference();
  }
  var 'conference' => $conference;
  return vue_formulaire_conference();
};


## est appélé quand in utlisation les icon jQuerry (desactivés voir gestconference) ###
# ---------- route POST /conference/modifier : réaliser modification conference,
post '/modifier/:conference_id' => sub {
  my $conference_id = param('conference_id');
  if (not defined $conference_id or not $conference_id =~ m/^\d+$/) {
    Messages::danger("Invalid parameter 'conference_id'!");
    return vue_liste_conference();
  }
  # on recherche ce conference
  my $conference = schema->resultset('Conference')->find($conference_id);
  if (not defined $conference) {
    Messages::danger("Cette conference n'existe pas (numero = $conference_id)");
    return vue_liste_conference();
  }

  Messages::developpement("conference_id = $conference_id") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Conference')->dfv_profil_creation;

  my $donnees_formulaire = request->params;   # obtenir les paramètres
  # --- check valide l'ensemble des donnees passees dans la query
  #     en fonction des contraintes exprimées dans le profil de validation.
  my $resultats = Data::FormValidator->check( $donnees_formulaire, $profil );
  Messages::developpement("Résultat validation:",
			  Dumper($resultats)) if DEBUG;

  # --- L'objet retourne par check a des methodes generales
  #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
  if ( $resultats->has_invalid or $resultats->has_missing ) {
      # ----- Si des erreurs sont détectées par la validation:
     
    Messages::danger("Il y a des erreurs");
    # Messages::danger("Nombre de valeurs manquantes: " . Dumper($resultats->has_missing));
    # Messages::danger("Nombre de valeurs invalides " . Dumper($resultats->has_invalid));
    # Messages::danger("messages " . Dumper($resultats->msgs));

    # --- après erreur, on revient en modification sur les donnees saisies
    $donnees_formulaire->{conference_id} = $conference->conference_id;
    var 'conference' => schema->resultset('Conference')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_conference();
  }

  # --- Aucune erreur n'est détectée par la validation, on peut modifier
  # --- on met à jour le conference via la methode update_from_fv
  #     (fournie par le composant DBIx::Class::FromValidators)
  $conference = $conference->update_from_fv($resultats);
  if (not defined $conference) {
    Messages::danger("Modification impossible!");
    return vue_liste_conference();
  }
  my $conference_nom = $conference->conference_nom;
  Messages::succes("conference modifiée (nom: $conference_nom, numéro: $conference_id)");
  var 'critere_conference_nom' => $conference_nom;
  return vue_liste_conference();
};


# ---------- route GET /conference/supprimer : afficher formulaire modification conference
get '/supprimer/:conference_id' => sub {
  my $conference_id = param('conference_id');
  my $conference = schema->resultset('Conference')->find($conference_id);
  #if (not defined $conference) {
  #  Messages::danger("Ce conference n'existe pas (numéro = $conference_id)");
  #  return vue_liste_conference();
  #}
  #var 'conference' => $conference;
  if (defined $conference) {
    my @editions = schema->resultset('EditionConf')->search({edition_conf_conference_id => $conference_id });
    # --- suppression de tous les utilisateur de ce groupe
    for my $edition (@editions) {
      $edition->delete;
    }
    $conference->delete();
    Messages::succes("Conference supprimée");
  } else {
    Messages::danger("Cette conference n'existe pas (numéro = $conference_id)");
  }
  return vue_liste_conference();
};

# post '/supprimer/:conference_id' => sub {
#   my $conference_id = param('conference_id');
#   my $conference = schema->resultset('Conference')->find($conference_id);
#   if (defined $conference) {
#     $conference->delete();
#     Messages::succes("Conference supprimée");
#   } else {
#     Messages::danger("Ce conference n'existe pas (numéro = $conference_id)");
#   }
#   return vue_liste_conference();
# };


#------------------------------------------------------------
# les vues côté "conference"
#------------------------------------------------------------

sub vue_formulaire_suppression {
  my $conference = var 'conference';
  template 'formulaire_suppression_conference', {
    conference => $conference,
  };
}

sub vue_formulaire_conference{
  my $conference = var 'conference';
  my $msgs = var 'msgs';
  #if conference_id defined ??
  my $titre =
     $conference->conference_id == 0 ?
     "Nouvelle conference" :
     "Modification du conference";
  template 'formulaire_conference', {
    titre => $titre,
    conference => $conference,
    msgs => $msgs,
   };
}

sub vue_detail_conference{
  my $conference = var 'conference';
  my $c_id = var 'c_id';
  my @editions = schema->resultset('EditionConf')->search({edition_conf_conference_id => $c_id})->all();

  template 'detail_conference', {
    conference => $conference,
    editions => \@editions,
  };
}

sub vue_liste_conference {
  my @conferences;
  my @liste_conferences = schema->resultset('Conference')->all();
  my $now = DateTime->now;
  for my $conference (@liste_conferences) {
    my $nb_editions = scalar($conference->edition_confs);
    my $nb_conf_a_venir = scalar(
    $conference->edition_confs->search({
    -or => [ edition_conf_date_limite_soumission => {'>' => $now},
             edition_conf_date_limite_soumission => undef]})
    );
    my @conf;
    push(@conf, $conference, $nb_editions, $nb_conf_a_venir);
    push(@conferences, \@conf);
  }

  template 'liste_conferences', {
    conferences => \@conferences,
    titre => "Liste des conferences",
  };
}

# fin du package (la compilation s'est bien passé)
true;

__END__


## comprehension fin
