drop table if exists utilisateur cascade ;
drop table if exists groupe cascade;
drop table if exists est_membre cascade;
drop table if exists conference cascade;
drop table if exists edition_conf cascade;
drop table if exists journal cascade;
drop table if exists version cascade;
drop table if exists statut cascade;
drop table if exists hors_serie cascade;
drop table if exists article cascade;
drop table if exists ordre cascade;


create table utilisateur (
    utilisateur_id serial primary key,
    utilisateur_auht text not null,
    utilisateur_nom varchar(60) not null,
    utilisateur_prenom varchar(60) not null
      ) ;


create table groupe (
    groupe_id serial primary key,
    groupe_nom varchar(60) not null,
    groupe_description varchar(150)
      ) ;



create table est_membre (
    est_membre_groupe_id int(60) not null,
    est_membre_utilisateur_id int(60) not null,
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
    conference_site_web varchar(60),
    conference_description varchar(1000)
    );


create table edition_conf ( 
    edition_conf_id varchar(60) primary key,
    edition_conf_description varchar(1000),
    edition_conf_conference_id varchar(60) not null,
    constraint edition_conf_edition_conf_conference_id_fkey foreign key (edition_conf_conference_id)
references conference (conference_id) match simple
           on update no action on delete no action,
    edition_lieu varchar(60),
    edition_date date,
    edition_date_limite_soumission date,
    edition_consignes varchar(10000)
    );


create table journal (
    journal_id varchar(60) primary key,
    journal_nom varchar(60) not null,
    journal_description varchar(500),
    journal_theme varchar(60),
    journal_site_web varchar(60),
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


create table version (
    version_id varchar(60) primary key,
    version_nom varchar(60) not null
      );


create table statut (
    statut_id varchar(60) primary key,
    statut_nom varchar(60) not null
      );


create table article (
    article_id serial primary key,
    article_journal_id varchar(60),
    article_hors_serie_id varchar(60),
    article_statut_id varchar(60) not null,
    article_edition_conf_id varchar(60),
    article_version_id varchar(60) not null, 
    article_lien varchar(2000),
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
           on update no action on delete no action,
    constraint article_article_version_id_fkey foreign key (article_version_id)
references version (version_id) match simple
           on update no action on delete no action
);


create table ordre (
ordre_utilisateur_id int(60) not null,
ordre_article_id int(60) not null,
ordre_ordre integer not null,
primary key (ordre_utilisateur_id, ordre_article_id),
constraint ordre_ordre_utilisateur_id_fkey foreign key (ordre_utilisateur_id)
references utilisateur (utilisateur_id)  match simple
           on update no action on delete no action,
     constraint ordre_ordre_article_id_fkey foreign key (ordre_article_id)
              references article (article_id) match simple
              on update no action on delete no action
);

