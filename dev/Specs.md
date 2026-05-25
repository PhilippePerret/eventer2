# Eventer2

## Philosophie

- outil local
- aucune complexité inutile
- interface silencieuse
- priorité absolue à la fluidité
- zéro sensation “base de données”

---

## Spécifications

* Application ruby Sinatra (cf. app.rb)
* l’enregistrement est automatique, transparent



---

## Architecture

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

# Données

## Project

> C’est un eventer comme les autres, avec certaines propriétés propres.

## Eventer

~~~json
title				: "Le titre de l'éventer ou du projet"
id					: "ev12"  // fixé par l'app
events			: [liste des events]
options 		:
	colorizeEventsWithFirstBrin: true
persos			: [liste des ids de personnages de l’eventer]
brins				: [liste des ids de brins de l’eventer]
project 		: "id-du-projet"
active  		: true 		// seulement pour les projects
created_at	: date de création
updated_at	: date de dernière modification
~~~



## Event

```json
id     		: "ev12"
text   		: "La description de l'évènement"
brins  		: ["b12", "b569"]
persos 		: ["p2", "p78"]
type			: ["dia", "act"]
nature		: ["con5", "amo2"]
duration	: 20 								// (secondes)
file			: "/Users/.../chap-03.md"
state			: 1
child			: true
```

> La propriété `child` est `true` lorsque l’event possède son propre eventer (donc ses sous-évènements) et qu’il y a au moins un évènement.
>
> Cet eventer est alors enregistré dans 

### States (event)

*(à comprendre en plaçant « en cours de… » avant chaque terme)*

~~~ json
0 : "---"
1 : "ébauche"
2 : "développement"
3 : "premier jet"
4 : "réécriture"
5 : "achèvement"
6 : "à corriger"
7 : "correction"
8 : "à relire"
9 : "achevé"
~~~

### Types (event)

~~~json
dia : "Dialogue"
act : "Action"
des : "Description"
~~~

### Natures (event)

~~~json
con1 : "Un peu tendu"
con2 : "Conflictuel"
con3 : "Fortement conflictuel"
amo1 : "Affectueux"
amo2 : "chaud"
amo3 : "Toride/passioné"

(à poursuivre)
~~~

## Brin

| Propriété | description                                                  |      |
| --------- | ------------------------------------------------------------ | ---- |
| `id`      | Identifiant unique et universel                              |      |
| `nom`     | La description du brin en une ligne courte. Dans la liste des évènements, elle apparait lorsque l’on survole le badge du brin. C’est le nom qui apparait dans le panneau des brins. |      |
| `badge`   | Trois lettres majuscules UNIQUES propre                      |      |
| `color`   | Sa couleur hexadécimale                                      |      |
| `type`    | Le type de brin (valeurs : intrigue principale, intrigue amoureuse, intrigue, personnage, relation, thème, accessoire, autre). |      |
| `persos`  | Liste des personnages du brin (identifiants).                |      |
| `file`    | Chemin du fichier associé au brin.                           |      |

### Types (de brins)

~~~json
mint	: Intrigue principale

~~~



## Perso

| Propriété   | DESCRIPTION                             | VALEURS             |
| ----------- | --------------------------------------- | ------------------- |
| `id`        | Identifiant unique universel            |                     |
| `badge`     | Deux lettre capitales uniques           | **SK**              |
| `avatar`    | Avatar (émoji, par exemple)             | 🤡                   |
| `pseudo`    | Nom usuel dans l’histoire               | **Stan**            |
| `patronyme` | Prénom Nom                              | ****                |
| `fonctions` | Fonctions dans le récit (liste)         | Mentor, Antagoniste |
| `file`      | Chemin au fichier associé au personnage |                     |

### Fonctions (personnage)

~~~json
(valeurs preset + custom)
prot		: Protagoniste
anta		: Antagoniste
adju		: Adjuvant/allié
ment		: Mentor
spre		: Sprechhund
(à poursuivre)
~~~



---

# Interface

## Structure

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



## Types

### `Event`

| Propriété  | Description                                                  | Valeur |
| ---------- | ------------------------------------------------------------ | ------ |
| `id`       | Identifiant unique et universel                              |        |
| `text`     | Intitulé de l’évènement (affiché dans le panneau)            |        |
| `brins`    | Liste des identifiants des brins                             |        |
| `type`     | Type de l’évènement (dialogue, action, action et dialogue, autre) |        |
| `natures`  | La natures de l’évènement (conflictuel, descriptif, contemplatif, réflexif, démonstratif, etc.) |        |
| `duration` | Durée en secondes de l’évènement.                            |        |
| `file`     | Chemin au fichier associé à l’évènement (s’il existe). Pour le moment, ne peut être défini que manuellement dans le fichier JSON. |        |



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

# Priorités réelles

1. fluidité d’édition
2. déplacement immédiat
3. filtrage agréable
4. lisibilité
5. stabilité

Pas :

- sophistication technique
- architecture
- “scalabilité”
- plugins
- cloud
- collaboration

---

## Développements ultérieurs

* pouvoir ouvrir le fichier associé à l’évènement, au brin, au personnage
* pouvoir définir en le choisissant le fichier associé à l’évènement, au brin, au personnage
* export dans différents formats
