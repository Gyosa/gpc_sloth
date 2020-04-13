package sloth::articles;
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

# toutes les routes de ce module commencent implicitement par "/articles"
prefix "/articles";

get '/liste' => sub {
  return vue_liste_article();
};

# ---------- route GET /article/afficher : afficher infos article 
get '/afficher/:article_id' => sub {
  my $a_id = param('article_id');
  my $article = schema->resultset('Article')->find($a_id);
  if (not defined $article or $article eq "") {
    Messages::danger("cet article n'existe pas (numero = $a_id)");
    return vue_liste_article();
  }
  var 'article' => $article;
  return vue_detail_article();
};

############################## Publication ###################################

# ---------- route GET /article/publication/creer : afficher formulaire publication 
get '/publication/creer' => sub {
  var 'article' => schema->resultset('Article')->new({article_id => 0});
  return vue_formulaire_publication();
};

# ---------- route POST /publication/creer
post '/publication/creer' => sub {
    
    # ===== Il faut d'abord valider les données du formulaire
    # --- le profil de validation est une methode que nous avons ajoutee
    #     a la classe DBIx::Class correspondant à la table a modifier
    my $profil = schema->class('Article')->dfv_profil_publication;
    
    # --- obtenir les données du formulaire
    my $donnees_formulaire = request->params;
    #my $to = $donnees_formulaire->{to};
    
    
    # --- valider l'ensemble des données avec le FormValidator
    my $resultats =  Data::FormValidator->check( $donnees_formulaire, $profil );
    Messages::developpement("Résultat validation:", Dumper($resultats)) if DEBUG;

    # --- L'objet retourne par check a des methodes generales
    #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
    if ( $resultats->has_invalid or $resultats->has_missing ) {
	
	# ----- Si des erreurs sont détectées par la validation:
	if($resultats->has_missing){Messages::danger("has missing");}
	if($resultats->has_invalid){Messages::danger("has invalid");}
	Messages::danger("Il y a des erreurs");
	# --- après erreur, on revient en modification sur les donnees saisies
	$donnees_formulaire->{article_id} = 0;
	my %data = %$donnees_formulaire;
	delete($data{to});
	delete($data{from});
	$donnees_formulaire = \%data;
	var 'article' =>  schema->resultset('Article')->new({article_id=>0, %{$resultats->valid}});
	var 'msgs' => $resultats->msgs;
	return vue_formulaire_publication();
    } 

    my %data = %$donnees_formulaire;
	  my @liste_article_meme_nom = schema->resultset('Article')->search({'article_nom' => $data{article_nom}});
	  if (scalar(@liste_article_meme_nom) > 0) {
	    # Il y a déjà une édition avec ce nom dans la base
	    var 'article' =>  schema->resultset('Article')->new({article_id=>0, %{$resultats->valid}});
	    var 'msgs' => $resultats->msgs;
	    return vue_formulaire_publication();
	  }
    
    warn Dumper($resultats);
    # ----- Si aucune erreur n'est détectée par la validation:
    # on doit créer le nouveau hors_serie
    my $new_article = schema->resultset('Article')->create_from_fv($resultats);
    if (defined $new_article) {
	Messages::succes("Article (numero=". $new_article->article_id() . ") ajouté");
	
	# --- ajout des relations dans la table Participation pour gerer l'ordre des redacteurs
	my $data_auteurs = $donnees_formulaire->{to};
	my @liste_auteurs_id;
	if (not defined $data_auteurs) {
	    return Dumper($data_auteurs);
	    Messages::danger("Création du nouvel article impossible il n'y a pas un seul auteur");
	}
	else{
	    # --- si un seul auteur
	    if (length($data_auteurs) == 1) {
		push(@liste_auteurs_id, $data_auteurs);
	    }# -- sinon il y a plusieurs auteurs
	    else{
		@liste_auteurs_id = @$data_auteurs;
	    }
	    # --- ajout des relalations dans Participation avec l'ordre
	    my $i = 1;
	    for my $auteur_id (@liste_auteurs_id) {
		my $data ={
		    'participation_utilisateur_id' => $auteur_id,
			'participation_article_id' => $new_article->article_id,
			'participation_ordre' => $i,
			'participation_fonction' => "Auteur"
		};
		my $rs = schema->resultset('Participation')->create($data);
		#$new_article->add_to_participations($auteur);
		
		$i +=1;
	    }   
	    
	}
	var 'article' => $new_article;
	
	#return $new_article->article_date_limite_soumission->day();
	#return Dumper($new_article->article_hors_serie_id);
	return vue_detail_article();
    }
    
};

