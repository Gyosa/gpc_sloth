package sloth::utilisateur;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;

# toutes les routes de ce module commencent implicitement par "/utilsateur"
prefix "/utilisateur";

# ---------- route GET /utilisateur/liste : afficher la liste des utilisateurs
get '/liste' => sub {
  Messages::developpement("Affichage liste des utilisateur") if DEBUG;

  # --- obtention et controle des paramètres
  my $params = request->params;
  Messages::developpement("Paramètres:", Dumper($params)) if DEBUG;
  # --- profil de validation des parametres pouvant etre transmis
  my $dfv_profil = {
    optional => [ qw/critere_utilisateur_nom critere_utilisateur_prenom/ ],
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
  var 'critere_utilisateur_nom' => $resultats->valid('critere_utilisateur_nom');
  var 'critere_utilisateur_prenom' => $resultats->valid('critere_utilisateur_prenom');

  return vue_liste_utilisateur();
};

# ---------- route GET /utilisateur/formulaire : afficher formulaire utilisateur 
get '/creer' => sub {
  var 'utilisateur' => schema->resultset('Utilisateur')->new({utilisateur_id => 0});
  return vue_formulaire_utilisateur();
};

# ---------- route POST /utilisateur/formualire : réaliser création utilisateur,
post '/creer' => sub {
  Messages::developpement("Création d'un nouveau utilisateur") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Utilisateur')->dfv_profil_creation;

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
    $donnees_formulaire->{utilisateur_id} = 0;
    var 'utilisateur' =>  schema->resultset('Utilisateur')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_utilisateur();

  }

  warn Dumper($resultats);
  
  # ----- Si aucune erreur n'est détectée par la validation:
  # on doit créer le nouveau utilisateur
  my $nouveau_utilisateur = schema->resultset('Utilisateur')->create_from_fv($resultats);
  if (defined $nouveau_utilisateur) {
    Messages::succes("Utilisateur (numero=". $nouveau_utilisateur->utilisateur_id() . ") ajouté");
    var 'critere_utilisateur_nom' => $nouveau_utilisateur->utilisateur_nom;
    var 'critere_utilisateur_prenom' => $nouveau_utilisateur->utilisateur_prenom;
  } else {
    Messages::danger("Création du nouveau utilisateur impossible");
  }
  return vue_liste_utilisateur();

};

### modifier les variables pour correspondre a la DBB### 
# ---------- route GET /utilisateur/modifier : afficher formulaire modification utilisateur
get '/modifier/:cli_numero' => sub {
  my $cli_numero = param('utlisateur_id');
  my $utilisateur = schema->resultset('Utilisateur')->find($cli_numero);
  if (not defined $utilisateur) {
    Messages::danger("cet utilisateur n'existe pas (numero = $cli_numero)");
    return vue_liste_utilisateur();
  }
  var 'utilisateur' => $utilisateur;
  return vue_formulaire_utilisateur();
};
### est appélé quand in utlisation les icon jQuerry (desactivés voir gestcli) ###
# ---------- route POST /utilisateur/modifier : réaliser modification utilisateur,
post '/modifier/:utilisateur_id' => sub {
  my $utilisateur_id = param('utilisateur_id');
  if (not defined $utilisateur_id or not $utilisateur_id =~ m/^\d+$/) {
    Messages::danger("Invalid parameter 'utilisateur_id'!");
    return vue_liste_utilisateur();
  }
  # on recherche ce utilisateur
  my $utilisateur = schema->resultset('Utilisateur')->find($utilisateur_id);
  if (not defined $utilisateur) {
    Messages::danger("Cet utilisateur n'existe pas (numero = $utilisateur_id)");
    return vue_liste_utilisateur();
  }

  Messages::developpement("utilisateur_id = $utilisateur_id") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire
  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Utilisateur')->dfv_profil_creation;

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
    $donnees_formulaire->{utilisateur_id} = $utilisateur->utilisateur_id;
    var 'utilisateur' => schema->resultset('Utilisateur')->new($donnees_formulaire);
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_utilisateur();
  }

  # --- Aucune erreur n'est détectée par la validation, on peut modifier
  # --- on met à jour le utilisateur via la methode update_from_fv
  #     (fournie par le composant DBIx::Class::FromValidators)
  $utilisateur = $utilisateur->update_from_fv($resultats);
  if (not defined $utilisateur) {
    Messages::danger("Modification impossible!");
    return vue_liste_utilisateur();
  }
  my $cli_nom = $utilisateur->cli_nom;
  Messages::succes("Utilisateur modifié (nom: $cli_nom, numéro: $utilisateur_id)");
  var 'critere_cli_nom' => $cli_nom;
  var 'critere_cli_cp' => $utilisateur->cli_cp;
  return vue_liste_utilisateur();
};


# ---------- route GET /utilisateur/supprimer : afficher formulaire modification utilisateur
get '/supprimer/:utilisateur_id' => sub {
  my $utilisateur_id = param('utilisateur_id');
  my $utilisateur = schema->resultset('Utilisateur')->find($utilisateur_id);
  if (not defined $utilisateur) {
    Messages::danger("Ce utilisateur n'existe pas (numéro = $utilisateur_id)");
    return vue_liste_utilisateur();
  }
  var 'utilisateur' => $utilisateur;
  return vue_formulaire_suppression();
};

