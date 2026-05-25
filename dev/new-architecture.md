# Eventer2

Je partirais maintenant sur quelque chose de beaucoup plus strict.

## Plus strict

### app.js minimal

Uniquement :

* boot ;
* chargement initial ;
* instanciation ;
* wiring global.

Pas :

* logique métier ;
* logique clavier ;
* logique d’édition ;
* logique de rendu.

Exemple :

const app = new App()
app.start()

### Un vrai objet App

Responsable seulement :

* panels actifs ;
* navigation entre panels ;
* chargement des données ;
* persistence.

Genre :

~~~

class App {
  openProjects()
  openEventer(project)
  openBrin(brin)
}

~~~

### KeyboardManager séparé

Au lieu de :

* document.addEventListener partout.

Un vrai dispatcher :

keyboard.route(event)

Qui envoie :

* au panel actif ;
* ou au champ édité.

Et RIEN d’autre.

### Édition locale

Le plus gros changement.

Aujourd’hui :

* l’édition est globale ;
* avec UI.mode.

EditableText

responsable de :

* Enter ;
* Escape ;
* Tab ;
* validation ;
* annulation.

Donc :

* plus de routing spécial ;
* plus de panelEditing.

### Panel = navigation seulement

Panel ne connaît :

* ni fetch ;
* ni API ;
* ni persistence ;
* ni Finder ;
* ni structure métier.

Seulement :

* sélection ;
* navigation ;
* reorder ;
* édition locale.

6. Les panels spécialisés pilotent le métier

Exemple :

ProjectsPanel

connait :

* création projet ;
* suppression projet ;
* ouverture projet.

Mais PAS :

* rendu générique ;
* clavier global ;
* édition bas niveau.

### Un vrai modèle métier

Actuellement :

* les objets sont semi-bruts.

Je créerais :

Project
Event
Brin
Personnage

avec :

* méthodes ;
* invariants ;
* serialization.

### Persistence isolée

Aujourd’hui :

* les fetch sont partout.

Je ferais :

ProjectRepository
EventRepository

Donc :

* zéro fetch dans les panels.

### Rendering séparé du comportement

Très important.

Actuellement :

* comportement + DOM mélangés.

Je séparerais :

* état ;
* rendu ;
* interactions.

### Plus jamais de flags globaux UI

Le vrai poison actuel :

UI.mode

Je supprimerais totalement ça.

Chaque composant doit connaître :

* SON état ;
* pas l’état global de l’application entière.



## AJOUT À CETTE RÉFLEXION : 

MOI : oui, oui, encore du baratin. Et en plus, tu oublies qu'il y a aussi les persos, et tu oublies aussi que toutes les collections fonctionnement de la même manière : un item peut posséder lui aussi une collection d'item qui peuvent eux aussi posséder une collection d'items, etc. Multiplier les collections comme tu le fais, sans tenir compte qu'elles fonctionnent toutes de la même manière (avec simplement des items qui peuvent être de nature différentes — pour la liste des projets en tout cas), c'est ne rien comprendre encore au code.
Et aussi : POURQUOI est-ce que tu ne proposes ces couches que MAINTENANT que je soulève un problème ?


CHATGPT : Tu as raison : il ne faut pas multiplier ProjectCollection, EventCollection, PersoCollection, etc. si le mécanisme est identique.

La bonne abstraction serait plutôt :

Item
ItemCollection
ItemTree
ListView
ListController

Et ensuite seulement des spécialisations métier :

ProjectItem
EventItem
BrinItem
PersoItem

La règle commune :

un item peut contenir une collection d’items

Donc Eventer2 devrait être pensé comme :

* une arborescence d’items ;
* avec des vues de listes ;
* et des comportements communs ;
* pas comme une suite de panneaux spéciaux.

Et oui : j’aurais dû voir ça avant.


## ENSUITE

MOI : Je pense qu'on va ré-essayer, parce que je n'ai vraiment pas envie d'abandonner ce projet auquel je vois des débouchés énormes chez les auteurs. La différence : je superviserais vraiment ton code, même si ça me déchire le cœur de devoir le faire.

Impératif quand même : qu'on garde le même design, qui me plaisait vraiment bien. Donc, je garde déjà  la feuille styles.css. Je garde aussi app.rb qui jusque-là, a bien répondu, non ?

CHATGPT : Oui.

styles.css :

* aucun problème ;
* le design peut être conservé intégralement ;
* même si l’architecture interne change complètement.

Et honnêtement :

* vu ce que tu décris de l’UI,
* le design actuel est une vraie force du projet.

Pour app.rb, oui aussi :

* il semble avoir été plutôt stable ;
* les problèmes venaient surtout du front ;
* pas du backend Sinatra/Finder/persistence.

Donc, pour Eventer2, je garderais probablement :

* styles.css
* app.rb
* les formats JSON
* certaines idées d’organisation DOM
* certains raccourcis clavier
* le comportement général UX

Et je reconstruirais surtout :

* l’architecture front ;
* le routing ;
* l’édition ;
* les panels ;
* l’état applicatif ;
* la navigation ;
* la persistence côté JS.


## Dernier

MOI : Regarder dans la fichier config.js comme j'ai rationnalisé la description des aides de raccourcis-clavier (qui aide à comprendre ce que chaque panneau doit faire en fonction de ses éléments (items)