# ---------- route GET /articles/publication/modifier/:article_id modfier les autilisateur du groupe
get '/publication/modifier/:article_id' => sub{
    
    my $article = schema->resultset('Article')->find(param('article_id'));
    if (defined $article) {
	var 'article' => $article;
	return vue_modifier_article()
    }else {
	Messages::alert("cet id d'utilisateur n'existe pas");
	return vue_liste_article()
    }
};

# ---------- route POST /articles/publication/modifier/:article_id modfier les autilisateur du groupe
post '/publication/modifier/:article_id' => sub{
    
# ===== Il faut d'abord valider les données du formulaire
    # --- le profil de validation est une methode que nous avons ajoutee
    #     a la classe DBIx::Class correspondant à la table a modifier
    my $profil = schema->class('Article')->dfv_profil_publication;
    #return Dumper($profil);
    
    
    # --- obtenir les données du formulaire
    my $donnees_formulaire = request->params;
    #return Dumper(schema->resultset('HorsSerie')->find(1));
    #return Dumper($donnees_formulaire);

    my $article_id = param('article_id');
    my $article = schema->resultset('Article')->find($article_id);
    #return Dumper($article->article_id);
    
    # --- valider l'ensemble des données avec le FormValidator
    my $resultats =  Data::FormValidator->check( $donnees_formulaire, $profil );
    Messages::developpement("Résultat validation:", Dumper($resultats)) if DEBUG;

      # --- L'objet retourne par check a des methodes generales
    #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
    if ( $resultats->has_invalid or $resultats->has_missing ) {
	
	# ----- Si des erreurs sont détectées par la validation:
	if($resultats->has_missing){Messages::danger("has missing");}
	if($resultats->has_invalid){Messages::danger("has invalid");}
	Messages::danger("Il y a des erreurs");
	# --- après erreur, on revient en modification sur les donnees saisies
	my %data = %$donnees_formulaire;
	delete($data{to});
	delete($data{from});
	$donnees_formulaire = \%data;
	var 'article' =>  schema->resultset('Article')->find($donnees_formulaire->{article_id});
	var 'msgs' => $resultats->msgs;
	return vue_modifier_article();
    } 
    
    # --- suppresions des relations dans la tables Participation
    my $rs = schema->resultset('Participation')->search({
	'participation_article_id' => $article_id})->delete();
    
    # --- retirer les ref dans les 3 clés secondaire vers Journal & Hors Serie
    $article->update({'article_revue_id' => undef});
    $article->update({'article_hors_serie_id' => undef});
    
    warn Dumper($resultats);
    # --- Si aucune erreur n'est détectée par la validation:
    # on doit mettre a jour l'article
    #return Dumper($resultats);
    $article = $article->update_from_fv($resultats);
    if (defined $article) {
	Messages::succes("Article (numero=". $article->article_id . ") modifié");

	
	
	# --- ajout des relations dans la table Participation pour gerer l'ordre des redacteurs
	my $data_auteurs = $donnees_formulaire->{to};
	my @liste_auteurs_id;
	if (not defined $data_auteurs) {
	    return Dumper($data_auteurs);
	    Messages::danger("Modification de l' article impossible il n'y a pas un seul auteur");
	}
	else{
	    # --- si un seul auteur
	    if (length($data_auteurs) == 1) {
		push(@liste_auteurs_id, $data_auteurs);
	    }# -- sinon il y a plusieurs auteurs
	    else{
		@liste_auteurs_id = @$data_auteurs;
	    }
	    # --- ajout des realations dans Participation avec l'ordre
	    my $i = 1;
	    for my $auteur_id (@liste_auteurs_id) {
		my $data ={
		    'participation_utilisateur_id' => $auteur_id,
			'participation_article_id' => $article_id,
			'participation_ordre' => $i,
			'participation_fonction' => "Auteur"
		};
		my $rs = schema->resultset('Participation')->create($data);
		#$new_article->add_to_participations($auteur);
		
		$i +=1;
	    }   
	    
	}
	var 'article' => $article;
	#return $new_article->article_date_limite_soumission->day();
	#return Dumper($new_article->article_date_limite_soumission);
	return vue_detail_article();
    }

    
};

