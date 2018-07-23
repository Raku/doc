# Offizielle Dokumentation von Perl_6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

Eine HTML Version dieser Dokumentation findet sich unter [https://docs.perl6.org/](https://docs.perl6.org/).
Dies ist die momentan empfohlene Methode diese Dokumentation zu nutzen.

Ausserdem gibt es ein Kommandozeilen-Tool namens "p6doc".

(Falls du dieses Repository via GitHub nutzt, werden die meisten
Dateien nicht korrekt angezeigt, weil sie in Perl 6 Pod geschrieben
sind, GitHub aber Perl 5 Pod an nimmt).

## README in anderen Sprachen

* [README in Chinesisch](../zh/README.zh.md)
* [README in Englisch](../../..README.md)
* [README in Italienisch](../it/README.it.md)
* [README in Spanisch](../es/README.es.md)
* [README in Französisch](../fr/README.fr.md)

## Installation von p6doc

Dieses Module ist im Perl 6 Module Ecosystem verfügbar. Verwende

    $ zef install p6doc

um die ausführbaren Dateien zu installieren und diese in deinem
Suchpfad verfügbar zu machen.

## Benutzung von p6doc

Falls sich Rakudo `perl6` als ausführbare Datei in deinem `PATH`
befindet, verwende

    $ ./bin/p6doc Str

um die Dokumentation der Klasse `Str` oder

    $ ./bin/p6doc Str.split

um die Dokumentation für die Methode `split` in der Klasse `Str`
anzuzeigen. Falls du `pod6doc` mit `zef` installiert hast, kannst du
`./bin` weg lassen. Ausserdem kannst du

    $ p6doc -f slurp

verwenden, um die Dokumentation von Standard-Funktionen
anzuzeigen. Abhängig von der Zugriffsgeschwindigkeit deiner Harddisk und der Rakudo Version kann dies eine Weile dauern.

-------

## Erzeugen der HTML Dokumentation

Installiere die Abhängigkeiten durch ausführen von

    $ zef --deps-only install .

in deinem Checkout-Verzeichnis.

Falls du [`rakudobrew`](https://github.com/tadzik/rakudobrew)
verwendest, führe den folgenden Befehl aus, um die
Kompatibilitäts-Anpassungen an den installierten ausführbaren Dateien
zu aktualisieren:

    $ rakudobrew rehash

Zusätzlich zu den Perl 6 Abhängigkeiten musst du `graphviz`
installiert haben. Unter Debian kannst du dies tun mit

    $ sudo apt-get install graphviz

Um die Web-Seiten der Dokumentation zu erstellen, verwende einfach

    $ make html

Bitte beachte, dass du ausserdem [nodejs](https://nodejs.org)
installiert haben musst, um die HTML Inhalte mit dem obigen Befehl zu
erzeugen, insbesonders muss sich ein ausführbares `node` in deinem
`PATH` befinden.

Nachdem die Web-Seiten erzeugt wurden, kannst du sie auf deinem lokalen Computer anzeigen, indem du das enthaltene Programm  `app.pl` mit

    $ make run

startest. Dann kannst du die Beispiel-Dokumentation anschauen, indem
du in deinem web browser die URL
[http://localhost:3000](http://localhost:3000) aufrufst.

Du benötigst zumindest eine Installation von
[Mojolicious](https://metacpan.org/pod/Mojolicious) auf deinem
Computer und du benötigst ausserdem [nodejs](https://nodejs.org) für
Syntax-Hervorhebung. Moglicherweise benötigst du noch weitere
Module. Du kannst diese mit

    $ cpanm --installdeps .

installieren.

---------

## Wir brauchen deine Hilfe!

Perl 6 ist eine umfangreiche Sprache und die Erstellung der Dokumentation erfordert einen hohen Aufwand. Wir sind dankbar für jede Hilfe.

Hier einige Möglichkeiten, uns dabei zu unterstützen:

 * Erstellen von fehlender Dokumentation für Klassen, Rollen, Methoden
   oder Operatoren.
 * Hinzufügen von Beispielen zur Verwendung zu bereits existierender
   Dokumentation.
 * Korrekturlesen und korrigieren der Dokumentation.
 * Eröffnen einer Problemmeldung (issue) auf GitHub zu fehlender Dokumentation.
 * Verwende `git grep TODO` in diesem Repository und ersetze TODO
   Abschnitte durch die eigentliche Dokumentation.

[Issues page](https://github.com/perl6/doc/issues) hat eine Liste der
derzeitigen Problemmeldungen und bekannte fehlende Teile der
Dokumentation. Das Dokument [CONTRIBUTING](CONTRIBUTING.md) erklärt
kurz wie du beginnen kannst, zur Dokumentation beizutrage.

--------

## Einige Anmerkungen:

**F:** Warum wird die Dokumentation nicht in die CORE Quellen integriert?<br>
**A:** Einige Gründe sind:

  1. Diese Dokumentation sill allgemeingültig sein in Bezug zu einer
     bestimmten Version der Spezifikation und soll nicht an eine
     spezifische Perl_6 Implementierung gebunden sein.

  2. Die Handhabung von eingebettetem Pod unterscheidet sich leicht
     zwischen verschiedenen Implementationen. Wir verhindern so
     potentielle Einflüsse der Laufzeit-Umgebung.

  3. Ein separates Repository im perl6 GitHub Konto lädt potentiell
     mehr Beitragende und Editoren ein.

**F:** Sollte ich Methoden von Super-Klassen und Rollen integrieren?<br>

**A:** Nein. Die HTML Version schliesst bereits Methoden von
       Super-Klassen und Rollen ein und das `p6doc` Skript wird diese
       zukünftig ebenfalls handhaben können.

--------

## Vision

> Ich möchte, dass p6doc and docs.perl6.org die Nr. 1 Quelle wird, die
> du nutzen kannst, wenn du etwas wissen willst über eine Perl 6
> ElementEigenschaft , sei es betreffend die Sprache, eingebaute Typen
> oder Routinen. Ich möchte dass sie nützlich ist für jeden Perl 6
> Programmierer.
>
>    -- moritz

--------

# ENV VARS

- Setze `P6_DOC_TEST_VERBOSE` auf einen `true` Wert, um ausführliche Meldungen während eines Runs der Test-Suite anzuzeigen.
Dies ist nützlich, um fehlgeschlagene Tests zu korrigieren.
- `P6_DOC_TEST_FUDGE` wandelt `skip-test` Code Beispiele in TODO um im `xt/examples-compilation.t` Test.

# LIZENZ

Der Programm-Code in diesem Repository ist verfügbar unter der
Artistic License 2.0, wie sie von der Perl Foundation veröffentlicht
wurde. Der komplette Text ist in der Datei [LICENSE](LICENSE) zu
finden.

Dieses Repository enthält ausserdem Code, der von Dritten erstellt und
möglicherweise unter einer anderen Lizenz lizenziert wurde. Solche
Dateien enthalten Angaben zu Copyright und Lizenz am Anfang der
Datei. Derzeit fallen unter anderem die folgenden Dateien unter diese
Kategorie:

* jQuery und jQuery UI libraries: Copyright 2015 jQuery Foundation und andere Beitragende; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Beispiele von Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Tabellen-Sortier-Plugin von https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
