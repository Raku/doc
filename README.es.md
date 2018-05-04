# Documentación Oficial de Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

Una versión HTML de esta documentación puede ser encontrada en [https://docs.perl6.org/](https://docs.perl6.org/).
Esta es la documentación recomendada.

También hay disponible un comando para la terminal: "p6doc".

(Si estás buscando el repositorio en GitHub, la mayoría de los archivos no serán mostrados correctamente,
ya que esto es Perl 6 Pod, y GitHub asume que es Perl 5 Pod).

## README en otros lenguajes

* [README in Chinese](README.zh.md)
* [README in Italian](README.it.md)
* [README in English](README.md)

## Instalar p6doc

Este módulo esta disponible en el ecosistema de módulos de Perl 6. Usa:

    `$ zef install p6doc`

para instalar los binarios y añadirlo a tu path.

## Usa p6doc

Con `perl6` (Rakudo) añadido al `PATH`, ejecuta

    $ ./bin/p6doc Str

para ver la documentación para la clase `Str`, o

    $ ./bin/p6doc Str.split

para ver la documentación para el método `split` de la clase `Str`. Puedes
omitir `./bin` si lo has instalado mediante `zef`. 
También puedes hacer

    $ p6doc -f slurp

para buscar la documentación estándar de funciones. Dependiendo de la velocidad
de tu disco duro y de la versión de Rakudo, es posible que tarde unos minutos.

-------

## Generando la documentación HTML

Instala las dependencias ejecutando lo siguiente en el directorio correspondiente:

    $ zef --deps-only install .

Si usas [`rakudobrew`](https://github.com/tadzik/rakudobrew), ejecuta también

    $ rakudobrew rehash

para actualizar los correctores de compatibilidad de los ejecutables instalados.

A parte de las dependencias de Perl 6, necesitas tener `graphviz` instalado. En Debian 
lo puedes instalar mediante:

    $ sudo apt-get install graphviz

Para generar las páginas webs de la documentación, simplemente ejecuta

    $ make html

Ten en cuenta que debes tener instalado [nodejs](https://nodejs.org)
para producir el contenido HTML con el anterior comando, en particular,
`node` debería estar en tu `PATH`.

Cuando las páginas hayan sido generadas, puedes verlas en localmente
en tu ordenador ejecutando el programa `app.pl`:

    $ make run

Una vez hecho lo anterior, puedes ver la documentación de ejemplo
dirigiéndote a [http://localhost:3000](http://localhost:3000), en tu navegador.

Necesitarás, por lo menos, tener [Mojolicious](https://metacpan.org/pod/Mojolicious)
instalado. Además necesitarás [nodejs](https://nodejs.org) para activar el resaltado.
También hay módulos adicionales que podrías necesitar, instálalos ejecutando:

    $ cpanm --installdeps .

---------
