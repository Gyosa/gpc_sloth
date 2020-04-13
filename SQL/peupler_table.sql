--- Ce fichier est en -*- mode: sql; coding: utf-8; -*-
---
--- Script de peuplement des tables dans la base gpcsloth - version psotgresql 2016
---
--- Pour exécuter ce script (suppose que la base et les tables sont déjà
--- créées) :
---
---   psql -h sgbd-eleves.mines-albi.fr -U slothadmin gpcsloth < SQL/peupler_table.sql
---
---   (il faut connaitre le mot de passe de slothadmin)
--peupler table--
insert into utilisateur (utilisateur_auth, utilisateur_nom, utilisateur_prenom)
       values('epourrat', 'Pourrat', 'Eliott');
insert into utilisateur (utilisateur_auth, utilisateur_nom, utilisateur_prenom)
       values('chamon', 'Hamon', 'Célestin');
insert into utilisateur (utilisateur_auth, utilisateur_nom, utilisateur_prenom)
       values('clescure', 'Lescure', 'Camille');
insert into utilisateur (utilisateur_auth, utilisateur_nom, utilisateur_prenom)
       values('mschalle', 'Schaller', 'Mathieu');
insert into utilisateur (utilisateur_auth, utilisateur_nom, utilisateur_prenom)
       values('hmarjoux', 'Marjoux', 'Hoël');

select * from utilisateur;
       
