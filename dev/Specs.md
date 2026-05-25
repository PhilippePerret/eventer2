# Eventer2

## Description

Application qui permet de gérer les évènemenciers de projets de film ou de roman. 

Un *évènemencier* (`Eventer` dans l’application) est simplement une suite d’évènements (`Event` dans l’application) au sens anglo-saxon du terme, c’est-à-dire au sens de « quelque chose qui se passe » d’importance quelconque. Une action (remplir un verre d’eau) est un évènement, un dialogue est un évènement, un morceau de ce dialogue est un évènement.

Un évènement a une échelle déterminé. Par exemple, l’échelle d’un évènemencier de premier niveau est l’acte. Donc **chaque acte est un évènement** (de longue durée).

Un évènement quelconque possède son propre évènemencier, de niveau inférieur (ou d’échelle inférieure). Dans une histoire traitée de façon traditionnelle, on peut avoir : 

~~~
Projet (eventer supérieur)
	Il contient des évènements d'échelle "acte"
	event : Exposition
	event : Développement
	event : Dénouement

Chacun de ces évènements contient son propre événemencier
d'échelle "séquence" :

Exposition
	event : Séquence 1
	event : Séquence 2
	...
	event	: Séquence N

Chacun de ces évènements "séquence" contient son propre
évènemencier d'échelle "scène" :

Séquence 3
	event : Scène 1
	event : Scène 2
	...
	event	: Scène N
	
Etc. On trouve donc traditionnellement la hiérarchie :

Project
	Acte
		Séquence
			Scène
				Beat de scène
					Action/Dialogue
						Paragraphe final
~~~

**Eventer** gère en douceur et de façon très pratique, entièrement au clavier, ces évènemenciers, pour un développement confortable et agile de la structure, en permettant notamment de se focaliser sur des intrigues particulières, ou des décors, ou des personnages, etc.

---

## Philosophie

- outil local
- aucune complexité inutile
- interface silencieuse
- priorité absolue à la fluidité
- zéro sensation “base de données”
- développement en TDD

---

## Spécifications

* Application ruby Sinatra (cf. app.rb)
* l’enregistrement est automatique, transparent
* tout clavier, presque rien à la souris
* sauvegarde en JSON
* identifiants les plus courts possible



---

## Architecture

**ATTENTION, CETTE ARCHITECTURE N’EST PAS À PRENDRE AU PIED DE LA LETTRE, ELLE EST PUREMENT INDICATIVE ET NE TIENT PAS COMPTE DES DERNIÈRES AVANCÉES.**

```text
Eventer2/
│
├── app.rb
│
├── data/
│   ├── __state__.json
│   ├── id-projet1.json
│   ├── id-projet1/
│   ├── id-projet2.json
│   ├── id-projet2/
│   ├── etc.
│
├── public/
│   ├── app.js
│   ├── config.js
│		├── classes/
│		│		├── App.js
│		│		├── controllers/
│		│		│		├── ListController.js (classe abstraite)
│		│		│		├── EventsController.js
│		│		│		├── ProjectsController.js
│		│		├── views/
│		│		│		├── ListView.js (classe abstraite)
│		│		│		├── EventListView.js
│		│		│		├── ProjectListView.js
│		│		├── repositories/ (???)
│		│		│		├── EventerRepository.js (???)
│		│		│		├── ProjectRepository.js (???)
│		│		├── models/
│		│		│		├── Item.js   (classe abstraite)
│		│		│		├── Project.js
│		│		│		├── Event.js
│		│		│		├── Brin.js
│		│		│		├── Perso.js
│		│		│		├── ItemCollection.js (classe abstraite)
│		│		│		├── ProjectCollection.js
│		│		│		├── EventCollection.js
│		│		│		├── BrinCollection.js
│		│		│		├── PersoCollection.js
│		│		├── EditableText.js  (???)
│		│		├── Texte.js  (gestion des textes)
│		│
│   ├── index.html
│   └── style.css
└── exports/
```



> Il y avait un Database.js dans la version 1 (qui fonctionnait aussi sans base de données)



---

# Backend

## app.rb

