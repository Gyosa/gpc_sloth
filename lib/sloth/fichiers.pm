package sloth::fichiers;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;

use File::Type;
use DateTime;
use DateTime::Format::Pg;
use sloth::articles;

# toutes les routes de ce module commencent implicitement par "/groupe"
prefix "/fichiers";

=head
# ---------- route POST /fichier/upload :
post '/upload' => sub {
    my $donnes_formulaire = request->params;
    my $data = request->upload('file');
 
    my $dir = path(config->{appdir}, 'uploads');
    #mkdir $dir if not -e $dir;
 
    my $path = path($dir, $data->basename);
    if (-e $path) {
	Messages::danger("ce fichier à deja été importer par le passé");
    }

    if ($data->copy_to($path)) {
	Messages::succes("fichier $path copié");
    }else {
	Messages::danger("erreur copie ficher $path");
    }

    #integration dans la bdd
    my $content = $data->content;
    my $new_file = schema->resultset('Fichier')->create({
       	fichier_contenu => $content,
	fichier_nom => "test_file",
	fichier_article_id => 2,
							
							});

    var 'path' => $path;
    var 'data' => $data;
    
    return vue_upload_liste_file();
};
=cut
########################## Upload File ########################

# ---------- route GET /fichier/upload : telecharger un fichier pour un article
get '/upload/:article_id' => sub {
    Messages::developpement("téléchargement d'un fichier") if DEBUG;
    my $article = schema->resultset('Article')->find(param('article_id'));
    var 'article' => $article;

    return vue_upload_file();
};

post '/upload/:article_id' => sub {
    my $donnes_formulaire = request->params;
    my $data = request->upload('file');
    
=head
    # trouver le type du fichier
    my $ft = File::Type->new();
    # read in data from file to $data, then
    my $type_from_data = $ft->checktype_contents($data);
=cut

    
    my $article_id = param('article_id');
    my $article =  schema->resultset('Article')->find($article_id);
    var 'article' => $article;
    
    my $fichier_nom = $data->basename;
    my $fichier_type = $data->type;
    my $fichier_content = $data->content;
    ;
    my $donnees_formulaire = request->params;
    $donnees_formulaire->{fichier_nom} = $fichier_nom;
    $donnees_formulaire->{fichier_type} = $fichier_type;    
    $donnees_formulaire->{fichier_contenu} = $fichier_content;
    $donnees_formulaire->{fichier_article_id} = $article_id;
    $donnees_formulaire->{fichier_date} = DateTime::Format::Pg->parse_datetime(DateTime->now);
      

    #return Dumper($donnees_formulaire);

    my $profil = schema->class('Fichier')->dfv_profil_fichier;
    
    my $resultats =  Data::FormValidator->check( $donnees_formulaire, $profil );
    Messages::developpement("Résultat validation:", Dumper($resultats)) if DEBUG;
    #return Dumper($resultats);
    
    # --- L'objet retourne par check a des methodes generales
    #     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
    if ( $resultats->has_invalid or $resultats->has_missing ) {
	
	# ----- Si des erreurs sont détectées par la validation:
	if($resultats->has_missing){Messages::danger("has missing");}
	if($resultats->has_invalid){Messages::danger("has invalid");}
	Messages::danger("Il y a des erreurs");
	# --- après erreur, on revient en modification sur les donnees saisies
	$donnees_formulaire->{fichier_id} = 0;
	var 'article' =>  schema->resultset('Fichier')->new($donnees_formulaire);
	var 'msgs' => $resultats->msgs;
	return sloth::articles::vue_formulaire_publication();
    } 

    # --- verifier si ce nouveau fichier est deja existant
    # --- avec le nom du fichier et l'id de l'article ce duo de colonne est forcement unique

    my @verif_files = schema->resultset('Fichier')->search({
	'fichier_nom' => $fichier_nom,
	    'fichier_article_id' => $article_id});
    
    if (scalar(@verif_files) == 0) {
	# --- ce fichier n'existe pas, creation dans la base de données
	
	warn Dumper($resultats);
	# ----- Si aucune erreur n'est détectée par la validation:
	# on doit créer le nouveau hors_serie
	my $new_fichier = schema->resultset('Fichier')->create_from_fv($resultats);
	#return Dumper($new_fichier);
	if (defined $new_fichier) {
	    Messages::succes("Fichier (numero=". $new_fichier->fichier_id() . ") ajouté");
	   
	    return sloth::articles::vue_detail_article();
	}else{
	    return "fichier non intégré dans la dbb";
	}
	
    }else{
	# --- ce nom de fichier pour cet article existe deja
	# --- archiver une version et mettre a jour la version actuelle du fichier

	my $fichier = $verif_files[0];

	# --- creation d'une nouvelle version

	
	my $donnees_version;
	$donnees_version->{version_nom} = $fichier->fichier_nom;
	$donnees_version->{version_type} = $fichier->fichier_type;    
	$donnees_version->{version_contenu} = $fichier->fichier_contenu;
	$donnees_version->{version_nb} = scalar($fichier->versions);
	$donnees_version->{version_date} = $fichier->fichier_date;
	$donnees_version->{version_commentaire} = $fichier->fichier_commentaire;
	$donnees_version->{version_fichier_id} = $fichier->fichier_id;


	my $profil_version = schema->class('Version')->dfv_profil_version;
	my $resultats_version =  Data::FormValidator->check( $donnees_version, $profil_version );
	Messages::developpement("Résultat validation:", Dumper($resultats)) if DEBUG;
	#return Dumper($resultats);
	# --- L'objet retourne par check a des methodes generales
	#     qui indiquent s'il y a eu des erreurs ou des donnees manquantes
	if ( $resultats_version->has_invalid or $resultats_version->has_missing ){
	    return Messages::danger("problème validator resultats_version");
	}

	my $new_version = schema->resultset('Version')->create_from_fv($resultats_version);
	if (defined $new_version) {
	    Messages::succes("Fichier (numero=". $new_version->version_nom." ->".$new_version->version_nb . ") ajouté");
	   
	    #return sloth::articles::vue_detail_article();
	}else{
	    Messages::danger("version non intégré dans la dbb");
	}	

	# --- modifiction de la version actuelle du fichier

	$fichier->update_from_fv($resultats);
	if (defined $fichier){
	    Messages::succes("Fichier ajouté".$fichier->fichier_nom);
	    return sloth::articles::vue_detail_article();
	}else{
	    return Messages::danger("Upadate du fichier raté")
	}
	
	
    }
	
};