############################## Communication ###################################



# ---------- route GET /article/communication/creer : afficher formulaire communication 
get '/communication/creer' => sub {
  var 'article' => schema->resultset('Article')->new({article_id => 0});
  return vue_formulaire_communication();
};


# ---------- route POST
post '/communication/creer' => sub {
  Messages::developpement("Création d'un nouvel article") if DEBUG;

  # ===== Il faut d'abord valider les données du formulaire

  # --- le profil de validation est une methode que nous avons ajoutee
  #     a la classe DBIx::Class correspondant à la table a modifier
  my $profil = schema->class('Article')->dfv_profil_creation_communication;


  # --- obtenir les paramètres
  my $donnees_formulaire = request->params;
  
  $donnees_formulaire->{article_date_limite_soumission} = $donnees_formulaire->{article_date_limite_soumission}[0];

  Messages::developpement("Résultat du formulaire:", Dumper($donnees_formulaire)) if DEBUG;
  
  # --- check valide l'ensemble des donnees passees dans la query
  #     en fonction des contraintes exprimées dans le profil de validation.
  my $resultats = Data::FormValidator->check( $donnees_formulaire, $profil );
  Messages::developpement("Résultat validation:", Dumper($resultats)) if DEBUG;

  # --- L'objet retourne par check a des methodes generales
  #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
  if ( $resultats->has_invalid or $resultats->has_missing ) {
    
      # ----- Si des erreurs sont détectées par la validation:
    if($resultats->has_missing){Messages::danger("has missing");}
    if($resultats->has_invalid){Messages::danger("has invalid");}
    Messages::danger("Il y a des erreurs");
    # --- après erreur, on revient en modification sur les donnees saisies
      my %data = %$donnees_formulaire;
			delete( $data{to} );
			delete( $data{from} );
			my $donnees_formulaire = \%data;

    # $donnees_formulaire->{article_id} = 0;
    var 'article' =>  schema->resultset('Article')->new({article_id=>0, %{$resultats->valid}});

      Messages::developpement("Résultat création:", Dumper(var 'article')) if DEBUG;
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_communication();
  } 

  my %data = %$donnees_formulaire;
  my @liste_article_meme_nom = schema->resultset('Article')->search({'article_nom' => $data{article_nom}});
  if (scalar(@liste_article_meme_nom) > 0) {
    # Il y a déjà une édition avec ce nom dans la base
    var 'article' =>  schema->resultset('Article')->new({article_id=>0, %{$resultats->valid}});
    var 'msgs' => $resultats->msgs;
    return vue_formulaire_communication();
  }

  warn Dumper($resultats);
  # ----- Si aucune erreur n'est détectée par la validation:
  # on doit créer le nouveau hors_serie
  my $new_article = schema->resultset('Article')->create_from_fv($resultats);
  if (defined $new_article) {
    Messages::succes("Article (numero=". $new_article->article_id() . ") ajouté");
  } else {
    Messages::danger("Création du nouvel article impossible");
  }
  var 'article' => $new_article;
  return vue_detail_article();
};

# ---------- route GET /articles/communication/modifier/:article_id modfier les autilisateur du groupe
get '/communication/modifier/:article_id' => sub{
    
    my $article = schema->resultset('Article')->find(param('article_id'));
    if (defined $article) {
	var 'article' => $article;
	return vue_modifier_article()
    }else {
	Messages::alert("cet id d'utilisateur n'existe pas");
	return vue_liste_article()
    }
};


