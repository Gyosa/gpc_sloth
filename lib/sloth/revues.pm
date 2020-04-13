package sloth::revues;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;

# toutes les routes de ce module commencent implicitement par "/revues"
prefix "/revues";

get '/liste' => sub {
  Messages::developpement("Affichage liste des revues") if DEBUG;
  return vue_liste_revue();
};

# ---------- route GET /revues/afficher : afficher infos revue 
get '/afficher/:revue_id' => sub {
  my $r_id = param('revue_id');
  my $revue = schema->resultset('Revue')->find($r_id);
  if (not defined $revue or $revue eq "") {
    Messages::danger("ce revue n'existe pas (numero = $r_id)");
    return vue_liste_revue();
  };
  var 'revue' => $revue;
  var 'r_id' => $r_id;
  return vue_detail_revue();
};


# ---------- route GET /revue/formulaire : afficher formulaire revue 
get '/creer' => sub {
  Messages::developpement("Création d'une nouvelle revue") if DEBUG;
  var 'revue' => schema->resultset('Revue')->new({revue_id => 0});
  return vue_formulaire_revue();
};


# ---------- route POST /revue/formualire : réaliser création revue,
post '/creer' => sub {
  Messages::developpement("Création d'une nouvelle revue") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Revue')->dfv_profil_creation;


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
    $donnees_formulaire->{revue_id} = 0;
    var 'revue' =>  schema->resultset('Revue')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_revue();

  }

  # --- On verifie si une revue du même nom n'est pas déjà dans la base
  my $revue_nom = $donnees_formulaire->{revue_nom};
  my @revues_identiques = schema->resultset('Revue')->search({ revue_nom => $revue_nom })->all();
  
  if ( scalar(@revues_identiques) != 0){
    Messages::danger("Ce nom existe déjà");
    # --- après erreur, on revient en modification sur les donnees saisies
    $donnees_formulaire->{revue_id} = 0;
    var 'revue' =>  schema->resultset('Revue')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_revue();
  };

  warn Dumper($resultats);
  
  # ----- Si aucune erreur n'est détectée par la validation:
  # on doit créer le nouveau revue
  my $new_revue = schema->resultset('Revue')->create_from_fv($resultats);
  if (defined $new_revue) {
    Messages::succes("Revue (numero=". $new_revue->revue_id() . ") ajouté");
    var 'critere_revue_nom' => $new_revue->revue_nom;
    var 'critere_revue_description'=> $new_revue->revue_description;
    var 'critere_revue_theme'=> $new_revue->revue_theme;
    var 'critere_revue_site_web'=> $new_revue->revue_site_web;
    var 'critere_revue_consignes'=> $new_revue->revue_consignes;
  } else {
    Messages::danger("Création de la nouvelle revue impossible");
  }
  return vue_liste_revue();

};

## modifier les variables pour correspondre a la DBB### 
#---------- route GET /revue/modifier : afficher formulaire modification revue
get '/modifier/:revue_id' => sub {
  my $revue_id = param('revue_id');
  my $revue = schema->resultset('Revue')->find($revue_id);
  if (not defined $revue) {
    Messages::danger("cette revue n'existe pas (numero = $revue_id)");
    return vue_liste_revue();
  }
  var 'revue' => $revue;
  return vue_formulaire_revue();
};


## est appélé quand in utlisation les icon jQuerry (desactivés voir gestrevue) ###
# ---------- route POST /revue/modifier : réaliser modification revue,
post '/modifier/:revue_id' => sub {
  my $revue_id = param('revue_id');
  if (not defined $revue_id or not $revue_id =~ m/^\d+$/) {
    Messages::danger("Invalid parameter 'revue_id'!");
    return vue_liste_revue();
  }
  # on recherche ce revue
  my $revue = schema->resultset('Revue')->find($revue_id);
  if (not defined $revue) {
    Messages::danger("Cet revue n'existe pas (numero = $revue_id)");
    return vue_liste_revue();
  }

  Messages::developpement("revue_id = $revue_id") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Revue')->dfv_profil_creation;

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
    $donnees_formulaire->{revue_id} = $revue->revue_id;
    var 'revue' => schema->resultset('Revue')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_revue();
  };

  my $revue_nom = $donnees_formulaire->{revue_nom};
  my @revues_identiques = schema->resultset('Revue')->search({ revue_nom => $revue_nom })->all();
  
  if ( scalar(@revues_identiques) != 1){
    Messages::danger("Ce nom existe déjà");
    # --- après erreur, on revient en modification sur les donnees saisies
    $donnees_formulaire->{revue_id} = 0;
    var 'revue' =>  schema->resultset('Revue')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_revue();
  };

  # --- Aucune erreur n'est détectée par la validation, on peut modifier
  # --- on met à jour le revue via la methode update_from_fv
  #     (fournie par le composant DBIx::Class::FromValidators)
 
  $revue = $revue->update_from_fv($resultats);
  if (not defined $revue) {
    Messages::danger("Modification impossible!");
    return vue_liste_revue();
  }
  my $revue_nom = $revue->revue_nom;
  Messages::succes("Revue modifiée (nom: $revue_nom, numéro: $revue_id)");
  var 'critere_revue_nom' => $revue_nom;
  var 'critere_revue_id' => $revue->revue_id;
  return vue_liste_revue();
};


