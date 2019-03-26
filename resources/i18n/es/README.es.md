# Documentación Oficial de Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

Una versión HTML de esta documentación puede ser encontrada en [https://docs.perl6.org/](https://docs.perl6.org/).
Esta es la documentación recomendada.

También hay disponible un comando para la terminal: "p6doc".

(Si estás buscando el repositorio en GitHub, la mayoría de los archivos no serán mostrados correctamente,
ya que esto es Perl 6 Pod, y GitHub asume que es Perl 5 Pod).

## README en otros lenguajes

* [README en alemán](../de/README.de.md)
* [README en chino](../zh/README.zh.md)
* [README en italiano](../it/README.it.md)
* [README en inglés](../../../README.md)
* [README en francés](../fr/README.fr.md)

## Instalar p6doc

Este módulo está disponible en el ecosistema de módulos de Perl 6. Usa:

    $ zef install p6doc

para instalar los binarios y añadirlo a tu path.

## Usar p6doc

Cuando tengas `perl6` (Rakudo) añadido al `PATH`, ejecuta

    $ ./bin/p6doc Str

para ver la documentación para la clase `Str`, o

    $ ./bin/p6doc Str.split

para ver la documentación del método `split` de la clase `Str`. Puedes
omitir `./bin` si lo has instalado mediante `zef`.
También puedes hacer

    $ p6doc -f slurp

para buscar la documentación estándar de funciones. Dependiendo de la velocidad
de tu disco duro y de la versión de Rakudo, es posible que tarde unos minutos.

-------

## Generando la documentación en HTML

Instala las dependencias ejecutando lo siguiente en el directorio correspondiente:

    $ zef --deps-only install .

Si usas [`rakudobrew`](https://github.com/tadzik/rakudobrew), ejecuta también:

    $ rakudobrew rehash

para actualizar los correctores de compatibilidad de los ejecutables instalados.

Aparte de las dependencias de Perl 6, necesitas tener `graphviz` instalado. En Debian
lo puedes instalar mediante:

    $ sudo apt-get install graphviz

Para generar las páginas webs de la documentación, simplemente ejecuta:

    $ make html

Ten en cuenta que debes tener instalado [nodejs](https://nodejs.org)
para producir el contenido HTML con el anterior comando, en particular,
`node` debería estar en tu `PATH`.

Cuando las páginas hayan sido generadas, puedes verlas localmente
en tu ordenador ejecutando el programa `app.pl`:

    $ make run

Una vez hecho lo anterior, puedes ver la documentación de ejemplo
dirigiéndote a [http://localhost:3000](http://localhost:3000) en tu navegador.

Necesitarás, por lo menos, tener [Mojolicious](https://metacpan.org/pod/Mojolicious)
instalado. Además precisarás [nodejs](https://nodejs.org) para activar el resaltado.
También hay módulos adicionales que podrías necesitar, instálalos ejecutando:

    $ cpanm --installdeps .

---------

## ¡Se precisa ayuda!

Perl 6 no es un lenguaje de programación pequeño, y documentarlo requiere mucho esfuerzo. Cualquier ayuda es bienvenida.

Algunas maneras en las que puedes ayudarnos:

  * Añadiendo documentación de clases, roles, métodos u operadores.
  * Añadiendo ejemplos de uso a la documentación existente.
  * Revisando y corrigiendo la documentación.
  * Abriendo issues en GitHub si consideras que falta documentación.
  * Haciendo `git grep TODO` en este repositorio, y reemplazando los items TODO con documentación.

[Esta página](https://github.com/perl6/doc/issues) tiene una lista de issues actuales y partes de la documentación que faltan. El documento [CONTRIBUTING](CONTRIBUTING.md) explica brevemente cómo empezar a contribuir.

--------
## Algunas aclaraciones:

**P:** ¿Por qué no estáis incluyendo la documentación en el código fuente del CORE?<br>
**R:** Debido a varias razones:

  1. Esta documentación pretende ser universal con respecto a una versión dada de una especificación, y no necesariamente estar atada a una implementación específica de Perl 6.

  2. El tratamiento que las implementaciones hacen de Pod 6 es todavía un poco inconsistente; esto evita impactos potenciales en el tiempo de ejecución.

  3. Un repo separado en la cuenta de Perl 6 de GitHub invita a más contribuidores y editores a participar.

**P:** ¿Debería incluir los métodos de las superclases o de los roles?<br>
**A:** No. La versión en HTML ya los incluye, y el script `p6doc` también.

--------

## Objetivo

> Quiero que p6doc y docs.perl6.org lleguen a ser el recurso número 1 para consultar cualquier
> característica de Perl 6, ya sea del lenguaje o de sus tipos y rutinas. Quiero que sea útil para todo programador de Perl 6.
>
>    -- moritz

--------

# ENV VARS

- Poner `P6_DOC_TEST_VERBOSE` a `true` para mostrar mensajes durante la ejecución del conjunto de tests. Práctico para depurar un test suite que falla.
- `P6_DOC_TEST_FUDGE` cambia los ejemplos de código `skip-test` a TODO en el test `xt/examples-compilation.t`.

# LICENCIA

El código en este repositorio está disponible bajo la Artistic License 2.0 como lo publicó la Perl Foundation. Ver el fichero [LICENSE](LICENSE) para ver el texto completo.

Este repositorio también contiene código de terceros que podría tener otra licencia, en cuyo caso indican al principio de los mismos el copyright y sus términos de licencia. Actualmente incluyen:

* librerías jQuery y jQuery UI: Copyright 2015 jQuery Foundation y otros contribuidores; [Licencia MIT](http://creativecommons.org/licenses/MIT)
* [plugin jQuery Cookie](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Ejemplos de StackOverflow [Licencia MIT](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [Licencia MIT](http://creativecommons.org/licenses/MIT)
