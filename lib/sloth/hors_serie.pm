package sloth::hors_series;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;

# toutes les routes de ce module commencent implicitement par "/hors_series"
prefix "/:hors_serie_revue_id/hors_serie";


# ---------- route GET /hors_series/afficher : afficher infos hors_serie 
get '/afficher/:hors_serie_id' => sub {
  my $hs_id = param('hors_serie_id');
  my $hors_serie_revue_id = param('hors_serie_revue_id');

  my $hors_serie = schema->resultset('HorsSerie')->find($hs_id);
  my $hors_serie_revue = schema->resultset('Revue')->find($hors_serie_revue_id);

  var 'hors_serie_revue' => $hors_serie_revue;


  if (not defined $hors_serie or $hors_serie eq "") {
    Messages::danger("ce hors_serie n'existe pas (numero = $hs_id)");
    return vue_liste_hors_serie();
  };
  var 'hors_serie' => $hors_serie;
  var 'hs_id' => $hs_id;
  return vue_detail_hors_serie();
};


# ---------- route GET /hors_serie/formulaire : afficher formulaire hors_serie 
get '/creer' => sub {
  Messages::developpement("Création d'un nouvel hors_serie") if DEBUG;
  my $hors_serie_revue_id = param('hors_serie_revue_id');
  my $hors_serie_revue = schema->resultset('Revue')->find($hors_serie_revue_id);
  var 'hors_serie_revue' => $hors_serie_revue;
  var 'hors_serie' => schema->resultset('HorsSerie')->new({
    hors_serie_id => 0,
    hors_serie_revue_id => $hors_serie_revue_id
    });
  return vue_formulaire_hors_serie();
};


# ---------- route POST /hors_serie/formualire : réaliser création hors_serie,
post '/creer' => sub {
  Messages::developpement("Création d'un nouvel hors_serie") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('HorsSerie')->dfv_profil_creation;


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

    var 'hors_serie' =>  schema->resultset('HorsSerie')->new({hors_serie_id=>0, %{$resultats->valid}});
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_hors_serie();

  } 


  warn Dumper($resultats);
  
  # ----- Si aucune erreur n'est détectée par la validation:
  # on doit créer le nouveau hors_serie
  my $new_hors_serie = schema->resultset('HorsSerie')->create_from_fv($resultats);
  if (defined $new_hors_serie) {
    Messages::succes("HorsSerie (numero=". $new_hors_serie->hors_serie_id() . ") ajouté");
  } else {
    Messages::danger("Création du nouvel hors serie impossible");
  }
  return vue_detail_revue();

};

## modifier les variables pour correspondre a la DBB### 
#---------- route GET /hors_serie/modifier : afficher formulaire modification hors_serie
get '/modifier/:hors_serie_id' => sub {
  my $hors_serie_id = param('hors_serie_id');
  my $hors_serie_revue_id = param('hors_serie_revue_id');
  my $hors_serie = schema->resultset('HorsSerie')->find($hors_serie_id);
  my $hors_serie_revue = schema->resultset('Revue')->find($hors_serie_revue_id);

  if (not defined $hors_serie) {
    Messages::danger("cette hors_serie n'existe pas (numero = $hors_serie_id)");
    return vue_detail_revue();
  }
  var 'hors_serie' => $hors_serie;
  var 'hors_serie_revue' => $hors_serie_revue;
  return vue_formulaire_hors_serie();
};