get '/lire/:fichier_id' => sub {
    my $fichier_id = param('fichier_id');
    my $fichier = schema->resultset('Fichier')->find($fichier_id);
    #return Dumper($fichier);
    my $contenu = $fichier->fichier_contenu;
    my $type = $fichier->fichier_type;
    my $nom = $fichier->fichier_nom;
    #return Dumper($type);

    send_file( \$contenu, content_type=>$type, filename=>$nom);
    #afficher avec des pipe html

};

get '/supprimer/:fichier_id' => sub {
    my $fichier_id = param('fichier_id');
    my $fichier = schema->resultset('Fichier')->find($fichier_id);
    if (defined $fichier) {
	my $article = schema->resultset('Article')->find($fichier->fichier_article_id);
	# --- supprimer les versions du fichiers
	my @liste_version = $fichier->versions;
	for my $version (@liste_version) {
	    $version->delete();
	}
	#return Dumper(scalar(@liste_version));
	
	# --- supprime le fichier
	$fichier->delete();
	var 'article' => $article;
	return sloth::articles::vue_detail_article();
    }else {
	return sloth::articles::vue_liste_article();
    }
    
    

    
};

get '/lireversion/:version_id' => sub {
    my $version_id = param('version_id');
    my $version = schema->resultset('Version')->find($version_id);
    #return Dumper($version);
    my $contenu = $version->version_contenu;
    my $type = $version->version_type;
    my $nom = $version->version_nom;
    #return Dumper($type);

    send_file( \$contenu, content_type=>$type, filename=>$nom);
    #afficher avec des pipe html

};


get '/liste' => sub {

    return vue_liste_file();
};



#------------------------------------------------------------
# les vues côté "utilisateur"
#------------------------------------------------------------

sub vue_upload_file() {
    my $article = var 'article';
    template 'formulaire_upload', {
	article => $article,
    }
}
=head
sub vue_upload_liste_file() {
    Messages::succes("file upload reussite");

    my $data = var 'data';
    my $path = var 'path';

    template 'liste_file', {
	data => $data,
	path => $path,
    }
}
=cut
sub vue_liste_file() {

    my @liste_files = schema->resultset('Fichier')->all;

    template 'liste_file', {
	liste_file => \@liste_files,
    }
}

# fin du package (la compilation s'est bien passé)
true;

__END__

    
