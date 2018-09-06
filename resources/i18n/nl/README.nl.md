# Officiële documentatie van Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

Een HTML-versie van deze documentatie is te vinden onder [https://docs.perl6.org/](https://docs.perl6.org/);
dit is momenteel de aanbevolen manier om de documentatie te raadplegen. Daarnaast bestaat er voor het raadplegen
van de documentatie ook een command line tool genaamd "p6doc".

NOOT: Als je door deze repository bladert met behulp van GitHub, dan zullen de meeste bestanden niet correct
worden weergegeven omdat ze zijn opgemaakt in Perl 6 Pod, terwijl GitHub ze interpreteert als Perl 5 Pod.

## README in andere talen

* [README in het Chinees](../zh/README.zh.md)
* [README in het Duits](../de/README.de.md)
* [README in het Italiaans](../it/README.it.md)
* [README in het Spaans](../es/README.es.md)
* [README in het Frans](../fr/README.fr.md)

## Het installeren van p6doc

Deze module is beschikbaar via het Perl 6 module-ecosysteem. Geef het commando:

    $ zef install p6doc

om het p6doc programma te installeren, en het beschikbaar te maken via het zoekpad.

## Het gebruik van p6doc

Geef, met een uitvoerbaar Rakudo `perl6` bestand in het zoekpad `PATH`, het commando:

    $ ./bin/p6doc Str

om de documentatie voor klasse `Str` te bekijken, of het commando:

    $ ./bin/p6doc Str.split

om de documentatie voor methode `split` in klasse `Str` in te zien. Je kunt
het `./bin/`-deel achterwege laten als je Rakudo met behulp van `zef` hebt geïnstalleerd.
Je kunt ook het commando:

    $ p6doc -f slurp

gebruiken om door de documentatie van de standaardfuncties te bladeren. De snelheid hierbij is
afhankelijk van je schijfsnelheid en Rakudoversie.

-------

## Het genereren van de HTML-documentatie

Installeer de benodigde dependencies door het volgende commando uit te voeren in de checkout directory:

    $ zef --deps-only install .

Als je gebruik maakt van [`rakudobrew`](https://github.com/tadzik/rakudobrew) heb je ook
het volgende commando nodig om de shims voor de geïnstalleerde programma's te updaten:

    $ rakudobrew rehash

Naast de Perl 6 dependencies dien je ook 'graphviz' geïnstalleerd te hebben; op Debian kun
je dit bewerkstelligen met het commando:

    $ sudo apt-get install graphviz

Om de documentatiewebpagina's te genereren geef je simpelweg het volgende commando:

    $ make html

Merk op dat je [nodejs](https://nodejs.org) geïnstalleerd dient te hebben om HTML pagina's
te kunnen genereren met het bovenstaande commando. In het bijzonder dient het uitvoerbare
`node` bestand via het zoekpad `PATH` vindbaar te zijn. Daarnaast moet ook `g++` zijn
geïnstalleerd om enkele dependencies die samen met nodejs zijn geïnstalleerd te compileren.
nodejs is overigens alleen nodig voor het highlighten van opgenomen codefragmenten. Als
dit niet vereist of gewenst is, dan volstaat het commando:

    $ make html-nohighlight

Na het genereren van de pagina's kun je ze lokaal op je computer bekijken door het starten van
het meegeleverde `app.pl`-programma:

    $ make run

Je kunt de documentatie dan bekijken door je webbrowser te verwijzen naar [http://localhost:3000](http://localhost:3000).

Je dient ten minste [Mojolicious](https://metacpan.org/pod/Mojolicious) te hebben geïnstalleerd, en
voor syntax highlighting is ook [nodejs](https://nodejs.org) nodig. Eventuele andere modules die je
nodig zou kunnen hebben kun je allemaal installeren middels het commando:

    $ cpanm --installdeps .

---------

## Hulp gevraagd!

Perl 6 is geen kleine taal en het documenteren ervan is dan ook een hele onderneming.
Alle hulp daarbij is van harte welkom, en wordt zeer gewaardeerd.

Dit zijn enkele manieren waarop je ons zou kunnen helpen:

 * Voeg ontbrekende documentatie toe voor klassen, rollen, methoden of operatoren.
 * Voeg gebruiksvoorbeelden toe aan bestaande documentatie.
 * Controleer en verbeter bestaande documentatie.
 * Wijs ons op ontbrekende documentatie door het openen van een issue op GitHub.
 * Doe een `git grep TODO` in deze repository, en vervang de TODO items door daadwerkelijke documentatie.


De [issues pagina](https://github.com/perl6/doc/issues) bevat een lijst van openstaande issues evenals een overzicht
van documentatieonderdelen waarvan bekend is dat ze ontbreken. Het [CONTRIBUTING dokument](CONTRIBUTING.md) legt
beknopt uit hoe je desgewenst kunt beginnen bij te dragen aan de documentatie.

--------

## Een paar kanttekeningen:

**Q:** Waarom wordt de documentatie niet geëmbed in de CORE broncode?<br>
**A:** Hiervoor bestaat een aantal redenen:

  1. Deze documentatie beoogt universeel te zijn ten aanzien van een
    gegeven versie van de specificatie, en is dus niet noodzakelijkerwijs
    verbonden aan een specifieke Perl 6 implementatie.
  2. De verwerking van geëmbedde Pod door implementaties is vooralsnog
    niet volkomen vlekkeloos; afzonderlijke documentatie voorkomt dus
    potentiële runtime-complicaties.
  3. Een aparte repository onder de perl6 GitHub-account werkt drempelverlagend,
    en nodigt meer mensen uit bij te dragen en teksten te bewerken.

**Q:** Kan ik ook bijdragen door methoden van superklassen of rollen op te nemen?<br>
**A:** Nee. De HTML-versie omvat op dit moment al methoden van superklassen en
    rollen, en het `p6doc`-script zal hieraan worden aangepast.

--------

## Visie

> Ik wens dat p6doc en docs.perl6.org het nummer 1-naslagwerk worden dat
> geraadpleegd kan worden wanneer je iets wilt weten over een Perl 6 feature,
> of dit nu behoort tot de taal zelf, of tot de ingebouwde typen en functies.
> Ik wil dat het van praktisch nut is voor iedere Perl 6-programmeur.
>
>    -- moritz

--------

# Omgevingsvariabelen

- Geef `P6_DOC_TEST_VERBOSE` een `true`-waarde om gedurende het doorlopen van de test suite uitvoerige meldingen weer te geven.
Dit is behulpzaam tijdens het debuggen van de test suite.
- `P6_DOC_TEST_FUDGE` zet `skip-test` codevoorbeelden om in TODO in `xt/examples-compilation.t` test.

# LICENTIE

De code in deze repository is beschikbaar onder de Artistic License 2.0 zoals gepubliceerd door The
Perl Foundation. Zie het [LICENSE](LICENSE) bestand voor de volledige tekst.

Deze repository bevat ook code die is geschreven door derde partijen en die onder een afwijkende licentie beschikbaar is gemaakt.
De betreffende bestanden vermelden het auteursrecht en de licentievoorwaarden aan het begin. Momenteel omvat deze categorie bestanden:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
