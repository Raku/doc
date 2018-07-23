# Documentazione Ufficiale Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

Una versione HTML di questa documentazione può essere trovata al seguente link [https://docs.perl6.org/](https://docs.perl6.org/).
Il link precedente è il modo consigliato di leggere e usare la documentazione.

Esiste uno strumento da riga di comando denominato "p6doc",

(Se stai navigando questo repository via GitHub molti dei file non saranno visualizzati
correttamente poiché la documentazione è scritta usando Pod per Perl 6 e GitHub
lo considera invece come Pod per Perl 5 ).

## README in altri linguaggi

* [README in Cinese](../zh/README.zh.md)
* [README in Inglese](../../../README.md)
* [README in Spagnolo](../es/README.es.md)
* [README in Tedesco](../de/README.de.md)
* [README in Francese](../fr/README.fr.md)

## Installare p6doc

Lo strumento p6doc è un modulo disponibile nell'ecosistema  Perl 6.
Il seguente comando

    $ zef install p6doc

installa lo strumento e lo rende disponibile nel tuo path di esecuzione.

## Usare p6doc

Una volta che si ha una versione Rakudo `perl6` eseguibile nel proprio `PATH`, è sufficiente
impartire il comando

    $ ./bin/p6doc Str

per vedere la documentazione della classe  `Str`, o nello specifico

    $ ./bin/p6doc Str.split

per visualizzar ela documentazione del method  `split` nella classe `Str`.
E' possibile omettere il prefisso  `./bin` se si è installato tramite `zef`.
E' possibile anche usare il comando seguente

    $ p6doc -f slurp

per sfogliare la documentazione di una funzione.
A seconda della velocità del disco e della versione di Rakudo, il rendering
può richiedere un po' di tempo.

-------

## Assemblare la documentazione HTML

E' necessario installare le dipendenze eseguendo il seguente comando
nella directory ove si è fatto il checkout del repository:

    $ zef --deps-only install .

Se si sta usando [`rakudobrew`](https://github.com/tadzik/rakudobrew),
è necessario anche eseguire il seguente comando in modo da aggiornare gli "shims"
per gli eseguibili installati:

    $ rakudobrew rehash

Oltre alle dipendenze specifiche di  Perl 6, è necessario anche avere installato `graphviz`,
che su sistemi Debian può essere installato con il seguente comando

    $ sudo apt-get install graphviz

Per costruire la documentazione in formato HTML è sufficiente eseguire il comando

    $ make html

Il comando precedente, al fine di generare contenuto HTML, richiede [nodejs](https://nodejs.org)
installato, e in particolare un eseguibile `node` raggiungibile nel `PATH`,

Una volta che le pagine HTML sono state generate, è possibile visualizzarle
sul computer locale mediante l'applicazione `app.pl` che viene avviata con
il comando

    $ make run

E' possibile visualizzare la documentazione puntanto il proprio browser web all'indirizzo
[http://localhost:3000](http://localhost:3000).

Per realizzare gli "highlights" è necessario avere installato
[Mojolicious](https://metacpan.org/pod/Mojolicious)
e [nodejs](https://nodejs.org).
Sono necessari anche alcuni altri moduli, tutti installabili con il comando

    $ cpanm --installdeps .

---------

## Help Wanted!

Perl 6 è un linguaggio vasto e documentarlo richiede molta fatica.
Ogni forma di aiuto è apprezzata.

Alcuni modi per aiutare il progetto includono:

 * aggiungere documentazione mancante per classi, ruoli, metodi e operatori;
 * aggiungere esempi di codice alla documentazione esistente;
 * leggere e correggere gli errori nella documentazione;
 * aprire dei ticket su GitHub riguardo documentazione mancante;
 * eseguire il comando `git grep TODO` sul repository, inserendo la documentazione mancante.
   actual documentation.

La pagina dei ticket [Issues](https://github.com/perl6/doc/issues)
contiene una lista dei problemi noti e delle parti di documentazione che sono note essere incomplete,
e il file [CONTRIBUTING](CONTRIBUTING.md)
spiega brevemente come iniziare a contribuire alla documentazione.


--------

## Alcune note:

**Q:** Perché la documentazione non viene inclusa nell'albero dei sorgenti CORE?<br>
**A:** Ci sono diverse ragioni:

  1. Questa documentazione è pensata per essere universale rispetto
     a una data versione delle specifiche di linguaggio, e non necessariamente
     legata a una specifica implementazione di  Perl 6.
  2. Le implementazioni che gestiscono Pod Embedded sono ancora
     non ottimali; e così facendo si evitano problemi di runtime.
  3. Un repository separato sull'account perl6 Github invita un maggior numero di
     potenziali volontari e scrittori.

**Q:** Devo includere nella documentazione metodi dalle superclassi o ruoli?<br>
**A:** No. La versione HTML include già automaticamente i metodi dalle superclassi e dei ruoli, e lo strumento `p6doc` sarà migliorato in questo senso.

--------

## Visione

> I want p6doc and doc.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Perl 6 programmer.
>
>    -- moritz


*Io voglio che p6doc e docs.perl6.org siano la prima risorssa da consultare quanto vuoi sapere qualcosa riguardo a una funzionalità di Perl 6, sia essa di linguaggio, tipo di dato o routine. Voglio che sia utile a ogni programmatore Perl 6.*

--------

# Variabili di ambiente

- `P6_DOC_TEST_VERBOSE` impostata a un valore true consente di visualizare messaggi "verbose"
durante l'esecuzione di una test-suite. E' utile per debuggare test che falliscono.
- `P6_DOC_TEST_FUDGE` considera i frammenti di codice con `skip-test` come dei TODO quando esegue il test `xt/examples-compilation.t`.

# Licenza

Il codice in questo repository è disponibile mediante la licenza Artistic License 2.0
nella versione pubblicata da  The Perl Foundation.
Si veda il file [LICENSE](LICENSE) per l'intero contenuto della licenza.

Questo repository contiene anche codice scritto da autori terzi che potrebbe essere concesso con una licenza differente. Tali files indicano il copyright e i termini di licenza all'inizio del file stesso. Attualmente tali file includono:

* jQuery e jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Esempi da Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin da https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