post '/supprimer/:utilisateur_id' => sub {
    my $utilisateur_id = param('utilisateur_id');
  my $utilisateur = schema->resultset('Utilisateur')->find($utilisateur_id);
  if (defined $utilisateur) {
    $utilisateur->delete();
    Messages::succes("Utilisateur supprimé");
  } else {
    Messages::danger("Ce utilisateur n'existe pas (numéro = $utilisateur_id)");
  }
  return vue_liste_utilisateur();
};

# ---------- route GET /utilisateur/rechercher : affichage du formulaire de recherche
get '/rechercher' => sub {
  return vue_formulaire_recherche();
};

# ---------- route GET /utilisateur/groupe : affichage des utilisateurs d'un groupe rechercher
get '/groupe' => sub {

    #recupération des params de la requette
    my $params = request->params;
    # --- profil de validation des parametres pouvant etre transmis
    my $dfv_profil = {
	required => [ qw/critere_groupe/ ],
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
    
    #param pour la vue afficher les membres d'un groupe
    var 'critere_groupe' => $resultats->valid('critere_groupe');
    
    return membre_du_groupe();
};


#------------------------------------------------------------
# les vues côté "utilisateur"
#------------------------------------------------------------

sub vue_formulaire_suppression {
  my $utilisateur = var 'utilisateur';
  template 'formulaire_suppression_utilisateur', {
    utilisateur => $utilisateur,
  };
}

sub vue_formulaire_utilisateur {
  my $utilisateur = var 'utilisateur';
  my $msgs = var 'msgs';
  #if utilisateur_id defined ??
  my $titre =
    $utilisateur->utilisateur_id == 0 ?
    "Nouveau utilisateur" :
    "Édition du utilisateur";
  template 'formulaire_utilisateur', {
    titre => $titre,
    utilisateur => $utilisateur,
    msgs => $msgs,
  };
}

sub vue_liste_utilisateur {
  my $clause_where = {}; # ce tableau associatif contiendra les critères de la clause where

  # on récupère d'éventuels paramètres
  my $critere_utilisateur_nom = var 'critere_utilisateur_nom';
  $critere_utilisateur_nom = undef if defined $critere_utilisateur_nom and $critere_utilisateur_nom eq "";
  if (defined $critere_utilisateur_nom) {
    $clause_where->{'utilisateur_nom'} = $critere_utilisateur_nom;
  }
  
  my $critere_utilisateur_prenom = var 'critere_utilisateur_prenom';
  $critere_utilisateur_prenom = undef
      if defined $critere_utilisateur_prenom and ($critere_utilisateur_prenom eq "" or $critere_utilisateur_prenom eq "*");
  if (defined $critere_utilisateur_prenom) {
    $clause_where->{'utilisateur_prenom'} = $critere_utilisateur_prenom;
  }


  Messages::developpement("Clause where:",
			  Dumper($clause_where)) if DEBUG;
  
  my $rs = schema->resultset('Utilisateur')->search(
    $clause_where,
    {
      order_by => 'utilisateur_nom',
    }
   );
  my @utilisateurs = $rs->all;

  # --- appel du template de liste
  template 'liste_utilisateur', {
      utilisateurs => \@utilisateurs,
    titre => "Liste des utilisateurs",
    critere_utilisateur_prenom => $critere_utilisateur_prenom,
    critere_utilisateur_nom => $critere_utilisateur_nom,
  };
}


#recherche des utilsateur d'un groupe
sub vue_formulaire_recherche {
    # récupération de tous les groupes d'utilisateurs existants distincts par ordre alphabetique
    
    my @liste_groupes = schema->resultset('Groupe')
	
      ->search({}, { distinct => 1, order_by => {'-asc' => 'groupe_nom'}})
      ->get_column('groupe_id')->all();
  

  Messages::developpement("liste des groupes:", Dumper(@liste_groupes)) if DEBUG;

    template 'formulaire_recherche', {
    #template 'liste_groupes', {
      liste_groupes => \@liste_groupes,
  };
}

#recherche les utilisateurs d'un groupe
sub membre_du_groupe() {
    my $clause_where = {}; # ce tableau associatif contiendra les critères de la clause where
    
    # on récupère d'éventuels paramètres
    
    ## recherche des utilisateur qui appartiennent à un groupe
    my $critere_groupe = var 'critere_groupe';
    $critere_groupe = undef if defined $critere_groupe and $critere_groupe eq "";
    my $groupe;
    
    if (defined $critere_groupe){

      ## avec liste 
      $groupe = schema->resultset('Groupe')->find($critere_groupe);
      if (defined $groupe) {
	  my @user_membres = $groupe->est_membre_utilisateurs;
	  Messages::developpement("Groupe:",
			  Dumper($groupe)) if DEBUG;
  
  
	  # --- appel du template de liste
	  template 'liste_groupes_user', {
	      liste_membre => \@user_membres,
	      groupe => $groupe,
	      titre => "Liste des utilisateurs",
	      critere_groupe => $critere_groupe,
	  };
      }
      else {
	  template 'erreur';
      }
    }

}

# fin du package (la compilation s'est bien passé)
true;

__END__