## est appélé quand in utlisation les icon jQuerry (desactivés voir gestcli) ###
# ---------- route POST /hors_serie/modifier : réaliser modification hors_serie,
post '/modifier/:hors_serie_id' => sub {
  my $hors_serie_id = param('hors_serie_id');
  if (not defined $hors_serie_id or not $hors_serie_id =~ m/^\d+$/) {
    Messages::danger("Invalid parameter 'hors_serie_id'!");
    return vue_detail_revue();
  }
  # on recherche ce hors_serie
  my $hors_serie = schema->resultset('HorsSerie')->find($hors_serie_id);
  if (not defined $hors_serie) {
    Messages::danger("Cet hors_serie n'existe pas (numero = $hors_serie_id)");
    return vue_detail_revue();
  }

  Messages::developpement("hors_serie_id = $hors_serie_id") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('HorsSerie')->dfv_profil_creation;

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
    $donnees_formulaire->{hors_serie_id} = $hors_serie->hors_serie_id;
    var 'hors_serie' => schema->resultset('HorsSerie')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_hors_serie();
  }

  # --- Aucune erreur n'est détectée par la validation, on peut modifier
  # --- on met à jour le hors_serie via la methode update_from_fv
  #     (fournie par le composant DBIx::Class::FromValidators)
  $hors_serie = $hors_serie->update_from_fv($resultats);
  if (not defined $hors_serie) {
    Messages::danger("Modification impossible!");
    return vue_detail_hors_serie();
  }
  my $hors_serie_nom = $hors_serie->hors_serie_nom;
  var 'hors_serie' => $hors_serie;
  Messages::succes("HorsSerie modifié (nom: $hors_serie_nom, numéro: $hors_serie_id)");
  return vue_detail_hors_serie();
};


get '/supprimer/:hors_serie_id' => sub {
  my $hors_serie_id = param('hors_serie_id');
  my $hors_serie = schema->resultset('HorsSerie')->find($hors_serie_id);
  # if (not defined $hors_serie) {
  #   Messages::danger("Ce hors_serie n'existe pas (numéro = $hors_serie_id)");
  #   return vue_liste_hors_serie();
  # }
  # var 'hors_serie' => $hors_serie;
  if (defined $hors_serie) {
  $hors_serie->delete();
  Messages::succes("Hors série supprimé");
  } else {
    Messages::danger("Ce hors_serie n'existe pas (numéro = $hors_serie_id)");
  }
  return vue_detail_revue();
};

# post '/supprimer/:hors_serie_id' => sub {
#   my $hors_serie_id = param('hors_serie_id');
#   my $hors_serie = schema->resultset('HorsSerie')->find($hors_serie_id);
#   if (defined $hors_serie) {
#     $hors_serie->delete();
#     Messages::succes("Hors série supprimé");
#   } else {
#     Messages::danger("Ce hors_serie n'existe pas (numéro = $hors_serie_id)");
#   }
#   return vue_detail_revue();
# };


#------------------------------------------------------------
# les vues côté "hors_serie"
#------------------------------------------------------------

sub vue_detail_hors_serie{
  my $hors_serie = var 'hors_serie';
  my $hors_serie_revue = $hors_serie->hors_serie_revue;

  my @liste_des_articles = schema->resultset('Article')->search({article_hors_serie_id => $hors_serie->hors_serie_id})->all();
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
  template 'detail_hs', {
    hors_serie => $hors_serie,
    revue_id => $hors_serie_revue->revue_id,
    hors_serie_revue => $hors_serie_revue,
    liste_articles => \@liste_articles,
  }
}

sub vue_detail_revue{
  my $r_id = param('hors_serie_revue_id');
  my $revue = schema->resultset('Revue')->find($r_id);
 
  my $is_hs = 0;
  my @liste_hs = schema->resultset('HorsSerie')->search({hors_serie_revue_id => $r_id})->all();
  if (scalar(@liste_hs) > 0 ){
    $is_hs = 1;
  }
  my @liste_article = schema->resultset('Article')->search({article_revue_id => $r_id})->all();
  template 'detail_revue', {
    revue => $revue,
    liste_hs => \@liste_hs,
    liste_articles => \@liste_article,
    liste_hs_exists => $is_hs,
  
  }
}

sub vue_formulaire_hors_serie {

  my $hors_serie = var 'hors_serie';
  my $hors_serie_revue = var 'hors_serie_revue';
  my $msgs = var 'msgs';
  my $hors_serie_revue_id = param('hors_serie_revue_id');

  my $titre =
     $hors_serie->hors_serie_id == 0 ?
     "Nouvel hors série" :
     "Modification du hors série";
  template 'formulaire_hors_serie', {
    titre => $titre,
    hors_serie => $hors_serie,
    msgs => $msgs,
    hors_serie_revue => $hors_serie_revue,
    hors_serie_revue_id => $hors_serie_revue_id,
   };
}

true;

__END__


## comprehension fin
