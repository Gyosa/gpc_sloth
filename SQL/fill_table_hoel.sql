insert into utilisateur ( utilisateur_auth, utilisateur_nom,utilisateur_prenom) 
	values
	('chamon', 'Hamon','Célestin'),
	('mschalle', 'Schaller','Mathieu'),
	('hmarjoux', 'Marjoux','Hoël'),
	('clescure', 'Lescure','Camille'),
	('epourrat', 'Pourrat','Eliott'); 

insert into groupe (groupe_nom,groupe_description) 
	values 
	('Les ninjas','Goupe d étudiants agiles, si rapides et si malicieux !'),
	('Les utilisateurs de Mac','Étudiants utilisant des Macbook'),
	('Les frisées','Confrerie des amoureux de la bouclette');

insert into est_membre (est_membre_groupe_id, est_membre_utilisateur_id)
	values 
	('1','1'),
	('1','2'),
	('1','3'),
	('1','4'),
	('1','5'),
	('2','2'),
	('2','5'),
	('3','1'),
	('3','5');


insert into conference (conference_nom, conference_site_web)
	values 
	('Iscram', 'http://iscram.com');

insert into conference (conference_nom,conference_description)
	values 
	('International Conference on Very Large Data Bases','The VLDB Conferences constitute one of the most eminent venues for the timely dissemination of research and development results in the field of database management.');

insert into edition_conf (edition_conf_nom, edition_conf_description, edition_conf_conference_id,edition_conf_ville,edition_conf_pays)
	values
	('Iscram édition 2019','Édition 2019 de l&rsquo;Information Systems for Crisis Response and Management','1','Albi','France');

insert into edition_conf (edition_conf_nom, edition_conf_description, edition_conf_conference_id, edition_conf_ville,
	edition_conf_pays, edition_conf_date_debut, edition_conf_date_fin, edition_conf_site, edition_conf_langue, edition_conf_date_limite_soumission)
	values
	('45th International Conference on Very Large Data Bases','The annual VLDB conference is a premier annual international forum for database researchers, vendors, practitioners, application developers, and users. PVLDB, established in 2008, is a scholarly journal for short and timely research papers, with a journal-style review and quality assurance process. PVLDB is distinguished by a monthly submission process with rapid reviews. Its issues are published regularly throughout the year. Your paper will appear in PVLDB soon after acceptance, and possibly in advance of the VLDB conference. All papers accepted in time will be published in PVLDB Vol. 12 and also presented at the VLDB 2019 conference.'
	, '2', 'Los Angeles', 'États-Unis', '2019-08-26', '2019-08-30', 'http://vldb.org/2019', 'Anglais', '2019-05-07'),
	('44th International Conference on Very Large Data Bases','The annual VLDB conference is a premier annual international forum for database researchers, vendors, practitioners, application developers, and users. PVLDB, established in 2008, is a scholarly journal for short and timely research papers, with a journal-style review and quality assurance process. PVLDB is distinguished by a monthly submission process with rapid reviews. Its issues are published regularly throughout the year. Your paper will appear in PVLDB soon after acceptance, and possibly in advance of the VLDB conference. All papers accepted in time will be published in PVLDB Vol. 11 and also presented at the VLDB 2019 conference.'
	, '2', 'Rio de Janeiro', 'Brazil', '2018-08-27', '2018-08-31', 'http://vldb2018.lncc.br/', 'Anglais', '2018-05-09');

insert into statut (statut_nom, statut_description)
	values
	('accepte','Papier accepté mais non publié'),
	('online','Papier publié online'),
	('publie','Papier publié papier'),
	('refuse','Refusé, à re-travailler'),
	('attente','Attente review suite à soumission'),
	('redaction','Rédaction en cours avant soumission');


insert into revue (revue_nom,revue_description,revue_theme,revue_site_web,revue_consignes) 
	values 
	('Enterprise information system',
	'Enterprise Information Systems (EIS) is devoted to original research and novel applications in improving the functions of an enterprise business and engineering management processes,and the theoretical and managerial implications of the system integrations and implementations.',
	'Industrial Engineering',
	'https://www.tandfonline.com/toc/teis20/current',
	'https://www.tandf.co.uk/journals/authors/teisauth.asp'),
	('Decision Support Systems',
	'The common thread of articles published in Decision Support Systems is their relevance to theoretical and technical issues in the support of enhanced decision making. The areas addressed may include foundations, functionality, interfaces, implementation, impacts, and evaluation of decision support systems.',
	'Industrial Engineering',
	'https://www.journals.elsevier.com/decision-support-systems/',
	'https://www.elsevier.com/journals/decision-support-systems/0167-9236?generatepdf=true'),
	('Journal of Intelligent Manufacturing',
	'Published in eight issues per year, the Journal of Intelligent Manufacturing provides a unique international forum for developers of intelligent manufacturing systems. By publishing quality refereed papers on the application of artificial intelligence in manufacturing, the Journal provides a vital link between the research community and practitioners in industry.',
	'Manufacturing',
	'https://www.springer.com/business+%26+management/operations+research/journal/10845',
	'https://www.springer.com/business+%26+management/operations+research/journal/10845');

