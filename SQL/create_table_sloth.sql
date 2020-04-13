drop table if exists utilisateur cascade ;
drop table if exists groupe cascade;
drop table if exists est_membre cascade;
drop table if exists conference cascade;
drop table if exists edition_conf cascade;
drop table if exists revue cascade;
drop table if exists fichier cascade;
drop table if exists statut cascade;
drop table if exists hors_serie cascade;
drop table if exists article cascade;
drop table if exists version cascade;
drop table if exists participation cascade; 


create table utilisateur (
    utilisateur_id serial primary key,
    utilisateur_auth varchar(60) unique,
    utilisateur_nom varchar(60) not null,
    utilisateur_prenom varchar(60) not null
      ) ;


create table groupe (
    groupe_id serial primary key,
    groupe_nom varchar(60) unique,
    groupe_description varchar(150)
      ) ;



create table est_membre (
	est_membre_groupe_id int not null,
	est_membre_utilisateur_id int not null,
	primary key (est_membre_groupe_id, est_membre_utilisateur_id),
	constraint est_membre_est_membre_groupe_id_fkey foreign key (est_membre_groupe_id)
		references groupe (groupe_id) match simple
        on update no action on delete no action,
     constraint est_membre_est_membre_utilisateur_id_fkey foreign key (est_membre_utilisateur_id)
        references utilisateur (utilisateur_id) match simple
        on update no action on delete no action
);


create table conference (
    conference_id serial primary key,
    conference_nom varchar(60) unique,
    conference_site_web varchar(1000),
    conference_description varchar(1000)
    );


create table edition_conf ( 
    edition_conf_id  serial primary key,
    edition_conf_nom varchar(60) unique,
    edition_conf_description varchar(1000),
    edition_conf_conference_id int not null,
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


create table revue (
    revue_id serial primary key,
    revue_nom varchar(60) unique,
    revue_description varchar(500),
    revue_theme varchar(60),
    revue_site_web varchar(1000),
    revue_consignes varchar(10000)
      ) ;


create table hors_serie (
    hors_serie_id serial primary key,
    hors_serie_nom varchar(60) unique,
    hors_serie_revue_id int not null,
    hors_serie_date_publication date,
    hors_serie_consignes varchar(10000),
	constraint hors_serie_hors_serie_revue_id_fkey foreign key (hors_serie_revue_id)
		references revue (revue_id) match simple
	    on update no action on delete no action,
    hors_serie_date_limite_soumission date
    );



create table statut (
    statut_id serial primary key,
    statut_nom varchar(60) unique,
    statut_description varchar(500)
      );


create table article (
    article_id serial primary key,
    article_nom varchar (60), 
    article_revue_id int,
    article_hors_serie_id int,
    article_statut_id int not null,
    article_edition_conf_id int,
    article_lien varchar(2000),
    article_mot_cle varchar(60),
    article_resume varchar(2000),
    article_date_limite_soumission date,
    article_date_archivage date
    );

create table fichier (
    fichier_id serial primary key,
    fichier_nom varchar(1024) not null,
    fichier_type varchar(1024) not null,
    fichier_contenu bytea not null,
    fichier_commentaire varchar(1024),
    fichier_date date not null,
    fichier_article_id int not null,
    unique (fichier_nom, fichier_article_id),
    constraint fichier_fichier_article_id_fkey foreign key (fichier_article_id)
        references article (article_id) match simple
        on update no action on delete no action
      );

--create unique index fichier_nom_article_id on fichier (fichier_nom, fichier_article_id);--


create table version (
       version_id serial primary key,
       version_nom varchar(1024) not null,
       version_type varchar(1024) not null,
       version_contenu bytea not null,
       version_nb integer,
       version_commentaire varchar(1024),
       version_date date not null,
       version_fichier_id integer not null,
       constraint version_version_fichier_id_fkey foreign key (version_fichier_id)
       		  references fichier (fichier_id) match simple
		  on update no action on delete no action
		 );


create table participation (
	participation_utilisateur_id int not null,
	participation_article_id int not null,
	participation_ordre integer not null,
	participation_fonction varchar(60),
	primary key (participation_utilisateur_id, participation_article_id),
	constraint participation_participation_utilisateur_id_fkey foreign key (participation_utilisateur_id)
		references utilisateur (utilisateur_id)  match simple
	    on update no action on delete no action,
	constraint participation_participation_article_id_fkey foreign key (participation_article_id)
	    references article (article_id) match simple
	    on update no action on delete no action
	);

