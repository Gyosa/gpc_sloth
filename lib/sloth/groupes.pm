package sloth::groupe;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper qw(Dumper);
binmode STDOUT, ":utf8";
use constant DEBUG => sloth::DEBUG;
# pour utliser reftype
use Scalar::Util qw/reftype/;

# toutes les routes de ce module commencent implicitement par "/groupe"
prefix "/groupes";

# ---------- route GET /groupes/liste : afficher la liste des groupes
get '/liste' => sub {
    Messages::developpement("Affichage liste des groupes") if DEBUG;

    return vue_liste_groupe();
};

# ---------- route GET /groupes/modifier/groupe_id : afficher le detail d'un groupe
get '/modifier/:groupe_id' => sub {
    Messages::developpement("Affichage du détail d'un groupe") if DEBUG;
    my $groupe_id = param('groupe_id');
    my $groupe = schema->resultset('Groupe')->find($groupe_id);
    if (not defined $groupe) {
	Messages::danger("ce groupe n'existe pas groupe id =".$groupe_id." !");
    }
    var 'groupe' => $groupe;
    return vue_modifier_groupe();
};

# ---------- route POST /groupes/modifier/groupe_id : afficher le detail d'un group
post '/modifier/:groupe_id' => sub {
    
    # ===== Il faut d'abord valider les données du formulaire
    # --- le profil de validation est une methode que nous avons ajoutee
    #     a la classe DBIx::Class correspondant à la table a modifier
    my $profil = schema->class('Groupe')->dfv_profil_modification;
    my $donnees_formulaire = request->params;

    my $groupe_id = param('groupe_id');
    my $groupe = schema->resultset('Groupe')->find($groupe_id);
    
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
	my $groupe_id = $donnees_formulaire->{groupe_id};
	my %data = %$donnees_formulaire;
	delete($data{to});
	delete($data{from});
	$donnees_formulaire = \%data;
	var 'groupe' =>  schema->resultset('Groupe')->find($groupe_id);
	var 'msgs' => $resultats->msgs;
	return vue_modifier_groupe();
	
    }else{
	
	warn Dumper($resultats);
		
	# ----- Si aucune erreur n'est détectée par la validation:
	# on doit modifier le groupe
	$groupe = $groupe->update_from_fv($resultats);
	
	if (not defined $groupe) {
	    Messages::danger("Modification impossible!");
	    return vue_liste_groupe();
	}else{
	    # --- recup de la liste des user qui seront dans le groupe après validation
	    my $data_ref = $donnees_formulaire->{to};
	    my @liste_membres_groupe;
	    #return Dumper($data_ref);
	    # --- if undef
	    if ( ! defined $data_ref) {
		#return "undef val for data_ref";
	    }else{
		# --- si il y a q'un utilisateur
		if (length($data_ref) == 1){
		    #return scalar($data_ref);
		    push(@liste_membres_groupe, $data_ref);
		    #return "if ->".scalar(Dumper(@liste_membres_groupe));
		    
		}
		# --- sinon
		else{
		    @liste_membres_groupe = @$data_ref;
		    #return "else ->".scalar(Dumper(@liste_membres_groupe));
		}

		# --- supression des relations deja existantes pour ce groupe
		my @groupe_utilisateurs = schema->resultset('EstMembre')->search({
		    'est_membre_groupe_id'=>$groupe_id});
		for my $utilisateur (@groupe_utilisateurs) {
		    $utilisateur->delete();
		}

		
		if (scalar(@liste_membres_groupe)>0){
		    for my $membre_groupe_id (@liste_membres_groupe){
			my $data = {
			    'est_membre_groupe_id'=>$groupe_id,
				'est_membre_utilisateur_id'=>$membre_groupe_id};
			my $rs = schema->resultset('EstMembre')->create($data);
		    }
		}else{
		    Messages::developpement("pas d'utilisateur dans le groupe");		
		}
		
	    }
	    var 'critere_group_nom' => $groupe->groupe_nom;
	    
	    return vue_liste_groupe();
	    
	}
    }
};

# ---------- route GET /groupes/creer : afficher le formulaire de création d'un groupe
get '/creer' => sub {
    Messages::developpement("Formualaire de création d'un nouveau groupe") if DEBUG;

    return vue_creer_groupes();
};


