package sloth::dashboard;
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
prefix "/dashboard";

get '' => sub {
    
    
    return vue_dashboard();
};


#------------------------------------------------------------
# les vues côté "article"
#------------------------------------------------------------

sub vue_dashboard {

    # recupération de tous les articles en cours de publications
    # --- count de tout les articles
    my $count_tot = scalar(schema->resultset('Article')->all);
    
    my @liste_article_redac;
    my @liste_article_attente;
    # --- statut_id : 1-accepte;2-online;3-publie;4-refuse;5-attente;6-redaction
    # --- liste des en cours de redac
    my @liste_redac;
    my $count_redac;
    @liste_redac = schema->resultset('Article')->search({article_statut_id => '6'});
    #@liste_redac = schema->resultset('Article')->all;
    $count_redac = scalar(@liste_redac);
    #push(@liste_article_redac, \@liste_redac, $count_redac);
    #return "count : ".Dumper($count)."\n".Dumper(@liste);
    
    # --- liste des art en attentes
    my @liste_attente;
    my $count_attente;
    @liste_attente = schema->resultset('Article')->search({
	article_statut_id => '5'});
    $count_attente = scalar(@liste_attente);

    my @liste_accepte;
    my $count_accepte;
    @liste_attente = schema->resultset('Article')->search({
    article_statut_id => '1'});
    $count_accepte = scalar(@liste_accepte);
    #push(@liste_article_attente, \@liste_attente, $count_attente);

    #return Dumper($count_redac);

    # --- liste des article publié et online
    my @liste_pub = schema->resultset('Article')->search({
	article_statut_id => ['2','3']});
    my $count_pub = scalar(@liste_pub);

    # --- calcul
    my $ratio_pub_tot = $count_pub/$count_tot;

    # --- gestion des publications sur les 12 derniers mois
    # ---
    
    my $dt_year = DateTime->now;
    $dt_year->set_year($dt_year->year - 1);
    $dt_year->set_month($dt_year->month + 6);
    
    #return Dumper($dt_year->dt_year);
    # --- recherche des art avec une date archiv ou soumiss de moins de 1 an ou undef
    $dt_year = DateTime::Format::Pg->format_datetime($dt_year);
    my @liste_tot_last_year = schema->resultset('Article')->search({
	-or => [
	     article_date_limite_soumission => {'>' => $dt_year},
	     article_date_limite_soumission => undef,
	     article_date_archivage => {'>' => $dt_year},
	     article_date_archivage => undef,
	    ]
							       });

    my @list_pub;
    my @list_ref;
    my @list_att; 
    my @list_red;

    for my $art (@liste_tot_last_year) {
	if ($art->article_statut_id == qw/1 2 3/){
	    push(@list_pub, $art);
	}
	elsif ($art->article_statut_id == '4'){
	    push(@list_ref, $art);
	}
	elsif ($art->article_statut_id == '5'){
	    push(@list_att, $art);
	}
	elsif ($art->article_statut_id == '6'){
	    push(@list_red, $art);
	}
	else {}
    }
    my @liste_last_year;
    push(@liste_last_year, \@list_pub, scalar(@list_pub), \@list_ref, scalar(@list_ref), \@list_att, scalar(@list_att), \@list_red, scalar(@list_red));

    #return Dumper(@liste_last_year[1]);
    
    # --- gestion des alert pour les 1,3,6 derniers mois
    # ---
    my $dt_month = DateTime->now;
    my @months;
    push(@months, 1, 3, 6);
    my @liste_art_alerte = schema->resultset('Article')->all;
    my @liste_alerte;
    
    for my $m (@months) {
	# --- ajouter les articles dont la date de soummisions est à moins de m mois
	my $dt = $dt_month;
	# --- si on doit changer d'année avec les n mois en mois 
	if ($dt_month->month + $m > 12) {
	    $dt->set_year($dt_month->year + 1);
	    $dt->set_month($dt_month->month - 12 + $m);
	    return $m."je suis de passage : ".$dt->year." :".$dt->month;
	}else {
	    $dt->set_month($dt->month + $m);
	}
	$dt = DateTime::Format::Pg->parse_datetime($dt);
	#return $dt;
	my @liste = schema->resultset('Article')->search({
	    article_date_limite_soumission => {'<' => $dt},
							 });
	push(@liste_alerte, \@liste);
	
    }
    
    #return Dumper(length($liste_alerte[0]))." & ".Dumper(length($liste_alerte[1]))." & ".Dumper(length($liste_alerte[2]));

    
    # --- appel du template du dashboard
    template 'tableau_de_bord', {
	titre => "Mon tableau de bord",
	#liste_article_redac => @liste_article_redac,
	#liste_article_attente => @liste_article_attente,
	liste_redac => \@liste_redac,
	count_redac => $count_redac,
	liste_attente => \@liste_attente,
	count_attente => $count_attente,
    liste_accepte => \@liste_accepte,
    count_accepte => $count_accepte,
	ratio_pub_tot => $ratio_pub_tot,
	liste_alerte => \@liste_alerte,
	liste_last_year => \@liste_last_year,
    };
}

# fin du package (la compilation s'est bien passé)
true;

__END__


## comprehension fin