insert into hors_serie (hors_serie_revue_id, hors_serie_consignes, hors_serie_date_limite_soumission)
	values
	('1',
	 'Que des articles sur l&rsquo;intelligence artificielle',
	 '2019-09-09');

insert into article (article_revue_id, article_statut_id, article_mot_cle, article_resume)
	values 
	('1',
	 '6',
	 'article de test',
	 'Cet article de test est en cours de rédaction pour le journal "Enterprise information system"'
	),
	('1',
	 '5',
	 'article de test',
	 'Cet article de test est en attente de review en vue d une publication pour le journal "Enterprise information system"'
	),
	('2',
	 '6',
	 'article de test',
	 'Cet article de test est en cours de rédaction pour le journal "Decision Support Systems"'
	),
	('2',
	 '4',
	 'article de test',
	 'Cet article de test à été refusé par le journal "Decision Support Systems" il doit être re-travailler avant d être soumission à nouveau'
	),
	('3',
	 '6',
	 'article de test',
	 'Cet article de test est en cours de rédaction pour le journal "Journal of Intelligent Manufacturing"'
	);

insert into article (article_revue_id, article_hors_serie_id, article_statut_id, article_mot_cle, article_resume, article_date_limite_soumission)
	values 
	('1',
	 '1',
	 '6',
	 'article de test',
	 'Cet article de test est en cours de rédaction pour l hors série "Que des articles sur l intelligence artificielle" du journal "Enterprise information system"',
	 '2019-09-09'
	);
	
insert into article (article_revue_id, article_statut_id, article_mot_cle, article_resume, article_date_archivage)
	values
	('1',
	 '3',
	 'article de test',
	 'Cet article est archivé et à été publié dans le journal "Enterprise information system"',
	 '2018-12-25'
	),
	('3',
	 '3',
	 'article de test',
	 'Cet article est archivé et à été publié dans le journal "Journal of Intelligent Manufacturing"',
	 '2019-01-05'
	),
	('3',
	 '4',
	 'article de test',
	 'Cet article est archivé et à été refusé dans le journal "Journal of Intelligent Manufacturing"',
	 '2018-11-14'
	),
	('2',
	 '4',
	 'article de test',
	 'Cet article est archivé et à été refusé dans le journal "Decision Support Systems"',
	 '2018-11-14'
	),
	('2',
	 '2',
	 'article de test',
	 'Cet article est archivé et à été publié dans la version en ligne du journal "Decision Support Systems"',
	 '2019-02-02'
	);
--pb--
insert into article (article_edition_conf_id, article_statut_id, article_mot_cle, article_resume, article_date_limite_soumission)
	values
	('2',
	 '6',
	 'article de test',
	 'Cet article est en cours de redaction pour l édition de conference "45th International Conference on Very Large Data Bases"',
	 '2019-05-07'
	),
	('2',
	 '6',
	 'article de test',
	 'Cet article est en cours de redaction pour l édition de conference "45th International Conference on Very Large Data Bases"',
	 '2020-06-16'
	);
--pb--
insert into article (article_edition_conf_id, article_statut_id, article_mot_cle, article_resume)
	values	
	('1',
	 '6',
	 'article de test',
	 'Cet article est en cours de redaction pour l édition de conference "Iscram édition 2019"'
	),
	('1',
	 '6',
	 'article de test',
	 'Cet article est en cours de redaction pour l édition de conference "Iscram édition 2019"'
	);

insert into article (article_edition_conf_id, article_statut_id, article_mot_cle, article_resume, article_date_archivage)
	values
	('3',
	 '3',
	 'article de test',
	 'Cet article a été présenté lors de l édition de conference "44th International Conference on Very Large Data Bases"',
	 '2018-05-30'
	),
	('3',
	 '4',
	 'article de test',
	 'Cet article a été refusé pour l édition de conference "44th International Conference on Very Large Data Bases"',
	 '2018-04-30'
	);

insert into participation ()
	values ();
	
insert into fichier ()
	values ();