# ---------- route POST /articles/communication/modifier/:article_id modfier les autilisateur du groupe
post '/communication/modifier/:article_id' => sub{
    
# ===== Il faut d'abord valider les données du formulaire
    # --- le profil de validation est une methode que nous avons ajoutee
    #     a la classe DBIx::Class correspondant à la table a modifier
    my $profil = schema->class('Article')->dfv_profil_creation_communication;
    #return Dumper($profil);
    
    
    # --- obtenir les données du formulaire
    my $donnees_formulaire = request->params;
    #return Dumper($donnees_formulaire);

    my $article_id = param('article_id');
    my $article = schema->resultset('Article')->find($article_id);
    #return Dumper($article->article_id);
    
    # --- valider l'ensemble des données avec le FormValidator
    my $resultats =  Data::FormValidator->check( $donnees_formulaire, $profil );
    Messages::developpement("Résultat validation:", Dumper($resultats)) if DEBUG;

      # --- L'objet retourne par check a des methodes generales
    #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
    if ( $resultats->has_invalid or $resultats->has_missing ) {
	
	# ----- Si des erreurs sont détectées par la validation:
	if($resultats->has_missing){Messages::danger("has missing");}
	if($resultats->has_invalid){Messages::danger("has invalid");}
	Messages::danger("Il y a des erreurs");
	# --- après erreur, on revient en modification sur les donnees saisies
	my %data = %$donnees_formulaire;
	delete($data{to});
	delete($data{from});
	$donnees_formulaire = \%data;
	var 'article' =>  schema->resultset('Article')->find($donnees_formulaire->{article_id});
	var 'msgs' => $resultats->msgs;
	return vue_modifier_article();
    } 
    
    # --- suppresions des relations dans la tables Participation
    my $rs = schema->resultset('Participation')->search({
	'participation_article_id' => $article_id})->delete();
    
    # --- retirer les ref dans les 3 clés secondaire vers Journal & Hors Serie
    $article->update({'article_edition_conf_id' => undef});
    
    warn Dumper($resultats);
    # --- Si aucune erreur n'est détectée par la validation:
    # on doit mettre a jour l'article
    $article = $article->update_from_fv($resultats);
    if (defined $article) {
	Messages::succes("Article (numero=". $article->article_id . ") modifié");

	
	
	# --- ajout des relations dans la table Participation pour gerer l'ordre des redacteurs
	my $data_auteurs = $donnees_formulaire->{to};
	my @liste_auteurs_id;
	if (not defined $data_auteurs) {
	    return Dumper($data_auteurs);
	    Messages::danger("Modification de l' article impossible il n'y a pas un seul auteur");
	}
	else{
	    # --- si un seul auteur
	    if (length($data_auteurs) == 1) {
		push(@liste_auteurs_id, $data_auteurs);
	    }# -- sinon il y a plusieurs auteurs
	    else{
		@liste_auteurs_id = @$data_auteurs;
	    }
	    # --- ajout des realations dans Participation avec l'ordre
	    my $i = 1;
	    for my $auteur_id (@liste_auteurs_id) {
		my $data ={
		    'participation_utilisateur_id' => $auteur_id,
			'participation_article_id' => $article_id,
			'participation_ordre' => $i,
			'participation_fonction' => "Auteur"
		};
		my $rs = schema->resultset('Participation')->create($data);
		#$new_article->add_to_participations($auteur);
		
		$i +=1;
	    }   
	    
	}
	var 'article' => $article;
	#return $new_article->article_date_limite_soumission->day();
	#return Dumper($new_article->article_date_limite_soumission);
	return vue_detail_article();
    }

    
};

#------------------------------------------------------------
# les vues côté "article"
#------------------------------------------------------------

