# Eventer2 — Contexte de reprise complet

## Stack

- Ruby + Sinatra
- Frontend JavaScript vanilla
- ES Modules obligatoires
- Tests E2E Playwright
- CSS actuel conservé
- UX actuelle conservée
- app.rb conservé autant que possible

---

# Consignes impératives

## Livraison

- fichiers ENTIERS uniquement DANS UN ZIP EN RESPECTANT LES NOMS CI-DESSOUS
- JAMAIS DE CODE À COPIER-COLLER !!!!!
- jamais de patchs partiels
- jamais de snippets à copier/coller
- fichiers application dans `app.zip`
- fichiers tests dans `tests.zip`
- les ZIP ne doivent contenir QUE les fichiers nouveaux/modifiés
- Mettre les fichiers tests dans des dossiers pour une meilleure hiérarchie (app, navigation, eventer, ui, etc.)

## Réponses

- réponses très courtes
- pas de commentaires
- pas d’explications non demandées
- pas de philosophie
- pas de digression
- répondre uniquement à la question posée
- numéroter les points lorsque nécessaire

---

# Architecture générale stabilisée

## app.js

`app.js` doit rester minimal.

Responsabilités :

- boot
- instanciation
- wiring global

Exemple attendu :

```js
import App from './classes/App.js'

const app = new App()
app.start()
```

AUCUNE logique métier dans `app.js`.

---

# Architecture métier

## IMPORTANT

Il n’existe PAS de classe abstraite `Item` métier.

Erreur à éviter absolument :

```text
Item
  -> Project
  -> Event
  -> Brin
  -> Perso
```

Cette architecture a été explicitement rejetée.

---

# Vraies classes métier

Classes métier réelles :

```text
Eventer
Event
Brin
Perso
Project
```

## Règle centrale

Un `Eventer` contient :

- une liste d’identifiants d’events
- une liste d’identifiants de brins
- une liste d’identifiants de persos

Donc :

```js
{
  events: [],
  brins: [],
  persos: []
}
```

Les objets complets sont chargés ailleurs.

---

# Event

Un `Event` peut :

- posséder ses propres brins
- posséder ses propres persos
- posséder son propre Eventer enfant

Navigation :

- event sélectionné
- flèche droite => ouvre/crée son Eventer enfant

---

# Point architectural MAJEUR

La liste des projets EST un Eventer.

Ce n’est PAS un système séparé.

Donc :

- mêmes raccourcis
- même navigation
- même sélection
- même mécanique
- même logique générale

Seul l’AFFICHAGE peut être spécialisé.

---

# Root eventer

L’application démarre sur un premier Eventer racine.

Ce root Eventer contient les projets.

Donc `app.rb` n’a PAS à :

- scanner le dossier data
- chercher les projets lui-même
- connaître une logique spéciale de projets

Il charge simplement le root Eventer qui s’appelle `__projects__.json`.

---

# Séparation métier / UI

Très important.

NE PAS mélanger :

- métier
- DOM
- navigation
- rendu
- clavier

---

# Listing

L’abstraction commune réelle est :

```text
Listing
ListingItem
```

PAS `Item`.

`Listing` concerne uniquement :

- affichage
- navigation
- sélection
- édition locale
- réordonnancement
- filtrage

Donc :

- `Eventer` n’hérite PAS de `Listing`
- `Listing` appartient à la couche UI

---

# Adaptateurs spécialisés de Listing

Probablement :

```text
EventerListing
ProjectsListing
BrinsListing
PersosListing
```

Mais côté UI/navigation.

PAS métier.

---

# Repositories

Repositories obligatoires.

AUCUN fetch dans :

- panels
- vues
- modèles

Repositories prévus :

```text
ProjectRepository
EventerRepository
```

Possiblement ensuite :

```text
BrinRepository
PersoRepository
```

Responsabilités :

- chargement
- sauvegarde
- sérialisation
- accès fichiers/API

---

# App

`App` doit gérer :

- panels/listings actifs
- navigation
- chargement initial
- persistence globale
- breadcrumbs

PAS :

- rendu détaillé
- logique clavier locale
- édition locale

---

# Keyboard

Keyboard manager séparé.

PAS de :

```js
document.addEventListener(...)
```

partout.

Un dispatcher unique.

---

# EditableText

Édition locale obligatoire.

Chaque champ gère lui-même :

- Enter
- Escape
- Tab
- validation
- annulation

Interdiction de recréer un système global de mode UI.

---

# UI.mode

Interdit.

Aucun flag global du type :

```js
UI.mode
```

Chaque composant connaît uniquement SON état.

---

# Breadcrumbs

À conserver.

Ils représentent simplement la pile de navigation.

Exemple :

```js
[
  project,
  act,
  sequence,
  scene
]
```

---

# Données

## Sauvegarde

JSON uniquement.

Sauvegarde automatique.

Pas de base de données.

2000 events JSON considérés comme parfaitement acceptables.

---

# Structure data

À faire évoluer.

Pour les tests :

```text
data_ini_state/
│	
├── __projects__.json
├── __projects__/      (la liste des projets)
│   	├── __e2e__/
│   	│		├── __events__.json
│   	│		├── __brins__.json
│   	│		├── __persos__.json
│
```

---

# Tests

## TDD obligatoire

Progression :

- rouge
- vert
- refactor

## Ordre logique retenu

1. modèles métier
2. repositories
3. listings/navigation
4. rendu
5. clavier
6. E2E complets

## Tests Playwright

Projet configuré en ES modules.

Donc :

```js
import { test, expect } from '@playwright/test'
```

et JAMAIS :

```js
require(...)
```

---

# Important

Ne jamais :

- réécrire toute l’application dans `app.js`
- remettre toute la logique dans un seul fichier
- improviser une architecture différente
- réintroduire des concepts rejetés

---

# État actuel validé

## index.html

Conserve :

```html
<script src="/config.js"></script>
<script type="module" src="/app.js"></script>
```

---

# Tests déjà validés

Le test :

```text
application boots
```

passe.

---

# Prochaine direction

Implémenter correctement la liste des projets :

- comme premier Eventer
- avec vraie séparation architecture/UI/métier/repository
- sans logique spéciale cachée dans app.rb
- sans remettre toute la logique dans app.js

