package sloth::edition_conf;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;

# toutes les routes de ce module commencent implicitement par "/edition_conf"
prefix "/:edition_conf_conference_id/edition_conf";


# ---------- route GET /edition_conf/afficher : afficher infos edition_conf 
get '/afficher/:edition_conf_id' => sub {
  my $edition_conf_id = param('edition_conf_id');
  my $edition_conf_conference_id = param('edition_conf_conference_id');

  my $edition_conf = schema->resultset('EditionConf')->find($edition_conf_id);
  my $edition_conf_conference = schema->resultset('Conference')->find($edition_conf_conference_id);

  var 'edition_conf_conference' => $edition_conf_conference;

  if (not defined $edition_conf or $edition_conf eq "") {
    Messages::danger("ce edition_conf n'existe pas (numero = $edition_conf_id)");
    return vue_liste_edition_conf();
  };
  var 'edition_conf' => $edition_conf;
  var 'edition_conf_id' => $edition_conf_id;
  return vue_detail_edition_conf();
};


# ---------- route GET /edition_conf/formulaire : afficher formulaire edition_conf 
get '/creer' => sub {
  Messages::developpement("Création d'un nouvel edition_conf") if DEBUG;
  my $edition_conf_conference_id = param('edition_conf_conference_id');
  var 'edition_conf' => schema->resultset('EditionConf')->new({
    edition_conf_id => 0,
    edition_conf_conference_id => $edition_conf_conference_id
    });
  return vue_formulaire_edition_conf();
};


# ---------- route POST /edition_conf/formualire : réaliser création edition_conf,
post '/creer' => sub {
  Messages::developpement("Création d'un nouvel edition_conf") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('EditionConf')->dfv_profil_creation;


  # --- obtenir les paramètres
  my $donnees_formulaire = request->params;




  
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
    var 'edition_conf' =>  schema->resultset('EditionConf')->new({edition_conf_id=>0, %{$resultats->valid}});
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_edition_conf();

  } 
  my %data = %$donnees_formulaire;
  my @liste_edition_meme_nom = schema->resultset('EditionConf')->search({'edition_conf_nom' => $data{edition_conf_nom}});
  if (scalar(@liste_edition_meme_nom) > 0) {
    # Il y a déjà une édition avec ce nom dans la base
    var 'edition_conf' =>  schema->resultset('EditionConf')->new({edition_conf_id=>0, %{$resultats->valid}});
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_edition_conf();
  }

  warn Dumper($resultats);
  
  # ----- Si aucune erreur n'est détectée par la validation:
  # on doit créer le nouveau edition_conf
  my $new_edition_conf = schema->resultset('EditionConf')->create_from_fv($resultats);
  if (defined $new_edition_conf) {
    Messages::succes("EditionConf (numero=". $new_edition_conf->edition_conf_id() . ") ajouté");
  } else {
    Messages::danger("Création de la nouvelle conférence impossible");
  }
  return vue_detail_conference();

};

## modifier les variables pour correspondre a la DBB### 
#---------- route GET /edition_conf/modifier : afficher formulaire modification edition_conf
get '/modifier/:edition_conf_id' => sub {
  my $edition_conf_id = param('edition_conf_id');
  my $edition_conf = schema->resultset('EditionConf')->find($edition_conf_id);
  if (not defined $edition_conf) {
    Messages::danger("cette edition_conf n'existe pas (numero = $edition_conf_id)");
    return vue_detail_conference();
  }
  var 'edition_conf' => $edition_conf;
  return vue_formulaire_edition_conf();
};


