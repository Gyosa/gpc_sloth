package sloth::mes_articles;
use strict;
use warnings;
# ce module apparatient à l'application 'sloth';
use Dancer2 appname => 'sloth';
use Dancer2::Plugin::DBIC;      # accès aux classes DBI (mot-clé: schema)
# pour de le debug
use Data::Dumper;
use constant DEBUG => sloth::DEBUG;

# toutes les routes de ce module commencent implicitement par "/articles"
prefix "/mes_articles";

get '/liste' => sub {
  my $rs = schema->resultset('Utilisateur')->search({'utilisateur_auth' => $ENV{REMOTE_USER}});
  my @utilisateurs = $rs->all;

  var 'utilisateur' => shift @utilisateurs;
  return vue_mes_article();
};

#------------------------------------------------------------
# les vues côté "article"
#------------------------------------------------------------

sub vue_mes_article {
  my $utilisateur = var 'utilisateur';

  #récuperation de la liste des articles existants
  my @liste_articles;
  my @liste_des_articles = $utilisateur->participation_articles;

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
      }
      }      
      # --- ajout de la liste des auteurs
      @liste_auteurs = schema->resultset('Utilisateur')->search(
          {'participation_article_id' => $article->article_id,
      },
      {join => 'participations',
       order_by => {'-asc' => 'participations.participation_ordre'},
      })->all();
    }
      my @this_article;
      push(@this_article, $article, $typeArticle, \@parentArticle, $statut, \@liste_auteurs);
      push(@liste_articles, \@this_article);
    }
  } else {
    Messages::developpement("liste des article est vide"); 
  }
  # --- appel du template de liste
  template 'mes_articles', {
    liste_articles => \@liste_articles,
    utilisateur => $utilisateur,
  };
}

true;

__END__
