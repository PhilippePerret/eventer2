# Eventer2

Deuxième version plus mure de la gestion des évènemenciers.

## Pour lancer l'application

* `ruby ./app.rb` dans le dossier
* lancer l'app Web Savari *Eventer*

## Pour le développement avec ChatGPT

* Ouvrir une fenêtre Terminal au dossier de l'application et y jouer le code `zsh xcreate_zip.sh` pour une version actuelle du code qu'il faut à chaque fois donner à l'IA pour ne pas qu'elle se paume.
* Lui dire que les tests se trouvent dans `dev/Tests.md` (ajouter les nouveaux tests là aussi)
* Changer souvent de fil de prompt parce que ça devient vite.


## Pour tuer tous les serveurs

`pkill -9 ruby`
`pkill -9 node` // si tests en route par exemple