sub vue_modifier_article {
    my @this_article;
    my $article = var 'article';
    my @liste_membres = $article->participations_utilisateurs;
    

    my $typeArticle;
    my @parentArticle;
    if (defined $article->article_edition_conf_id 
	or not $article->article_edition_conf_id eq "") {
	# C'est une communication pour une édition de conf
	$typeArticle = 1;
	push(@parentArticle, $article->article_edition_conf);
    } else {
	if (defined $article->article_hors_serie_id 
	    or not $article->article_hors_serie_id eq "") {
	    # C'est une publication pour un hors série
	    $typeArticle = 2;
	    push(@parentArticle, $article->article_hors_serie, $article->article_revue);
	} else {
	    if (defined $article->article_revue_id 
		or not $article->article_revue_id eq "") {
		# C'est une publication pour une revue
		$typeArticle = 3;
		push(@parentArticle, $article->article_revue);
	    }
	}
    }
    # --- list push des infos relatif à l'article
    push(@this_article, $article, \@liste_membres,  $typeArticle, \@parentArticle);

    my @liste_editions = schema-> resultset('Conference')->all();
    
    my @liste_revues = schema->resultset('Revue')->all();
    # --- liste des revues et ses hors series
    my @liste_revues_hs;
    for my $revue (@liste_revues) {
	my @liste_hs = $revue->hors_series;
	my @add;    
	push(@add, $revue, scalar(@liste_hs), \@liste_hs);
	push(@liste_revues_hs, \@add);
    }

    # --- trouver les utilisateur qui ne sont pas auteurs
    my @liste_membre_id;
    for my $membre (@liste_membres) {
	push(@liste_membre_id, $membre->utilisateur_id);
    }
    
    my @liste_utilisateurs = schema->resultset('Utilisateur')->search({
	 utilisateur_id => {
	    -not_in=>\@liste_membre_id}
								      });

    my @liste_statut = schema->resultset('Statut')->all();
    
    
    template 'modifier_article', {
	titre => "modifier_article",
	this_article => \@this_article,
	liste_revues_hs => \@liste_revues_hs,
	liste_editions => \@liste_editions,
	liste_utilisateurs => \@liste_utilisateurs,
	liste_statut => \@liste_statut    }
}

get '/supprimer/:article_id' => sub {
  my $a_id = param('article_id');
  my $article = schema->resultset('Article')->find($a_id);
  if (not defined $article or $article eq "") {
    Messages::danger("cet article n'existe pas (numero = $a_id)");
    return vue_liste_article();
  } else {
    my @fichiers = schema->resultset('Fichier')->search({fichier_article_id => $a_id });
    # --- suppression de tous les utilisateur de ce groupe
    for my $fichier (@fichiers) {
      $fichier->delete;
    }  

    my @participations = schema->resultset('Participation')->search({participation_article_id => $a_id });
    # --- suppression de tous les utilisateur de ce groupe
    for my $participation (@participations) {
      $participation->delete;
    }
    $article->delete;

    return vue_liste_article();
  }
};


sub vue_formulaire_suppression {
  my $article = var 'article';
  template 'formulaire_suppression_article', {
    article => $article,
  };
}

sub vue_formulaire_publication{
  my $article = var 'article';
  my $msgs = var 'msgs';
  my $titre =
     $article->article_id == 0 ?
     "Nouvel article pour une revue ou un de ses hors série" :
     "Modification de la publication";
  my @liste_revues = schema->resultset('Revue')->all();
  my @liste_hors_series = schema->resultset('HorsSerie')->all();
  my @liste_statuts = schema->resultset('Statut')->all();
  my @liste_utilisateurs = schema->resultset('Utilisateur')->all();
  # --- liste des revues et ses hors series
  my @liste_revues_hs;
  for my $revue (@liste_revues) {
      my @liste_hs = $revue->hors_series;
      my @add;    
      push(@add, $revue, scalar(@liste_hs), \@liste_hs);
      push(@liste_revues_hs, \@add);
  }

  template 'formulaire_publication', {
    titre => $titre,
    article => $article,
    msgs => $msgs,
    liste_revues_hs => \@liste_revues_hs,
    liste_hors_series => \@liste_hors_series,
    liste_statuts => \@liste_statuts,
    liste_utilisateurs => \@liste_utilisateurs,
   };
}

sub vue_formulaire_communication{
  my $article = var 'article';
  my $msgs = var 'msgs';
  my $titre =
     $article->article_id == 0 ?
     "Nouvel article pour une édition de conférence" :
     "Modification de la communication";

  # Affichache des édition non terminée uniquement
  my $today = DateTime->now;
  $today = DateTime::Format::Pg->parse_datetime($today);
  my @liste_editions = schema->resultset('EditionConf')->search({
  	-or => [ edition_conf_date_limite_soumission => {'>' => $today},
             edition_conf_date_limite_soumission => {'=' => $today}
             ]}) -> all();
  my @liste_statuts = schema->resultset('Statut')->all();
  my @liste_utilisateurs = schema->resultset('Utilisateur')->all();

  template 'formulaire_communication', {
    titre => $titre,
    article => $article,
    msgs => $msgs,
    liste_editions => \@liste_editions,
    liste_statuts => \@liste_statuts,
    liste_utilisateurs => \@liste_utilisateurs,
   };
}