Cf. l’état actuel.


---

# Frontend

Ruby + Sinatra.

Responsabilités :

- servir l’interface
- charger/sauvegarder les évènements/projets
- exporter
- ouvrir des fichiers externes (chaque évènement/projet peut avoir son fichier)

Aucune logique métier compliquée.

---

## Modèles

Voir le fichier.

---

## Interface

### Structure

- colonne centrale unique
- une ligne = un évènement/un projet
  - à gauche : son intitulé 
  - à droite : badges des brins, badges des personnages, état

- édition directe
- déplacement immédiat
- filtres escamotables

---

### Panneaux (panel.js)

Le panneau des évènements est toujours affiché. Les panneaux des brins et des personnages s’affichent au besoin.

Les panneaux des évènements (Event, EventsPanel.js), des brins (Brin, BrinsPanel.js) et des personnages (Perso, PersosPanel.js) fonctionnent tous de la même façon (Panel.js)

* la touche « n » permet de **créer un nouvel élément** du type du panneau actif (Event, Brin ou Perso), sous l’élément sélectionné,
* les touches flèche haut/bas permettent de **passer en revue les éléments**,
* les touches ⌘ + flèche haut/bas, permettent de **déplacer les éléments**,
* la touche Delete (PAS backspace) permet de **détruire l’élément** sélectionné (sans demande, sans avertissement),
  * comportement particulier pour les brins : le retirer des évènements.
  * comportement particulier pour les personnages : le retirer des brins + des évènements.
* la touche Space (Espace) permet de sélectionner l’élément courant (une coche verte se place à côté, il n’y a RIEN lorsque l’élément n’est pas sélectionné)
* la touche « Entrée » permet d’**éditer l’élément** courant (évidemment, les autres raccourcis clavier ne doivent plus fonctionner),
  * quand on est en édition, la touche « Entrée » permet de sortir de l’édition + enregistrer les changements s’il y en a.

---

# Ligne évènement

Contient :

- texte (`Event.text`)
- badges de brins (`Brin.badge`)
- avatar ou lettres de personnages (`Perso.avatar` ou `Perso.badge`)
- durée si définie (`Event.duration`)

---

# Interactions

## Clavier

| Action | Raccourci |
|---|---|
| Nouveau Project/Event/Brin/Perso (suivant panneau) | n |
| Choisir l’élément (suivant panneau) en courant | ↑↓ |
| Déplacer l’élément (suivant panneau) | ⌘ ↑↓ |
| Filtrer (par le panneau des brins + divers) | / |
| Gérer les brins (afficher panneau) | b |
| Gérer les personnages (afficher panneau) | p |
| Mise en édition de l‘élément (Project/Event/Brin/Perso) | ↩︎ |
| Déplacement de propriété en propriété | ⇥ |
| Fin de l’édition de l’élément (enregistrement) | ↩︎ |
| Fermeture du panneau (Brins/Persos) | ⌘ ↩︎ |
| Annulation | ␛ |

---

## Filtres

Le filtre principal est le **filtrage de la liste des évènements par brin**. 

> Il y aura à l’avenir d’autres façons de filtrer, par personnages, par texte, par nature ou type, etc. Mais pour le moment, on se limite aux brins, l’utilisation la plus classique.

Donc, quand on joue la touche « / », ça ouvre le panneau des brins (ça les décoche tous, donc ça fait disparaitre tous les évènements dessous) et on se déplace + Space pour choisir les brins. Au fur et à mesure, les évènements réapparaissent.

---

# Style visuel

## Principes

- très peu de chrome
- peu de couleurs
- typographie dominante
- densité faible
- animations discrètes
- fond neutre
- pas d’effets “application moderne”

---

# Technique front

- HTML
- CSS
- JavaScript vanilla

Le DOM suffit largement.

---

# Sauvegarde

- sauvegarde automatique discrète
- un seul fichier JSON
- export possible

---

## Développements ultérieurs

* pouvoir ouvrir le fichier associé à l’évènement, au brin, au personnage
* pouvoir définir en le choisissant le fichier associé à l’évènement, au brin, au personnage
* export dans différents formats
