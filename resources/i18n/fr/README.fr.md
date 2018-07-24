# Documentation officielle de Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

La version HTML de cette documentation peut être trouvée en [https://docs.perl6.org/](https://docs.perl6.org/).
C'est la documentation reconmmandée.

Une commande est également disponible pour le terminal: "p6doc".

(Si vous recherchez ce repository via GitHub, la plupart des fichiers ne seront pas affichés correctement car la documentation est écrite avec Pod pour Perl 6 et GitHub le considère comme Pod pour Perl 5)


## README dans d'autres langues

* [README en allemand](../de/README.de.md)
* [README en anglais](../../../README.md)
* [README en chinois](../zh/README.zh.md)
* [README en espagnol](../es/README.es.md)
* [README en italien](../it/README.it.md)
* [README en japonais](../jp/README.jp.md)

## Installez p6doc

`p6doc` est un module disponible dans l'écosystème des modules Perl 6. Utilisez la comande suivante:

    $ zef install p6doc

pour installer le module et l'ajouter à votre path.

## Utilisez p6doc

Une fois que vous ajoutez `perl6` (Rakudo) au `PATH`, exécutez la commande


    $ ./bin/p6doc Str

pour voir la documentation de la classe `Str`, vous pouvez aussi exécuter la commande

    $ ./bin/p6doc Str.split

pour voir la documentation de la méthode `split` dans la classe `Str`.
Il est possible d'omettre le préfixe `./Bin` s'il est intallé via `zef`.
Vous pouvez également utiliser la commande

    $ p6doc -f slurp

pour parcourir la documentation des fonctions standard. Selon la vitesse de votre disque et la version de Rakudo, cela peut prendre un certain temps.

-------

## Générer la documentation HTML

Pour installez les dépendances exécutez la commande suivante dans le répertoire correspondant:

    $ zef --deps-only install .

Si vous utilisez [`rakudobrew`](https://github.com/tadzik/rakudobrew), exécutez également la commande suivante afin de mettre à jour les `shims` pour les exécutables installés:

    $ rakudobrew rehash

En plus des dépendances Perl 6, vous devez avoir `graphviz` installé, que vous pouvez installer avec la commande:

    $ sudo apt-get install graphviz

Pour générer la documentation au format `HTML`, il suffit d'exécuter la commande:

    $ make html

Vous devez avoir installé [nodejs](https://nodejs.org) pour pouvoir produire le contenu au format `HTML` avec la commande précédente, en particulier, `node` devrait être dans le `PATH`.

Une fois les pages HTML ont été générés, elles peuvent être visualisées sur votre ordinateur via `app.pl`, en exécutant la commande:

    $ make run

Après cela, vous pouvez voir la documentation dans votre navigateur internet au [http://localhost:3000](http://localhost:3000)

Vous devez avoir installé [Mojolicious](https://metacpan.org/pod/Mojolicious).
Vous aurez également besoin [nodejs](https://nodejs.org) pour pouvoir utiliser le surlignement.
Il y a aussi des modules supplémentaires dont vous pourriez avoir besoin, pour les installer, exécutez la commande:

    $ cpanm --installdeps .

---------

## Nous avons besoin de votre aide!

Perl 6 est un très grand langage de programmation, le documenter nécessite beaucoup d'efforts.
Toute aide est appréciée.

Il y a plusieurs façons de nous aider, certaines d'entre elles sont:

  * Ajouter la documentation manquante pour les classes, les rôles, les méthodes ou les opérateurs.
  * Ajouter des exemples d'utilisation à la documentation existante.
  * Examiner et corriger la documentation.
  * Ouvrez `issues`sur GitHub si vous  pensez qu'il y a un manque d'information sur la documentation.
  * Faites `git grep TODO` dans ce repository, et remplacez les éléments TODO par la documentation réelle.

[Cette page](https://github.com/perl6/doc/issues) contient une liste des problèmes actuels e des parties de documentation manquantes.
Le document [CONTRIBUTING](CONTRIBUTING.md) explique comment vous pouvez commencer à aider.
--------
## Quelques clarifications:

**Q:** Pourquoi la documentation n'est-elle pas incluse dans le code source CORE?<br>
**R:** Il y a plusieurs raisons:

  1. Cette documentation est destinée à être universelle par rapport à une version spécifique, elle n'est pas destinée à être une documentaion spécifique d'une implémenation spécifique de Perl 6.

  2. La gestion des implémentations de Pod intégré est encore un peu irrégulière; cela évite les impacts d'execution potentiels.

  3. Un Repository séparé du compte Perl 6 de GitHub encourage plus de contributeurs et éditeurs à participer.

**Q:** Dois-je inclure des méthodes provenant de superclasses ou de rôles dans la documentation?<br>
**R:** Non. La version HTML inclut déjà cette information, et le script `p6doc` l'inclut également.

--------

## Objetif

> Je veux que `p6doc` et docs.perl6.org soient la première ressource à consulter
> toute  fonctionnalité de Perl6,
> soit la langue, ou les types et les routines integrées. Je veux qu'il soit utile pour tous les programmeurs de Perl6.
>
>    -- moritz

--------

# Variables d'environnement

- Mettre `P6_DOC_TEST_VERBOSE` à `true` pour afficher des messages pendant l'exécution de l'ensemble des tests. Ceci est utile lors du débogage de la suite de tests défaillante.
- `P6_DOC_TEST_FUDGE` modifie les échantillons de code `skip-test` comme TODO dans le test `xt/examples-compilation.t`.

# LICENCE

Le code de ce repository est disponible sous la licence `Artistic License 2.0` tel que publié par la Perl Foundation. Voir le fichier [LICENSE](LICENSE) pour voir le texte intégral.

Ce repository contient également du code créé par des tiers que peuvent être concédés sous une licence différente. Ces fichiers indiquent les droits d'auteur et les termes de la licence en haut du fichier. Actuellement, is comprendent:

* Bibliothèques jQuery et jQuery UI: Copyright 2015 jQuery Foundation et autres contributeurs; [Licence MIT](http://creativecommons.org/licenses/MIT)
* [plugin jQuery Cookie](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Exemples de StackOverflow [Licence MIT](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Tableau trieur plugin de https://github.com/christianbach/tablesorter ;
  [Licence MIT](http://creativecommons.org/licenses/MIT)