sub vue_detail_article{
    my $article = var 'article';
    my $statut = $article->article_statut;
    my $typeArticle;
    my @parentArticle;
    if (defined $article->article_edition_conf_id 
	or not $article->article_edition_conf_id eq "") {
	# C'est une communication pour une édition de conf
	$typeArticle = 1;
	push(@parentArticle, $article->article_edition_conf);
    } else {
	if (defined $article->article_hors_serie_id 
	    or not $article->article_hors_serie_id eq "") {
	    # C'est une publication pour un hors série
	    $typeArticle = 2;
	    push(@parentArticle, $article->article_hors_serie, $article->article_revue);
	} else {
	    if (defined $article->article_revue_id 
		or not $article->article_revue_id eq "") {
		# C'est une publication pour une revue
		$typeArticle = 3;
		push(@parentArticle, $article->article_revue);
	    }
	}
    }
    # --- ajout de la liste des auteurs
    my @liste_auteurs = schema->resultset('Utilisateur')->search(
        {'participation_article_id' => $article->article_id,
	},
	{join => 'participations',
	 order_by => {'-asc' => 'participations.participation_ordre'},
	});

    # --- recuperer la liste des fichiers assicié a l'article
    my @liste_fichiers = $article->fichiers;
    my @fichiers;
    my @fichier_version;
    for my $fichier (@liste_fichiers) {
	my @liste_versions = $fichier->versions;
	my @versions;
	push(@versions, $fichier,  scalar(@liste_versions), \@liste_versions);
	push(@fichier_version, \@versions);
    }
    push(@fichiers, scalar(@fichier_version), \@fichier_version);
    
    #return Dumper($liste_auteurs[0]->utilisateur_auth);
    my @this_article;
    push(@this_article, $article, $typeArticle, \@parentArticle, $statut, \@liste_auteurs);
    template 'detail_article', {
	article => \@this_article,
	fichiers => \@fichiers,
  }
}

sub vue_liste_article {
  #récuperation de la liste des articles existants
  my @liste_articles;
  my @liste_des_articles = schema->resultset('Article')->all();
  if (scalar(@liste_des_articles) > 0) {
      # pour chaque article on cherche son statut, son type publi ou commu et son "parent"
      for my $article (@liste_des_articles) {
	  my $statut = $article->article_statut;
	  my $typeArticle;
	  my @parentArticle;
	  my @liste_auteurs;
	  if (defined $article->article_edition_conf_id 
	      or not $article->article_edition_conf_id eq "") {
	      # C'est une communication pour une édition de conf
	      $typeArticle = 1;
	      push(@parentArticle, $article->article_edition_conf);
	  } else {
	      if (defined $article->article_hors_serie_id 
		  or not $article->article_hors_serie_id eq "") {
		  # C'est une publication pour un hors série
		  $typeArticle = 2;
		  push(@parentArticle, $article->article_hors_serie, $article->article_revue);
	      } else {
		  if (defined $article->article_revue_id 
		      or not $article->article_revue_id eq "") {
		      # C'est une publication pour une revue
		      $typeArticle = 3;
		      push(@parentArticle, $article->article_revue);
		  }      # --- ajout de la liste des auteurs
	  }
	  @liste_auteurs = schema->resultset('Utilisateur')->search(
	      {'participation_article_id' => $article->article_id,
	      },
	      {join => 'participations',
	       order_by => {'-asc' => 'participations.participation_ordre'},
	      });
	  #return Dumper($liste_auteurs[0]->utilisateur_auth);
	  #return Dumper(scalar(@liste_auteurs));
      }
	  my @this_article;
	  push(@this_article, $article, $typeArticle, \@parentArticle, $statut, \@liste_auteurs);
	  push(@liste_articles, \@this_article);
      }
  } else {
      Messages::developpement("liste des article est vide"); 
  }
  # --- appel du template de liste
  template 'liste_articles', {
      liste_articles => \@liste_articles,
      titre => "Liste des articles",
  }
};


# fin du package (la compilation s'est bien passé)
true;

__END__

## comprehension fin