#---------- route GET /revue/supprimer : afficher formulaire modification revue
get '/supprimer/:revue_id' => sub {
  my $revue_id = param('revue_id');
  my $revue = schema->resultset('Revue')->find($revue_id);
  #if (not defined $revue) {
  #  Messages::danger("Ce revue n'existe pas (numéro = $revue_id)");
  # return vue_liste_revue();
  #}
  #var 'revue' => $revue;
   if (defined $revue) {
     my @hs = schema->resultset('HorsSerie')->search({hors_serie_revue_id => $revue_id });
     # --- suppression de tous les utilisateur de ce groupe
     for my $hs (@hs) {
       $hs->delete;
    }
    $revue->delete();
    Messages::succes("Revue supprimé");
  } else {
    Messages::danger("Ce revue n'existe pas (numéro = $revue_id)");
  }


  return vue_liste_revue();
};

# post '/supprimer/:revue_id' => sub {
#   my $revue_id = param('revue_id');
#   my $revue = schema->resultset('Revue')->find($revue_id);
#   if (defined $revue) {
#     $revue->delete();
#     Messages::succes("Revue supprimé");
#   } else {
#     Messages::danger("Ce revue n'existe pas (numéro = $revue_id)");
#   }
#   return vue_liste_revue();
# };


#------------------------------------------------------------
# les vues côté "revue"
#------------------------------------------------------------

sub vue_detail_revue{
  my $revue = var 'revue';
  my $r_id = var 'r_id';
  my $is_hs = 0;
  my @liste_hs = schema->resultset('HorsSerie')->search({hors_serie_revue_id => $r_id})->all();
  if (scalar(@liste_hs) > 0 ){
    $is_hs = 1;
  };
  my @liste_des_articles = schema->resultset('Article')->search({article_revue_id => $r_id})->all();
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
  template 'detail_revue', {
    revue => $revue,
    liste_hs => \@liste_hs,
    liste_articles => \@liste_articles,
    liste_hs_exists => $is_hs,
  }
}

sub vue_formulaire_suppression {
  my $revue = var 'revue';
  template 'formulaire_suppression_revue', {
  revue => $revue,
  };
}
sub vue_liste_revue {

  #récuperation de la liste des revues existantes
  my @liste_revues;
  my @liste_des_revues = schema->resultset('Revue')->all();

  if (scalar(@liste_des_revues) > 0) {
    Messages::developpement("liste_des_revues:", Dumper(@liste_des_revues)) if DEBUG;
  
    # pour chaque revue on cherche la liste des hors series de cette revue
    for my $revue (@liste_des_revues) {
      my @liste_hors_serie = $revue->hors_series;
      my $is_hs = 0;
      if (scalar(@liste_hors_serie) > 0 ){
        $is_hs = 1;
      };
      my $nb_articles_accepte = scalar($revue->articles->search({article_statut_id => 1})->all());
      my $nb_articles_online = scalar($revue->articles->search({article_statut_id => 2})->all());
      my $nb_articles_publie = scalar($revue->articles->search({article_statut_id => 3})->all());
      my $nb_articles_refuse = scalar($revue->articles->search({article_statut_id => 4})->all());
      my $nb_articles_attente = scalar($revue->articles->search({article_statut_id => 5})->all());
      my $nb_articles_redaction = scalar($revue->articles->search({article_statut_id => 6})->all());

      my $nb_articles = scalar($revue->articles);
      my @this_revue;
      push(@this_revue, $revue, $is_hs, \@liste_hors_serie, $nb_articles,$nb_articles_accepte,$nb_articles_online,$nb_articles_publie,$nb_articles_refuse,$nb_articles_attente, $nb_articles_redaction);
      push(@liste_revues, \@this_revue);
    }

  } else {
    Messages::developpement("liste des groupes est vide"); 
  }

  # --- appel du template de liste des revues
  template 'liste_revues', {
    liste_revues => \@liste_revues,
    titre => "Liste des revues",
  };
}

sub vue_formulaire_revue{
  my $revue = var 'revue';
  my $msgs = var 'msgs';
  #if revue_id defined ??
  my $titre =
     $revue->revue_id == 0 ?
     "Nouvelle revue" :
     "Modification de la revue";
  template 'formulaire_revue', {
    titre => $titre,
    revue => $revue,
    msgs => $msgs,
   }
 };

true;

__END__


## comprehension fin
