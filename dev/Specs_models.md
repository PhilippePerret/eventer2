# Eventer2 — Modèles



## Eventer

~~~json
id					: "ev12"  // fixé par l'app
											// sert à nommer le dossier qui
											// contiendra ses sous-eventers
scale				: eventer
events			: [liste des ids d’events]
options 		:
	colorizeEventsWithFirstBrin: true
persos			: [liste des ids de personnages de l’eventer]
brins				: [liste des ids de brins de l’eventer]
project_id	: "id-du-projet" // null pour project
active  		: true 		// seulement pour les projects
created_at	: date de création
updated_at	: date de dernière modification
lasts_id		: {event: x, brin: y, perso: z}
// ---- Seulement pour les projets ----
title				: "Le titre du projet"
nature			: "roman" ou "film"

~~~

### scales (eventer)

Un *Eventer* peut être de trois scales (échelles) assez distincts.

> À l’avenir, on pourrait imaginer avec plus de valeurs, comme « séquencier », « scénier », « scene beat », etc.

| Type          | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| **`project`** | C’est en quelque sorte l’eventer de premier niveau d’un projet. Il définit souvent les actes des l’histoire. |
| **`eventer`** | C’est l’évènemencier (liste d’évènements, d’events) normal.  |
| **`text`**    | C’est un évènemencier comme un autre dans son fonctionnement général, mais il est traité comme le texte final de l’histoire, c’est-à-dire comme un scénario si c’est un film (mis en forme en scénario) soit comme un texte de manuscrit pour un roman.<br />**Question** : faut-il mettre une option pour déterminer que, par défaut, l’eventer de niveau le plus profond doit être toujours considéré comme l’eventer de type `text` (qui servira donc à l’export pour produire le manuscrit ou le scénario final) ? |

---

## Event

> Les évènements (event) sont conservés dans le fichier `__events__.json` dans le dossier du projet ou de l’évènemencier.
>
> Note : un projet est aussi un Event.

```json
id     		: "ev12"
title 		: "La description de l'évènement"
brins  		: ["b12", "b569"]
persos 		: ["p2", "p78"]
type			: ["dia", "act"]
nature		: ["con5", "amo2"]
duration	: 20 								// (secondes)
file			: "/Users/.../chap-03.md"
state			: 1
child			: true
```

> La propriété `child` est `true` lorsque l’event possède son propre eventer (donc ses sous-évènements) et qu’il y a au moins un évènement. Attention à cette gestion : quand on est sur un event, si on fait la flèche droite, on crée automatiquement l’eventer de l’event. Mais si on ne crée pas d’events dedans (qu’on revient tout de suite) il ne faut pas que cette propriété soit mise à true. En conclusion : cette propriété doit être à true SEULEMENT lorsque l’event possède un eventer qui contient au moins un event.
>
> Cet eventer est alors enregistré dans un fichier JSON portant le nom de l’identifiant de l’event.

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

---

## Brin

> Les brins sont consignés dans le fichier `__brins__.json` du dossier du projet. Tous les brins y sont consignées (contrairement aux évènements qui se trouvent ici mais aussi dans des dossiers de dossier de dossier d’évènement.

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

---

## Perso

> Les personnages sont tous tous consignés dans le fichier `__persos__.json` dans le dossier du projet. Comme les brins.

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

## Identifiants

Pour réduire la taille des fichiers, faire les identifiants les plus courts possible (rappel : ceux des projets sont définis par l’user). C’est-à-dire qu’on prend la première lettre du type et on l’incrémente.  Par exemple « b » + x pour les brins, « p » + x pour les personnages, « e » + x pour les évènements, mais « ev » + x pour les évènemenciers.

=> Il faut persister les derniers identifiants de chaque type d’objet (dans la donnée du projet)

---