## est appélé quand in utlisation les icon jQuerry (desactivés voir gestcli) ###
# ---------- route POST /edition_conf/modifier : réaliser modification edition_conf,
post '/modifier/:edition_conf_id' => sub {
  my $edition_conf_id = param('edition_conf_id');
  if (not defined $edition_conf_id or not $edition_conf_id =~ m/^\d+$/) {
    Messages::danger("Invalid parameter 'edition_conf_id'!");
    return vue_detail_conference();
  }
  # on recherche ce edition_conf
  my $edition_conf = schema->resultset('EditionConf')->find($edition_conf_id);
  if (not defined $edition_conf) {
    Messages::danger("Cette edition de conférence n'existe pas (numero = $edition_conf_id)");
    return vue_detail_conference();
  }

  Messages::developpement("edition_conf_id = $edition_conf_id") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('EditionConf')->dfv_profil_creation;

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
    $donnees_formulaire->{edition_conf_id} = $edition_conf->edition_conf_id;
    var 'edition_conf' => schema->resultset('EditionConf')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_edition_conf();
  }


  # --- Aucune erreur n'est détectée par la validation, on peut modifier
  # --- on met à jour le edition_conf via la methode update_from_fv
  #     (fournie par le composant DBIx::Class::FromValidators)
  $edition_conf = $edition_conf->update_from_fv($resultats);
  if (not defined $edition_conf) {
    Messages::danger("Modification impossible!");
    return vue_detail_edition_conf();
  }
  my $edition_conf_nom = $edition_conf->edition_conf_nom;
  Messages::succes("EditionConf modifié (nom: $edition_conf_nom, numéro: $edition_conf_id)");
  return vue_detail_conference();
};


get '/supprimer/:edition_conf_id' => sub {
  my $edition_conf_id = param('edition_conf_id');
  my $edition_conf = schema->resultset('EditionConf')->find($edition_conf_id);
  # if (not defined $edition_conf) {
  #   Messages::danger("Ce edition_conf n'existe pas (numéro = $edition_conf_id)");
  #   return vue_liste_edition_conf();
  # }
  # var 'edition_conf' => $edition_conf;
  if (defined $edition_conf) {
  $edition_conf->delete();
  Messages::succes("Hors série supprimé");
  } else {
    Messages::danger("Ce edition_conf n'existe pas (numéro = $edition_conf_id)");
  }
  return vue_detail_conference();
};

# post '/supprimer/:edition_conf_id' => sub {
#   my $edition_conf_id = param('edition_conf_id');
#   my $edition_conf = schema->resultset('EditionConf')->find($edition_conf_id);
#   if (defined $edition_conf) {
#     $edition_conf->delete();
#     Messages::succes("Hors série supprimé");
#   } else {
#     Messages::danger("Ce edition_conf n'existe pas (numéro = $edition_conf_id)");
#   }
#   return vue_detail_conference();
# };


#------------------------------------------------------------
# les vues côté "edition_conf"
#------------------------------------------------------------

sub vue_detail_edition_conf{
  my $edition_conf = var 'edition_conf';
  my $edition_conf_conference_id = param('edition_conf_conference_id');
  my $edition_conf_conference = var 'edition_conf_conference';

  my @liste_des_articles = schema->resultset('Article')->search({article_edition_conf_id => $edition_conf->edition_conf_id})->all();
  my @liste_articles;
  if (scalar(@liste_des_articles) > 0) {
    # pour chaque article on ses auteurs"
    for my $article (@liste_des_articles) {
      my @liste_auteurs = schema->resultset('Utilisateur')->search(
        {'participation_article_id' => $article->article_id,
        },
        {join => 'participations',
         order_by => {'-asc' => 'participations.participation_ordre'},
        });
      my @this_article;
      push(@this_article, $article, \@liste_auteurs);
      push(@liste_articles, \@this_article);
    }
  } else {
    Messages::developpement("liste des article est vide"); 
  };

  template 'detail_edition_conf', {
    edition_conf => $edition_conf,
    conference_id => $edition_conf_conference_id,
    edition_conf_conference => $edition_conf_conference,
    liste_articles => \@liste_articles,

  }
}

sub vue_detail_conference{
  my $edition_conf_conference_id = param('edition_conf_conference_id');
  my $conference = schema->resultset('Conference')->find($edition_conf_conference_id);

  my $is_ec = 0;
  my @liste_ec = schema->resultset('EditionConf')->search({edition_conf_conference_id => $edition_conf_conference_id})->all();

  template 'detail_conference', {
    conference => $conference,
    editions => \@liste_ec,
  }
}

sub vue_formulaire_edition_conf {

  my $edition_conf = var 'edition_conf';
  my $msgs = var 'msgs';
  my $edition_conf_conference_id = param('edition_conf_conference_id');

  my $titre =
     $edition_conf->edition_conf_id == 0 ?
     "Nouvelle édition de conférence" :
     "Modification de l'édition";
  template 'formulaire_edition_conf', {
    titre => $titre,
    edition_conf => $edition_conf,
    msgs => $msgs,
    edition_conf_conference_id => $edition_conf_conference_id,
   };
}

true;

__END__


## comprehension fin
