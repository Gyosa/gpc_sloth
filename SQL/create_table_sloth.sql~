drop table if exists utilisateur cascade ;
drop table if exists groupe cascade;
drop table if exists est_membre cascade;
drop table if exists conference cascade;
drop table if exists edition_conf cascade;
drop table if exists journal cascade;
drop table if exists fichier cascade;
drop table if exists statut cascade;
drop table if exists hors_serie cascade;
drop table if exists article cascade;
drop table if exists participation cascade; 


create table utilisateur (
    utilisateur_id varchar(60) primary key,
    utilisateur_nom varchar(60) not null,
    utilisateur_prenom varchar(60) not null
      ) ;


create table groupe (
    groupe_id varchar (60) primary key,
    groupe_nom varchar(60) not null,
    groupe_description varchar(150)
      ) ;



create table est_membre (
	est_membre_groupe_id varchar (60) not null,
	est_membre_utilisateur_id varchar(60) not null,
	primary key (est_membre_groupe_id, est_membre_utilisateur_id),
	constraint est_membre_est_membre_groupe_id_fkey foreign key (est_membre_groupe_id)
		references groupe (groupe_id) match simple
        on update no action on delete no action,
     constraint est_membre_est_membre_utilisateur_id_fkey foreign key (est_membre_utilisateur_id)
        references utilisateur (utilisateur_id) match simple
        on update no action on delete no action
);


create table conference (
    conference_id varchar(60) primary key,
    conference_nom varchar(60) not null,
    conference_site_web varchar(1000),
    conference_description varchar(1000)
    );


create table edition_conf ( 
    edition_conf_id varchar(60) primary key,
    edition_conf_nom varchar(60),
    edition_conf_description varchar(1000),
    edition_conf_conference_id varchar(60) not null,
    constraint edition_conf_edition_conf_conference_id_fkey foreign key (edition_conf_conference_id)
		references conference (conference_id) match simple
        on update no action on delete no action,
    edition_conf_ville varchar(60),
    edition_conf_date_debut date,
    edition_conf_date_fin date,
    edition_conf_date_limite_soumission date,
    edition_conf_consignes varchar(10000),
    edition_conf_langue varchar(60),
    edition_conf_pays varchar(60),
    edition_conf_site varchar(1000)
    );


create table journal (
    journal_id varchar(60) primary key,
    journal_nom varchar(60) not null,
    journal_description varchar(500),
    journal_theme varchar(60),
    journal_site_web varchar(1000),
    journal_consignes varchar(10000)
      ) ;


create table hors_serie (
    hors_serie_id varchar(60) primary key,
    hors_serie_journal_id varchar(60) not null,
    hors_serie_consignes varchar(10000),
	constraint hors_serie_hors_serie_journal_id_fkey foreign key (hors_serie_journal_id)
		references journal (journal_id) match simple
	    on update no action on delete no action,
    hors_serie_date_limite_soumission date
    );





create table statut (
    statut_id varchar(60) primary key,
    statut_nom varchar(60) not null,
    statut_commentaire varchar(500)
      );


create table article (
    article_id varchar (60) primary key,
    article_journal_id varchar(60),
    article_hors_serie_id varchar(60),
    article_statut_id varchar(60) not null,
    article_edition_conf_id varchar(60),
    article_lien varchar(2000),
    article_mot_cle varchar(60),
    article_resume varchar(1000),
    article_date_archivage date,
    article_date_limite_soumission date,
	constraint article_article_journal_id_fkey foreign key (article_journal_id)
		references journal (journal_id) match simple
	    on update no action on delete no action,
	constraint article_article_hors_serie_id_fkey foreign key (article_hors_serie_id)
		references hors_serie (hors_serie_id) match simple
	    on update no action on delete no action,
	constraint article_article_statut_id_fkey foreign key (article_statut_id)
		references statut (statut_id) match simple
	    on update no action on delete no action,
	constraint article_article_edition_conf_id_fkey foreign key (article_edition_conf_id)
		references edition_conf (edition_conf_id) match simple
	    on update no action on delete no action
	);


create table fichier (
    fichier_id varchar(60) primary key,
    fichier_nom varchar(60) not null,
    fichier_contenu bytea not null,
    fichier_commentaire varchar(60),
    fichier_article_id varchar(60),
    constraint fichier_fichier_article_id_fkey foreign key (fichier_article_id)
        references article (article_id) match simple
        on update no action on delete no action
      );


create table participation (
	participation_utilisateur_id varchar(60) not null,
	participation_article_id varchar (60) not null,
	participation_ordre integer not null,
	participation_fonction varchar(60) not null,
	primary key (participation_utilisateur_id, participation_article_id),
	constraint participation_participation_utilisateur_id_fkey foreign key (participation_utilisateur_id)
		references utilisateur (utilisateur_id)  match simple
	    on update no action on delete no action,
	constraint participation_participation_article_id_fkey foreign key (participation_article_id)
	    references article (article_id) match simple
	    on update no action on delete no action
	);