#---------- route POST /groupes/creer : créer un nouveau groupe !
post '/creer' => sub {
    Messages::developpement("Création d'un nouveau utilisateur") if DEBUG;
    
    # ===== Il faut d'abord valider les données du formulaire
    # --- le profil de validation est une methode que nous avons ajoutee
    #     a la classe DBIx::Class correspondant à la table a modifier
    my $profil = schema->class('Groupe')->dfv_profil_creation;
    my $donnees_formulaire = request->params; #obtenir les parmètres

    my $data_ref = $donnees_formulaire->{to};
    my @liste_membres_groupe;
    #return Dumper($data_ref);
    # --- if undef
    if ( ! defined $data_ref) {
	#return "undef val for data_ref";
    } 
    else{
	# --- si il y a q'un utilisateur
	if (length($data_ref) == 1){
	    #return scalar($data_ref);
	    push(@liste_membres_groupe, $data_ref);
	    #return "if ->".scalar(Dumper(@liste_membres_groupe));
	    
	}
	# --- sinon
	else{
	    @liste_membres_groupe = @$data_ref;
	    #return "else ->".scalar(Dumper(@liste_membres_groupe));
	}
    }

    #     en fonction des contraintes exprimées dans le profil de validation.
    my $resultats = Data::FormValidator->check( $donnees_formulaire, $profil );
    Messages::developpement("Résultat validation:",
			  Dumper($resultats)) if DEBUG;
    #return Dumper($resultats);
    # --- L'objet retourne par check a des methodes generales
    #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
    if ( $resultats->has_invalid or $resultats->has_missing ) {
	# ----- Si des erreurs sont détectées par la validation:
	if($resultats->has_missing){Messages::danger("has missing");}
	if($resultats->has_invalid){Messages::danger("has invalid");}
	Messages::danger("Il y a des erreurs");
	
	# --- après erreur, on revient en modification sur les donnees saisies
	$donnees_formulaire->{groupe_id} = 0;
	return Dumper($resultats->valid);
	var 'groupe' =>  schema->resultset('Groupe')->new(%{$resultats->valid});
	var 'msgs' => $resultats->msgs;
	return vue_creer_groupes();
	
    }else{
	
	warn Dumper($resultats);
		
	# ----- Si aucune erreur n'est détectée par la validation:
	# on doit créer le nouveau groupe
	my $nouveau_groupe = schema->resultset('Groupe')->create_from_fv($resultats);
	
	if (defined $nouveau_groupe) {
	    Messages::succes("Groupe (nom=". $nouveau_groupe->groupe_nom() .") ajouté avec succes");
	    # ajout dans la table est membre les user de ce groupe
	    my $groupe_id = $nouveau_groupe->groupe_id;
	    
	    #return Dumper(@liste_membres_groupe);
	    
	    if (scalar(@liste_membres_groupe)>0){
		for my $membre_groupe_id (@liste_membres_groupe){
		    my $data = {
			'est_membre_groupe_id'=>$groupe_id,
			    'est_membre_utilisateur_id'=>$membre_groupe_id};
		    my $rs = schema->resultset('EstMembre')->create($data);
		}
	    }else{
		Messages::developpement("pas d'utilisateur dans le groupe");		
	    }
	    
	    var 'critere_group_nom' => $nouveau_groupe->groupe_nom;

	}else{
	    Messages::danger("Création d'un nouvel utilisateur impossible");
	}
	return vue_liste_groupe();
	
    }
    
};

#routine pour ajouter une realtion dans la tables est membre à partir du user id et du groupe id
=head
sub ajouter_relation_est_membre() {
    my ($groupe_id, $utilisateur_id ) = @_;
    my $data = {
	'est_membre_groupe_id'=>$groupe_id,
	    'est_membre_utilisateur_id'=>$utilisateur_id};
    my $rs = schema->resultset('EstMembre')->create($data);    
}
=cut

# ---------- route get /groupes/supprimer/:groupe_id : supprimer un groupe avec son id
get '/supprimer/:groupe_id' => sub {
    my $groupe_id = param('groupe_id');
    my $groupe = schema->resultset('Groupe')->find($groupe_id);
    my @utilisateurs_groupe = schema->resultset('EstMembre')->search({
	est_membre_groupe_id => $groupe_id});
    if (defined $groupe) {
	# suppresion des relations dans est membres
	if (scalar(@utilisateurs_groupe)>0){
	    for my $utilisateur_groupe (@utilisateurs_groupe){
		$utilisateur_groupe->delete();
	    }
	} else {
	    Messages::developpement("ce groupe n'avait pas d'utilisateur");
	}
	#suppression du groupe
	$groupe->delete();
	Messages::developpement("groupe supprimé");
    } else {
	Messages::danger("Ce groupe n'existe pas (numéro = $groupe_id)");
    }
    return vue_liste_groupe();
};


#------------------------------------------------------------
# les vues côté "utilisateur"
#------------------------------------------------------------

#cherhche tous les groupes et les utilsateurs de ces groupes
sub vue_liste_groupe() {

    #récuperation de la liste de tous les groupes
    my @liste_groupes;
    my @liste_des_groupes = schema->resultset('Groupe')->all();

    if (scalar(@liste_des_groupes) > 0) {
	Messages::developpement("liste_groupes:", Dumper(@liste_groupes)) if DEBUG;
	# pour chaque groupe cherche la liste des utilisateurs de ce groupe
	for my $groupe (@liste_des_groupes) {
	    my @liste_membre = $groupe->est_membre_utilisateurs;

	    my @this_groupe;
	    push(@this_groupe, $groupe,  \@liste_membre);
	    push(@liste_groupes, \@this_groupe);
	}
    }
    else{
	Messages::developpement("la liste des groupes est vide"); 
    }

    #--- appel du template de la liste des groupes
    template 'liste_groupes', {
	liste_groupes => \@liste_groupes,
    };
}

sub vue_modifier_groupe(){
    #récuperation de la liste de tous les groupes
    
    my $groupe = var 'groupe';
    my @my_groupe;

    my @liste_membre = $groupe->est_membre_utilisateurs;

    push(@my_groupe, $groupe,  \@liste_membre);

    
    my @liste_membre_id;
    for my $membre (@liste_membre) {
	push(@liste_membre_id, $membre->utilisateur_id);
    }
    #return Dumper(qw/ceci est un test/);
    # recuperation de la liste des utilisateur de l'application
    #---
    #my @liste_utilisateurs = schema->resultset('Utilisateur')->all();
    my @liste_utilisateurs =schema->resultset('Utilisateur')->search({
	utilisateur_id => {
	    -not_in=>\@liste_membre_id}
								  });

    #--- appel du template de la liste des groupes
    template 'modifier_groupes', {
	my_groupe => \@my_groupe,
	liste_utilisateurs => \@liste_utilisateurs,
    };
}

sub vue_creer_groupes {
   
    # recuperation de la liste des utilisateur de l'application
    #---
    my @liste_utilisateurs = schema->resultset('Utilisateur')->all();

    template 'creer_groupes', {
	liste_utilisateurs => \@liste_utilisateurs,
    };
}

# fin du package (la compilation s'est bien passé)
true;

__END__
