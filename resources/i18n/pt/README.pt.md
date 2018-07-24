# Documentação Oficial do Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

Uma versão HTML dessa documentação disponível em [https://docs.perl6.org/](https://docs.perl6.org/).
Que é a versão recomendada.

Também disponível uma ferramenta de linha de comando: "p6doc".

(Se está acessando pelo GitHub, a maioria dos documentos não serão exibidos corretamente, pois estão escritos em Perl 6 Pod
mas o GitHub assume que são Perl 5 Pod.)

## README em outras línguas

* [README em alemão](../de/README.de.md)
* [README em chinês](../zh/README.zh.md)
* [README em italiano](../it/README.it.md)
* [README em inglês](../../../README.md)
* [README em francês](../fr/README.fr.md)
* [README em espanhol](../es/README.es.md)
* [README em japonês](../jp/README.jp.md)
* [README em neerlandês](../nl/README.nl.md)

## Instalar p6doc

Este módulo está disponivel no ecosistema de módulos do Perl 6. Use:

    $ zef install p6doc

para instalar os binários e adicionar ao path.

## Usar p6doc

Com o `perl6` (Rakudo) no `PATH`, execute

    $ ./bin/p6doc Str

para ver a documentacão da clase `Str`, ou

    $ ./bin/p6doc Str.split

para ver a documentacão do método `split` da clase `Str`. Pode
omitir `./bin` se o `p6doc` foi instalado com o `zef`.
Também pode executar

    $ p6doc -f slurp

para pesquisar a documentacão padrão de subrotinas. Dependendo da velocidade
do disco rígido e da versão do Rakudo, é possivel que demore minutos.

-------

## Gerando a documentacão HTML

Instale as dependências executando o siguinte no directório onde estão as fontes:

    $ zef --deps-only install .

[`rakudobrew`](https://github.com/tadzik/rakudobrew), precisa que seja executado tabém:

    $ rakudobrew rehash

para atualizar os links de compatibilidade de executáveis.

Além das dependências de Perl 6, precisa do `graphviz` instalado. No Debian
instale usando:

    $ sudo apt-get install graphviz

Para suporte ao destaque de código, precisa também do [nodejs](https://nodejs.org) instalado e disponível no path.
E também das suas depedências, incluindo `g++`.

Para gerar as páginas web da documentacão com destaque de código, executa:

    $ make html

Para gerá-las sem destaque de código, use:

    $ make html-nohighlight

Após estarem criadas, pode ver localmente no teu computador com o incluso `app.pl`, executando:

    $ make run

Feito o anterior, a documentacão estará dsiponível em [http://localhost:3000](http://localhost:3000).

`app.pl` depende do [Mojolicious](https://metacpan.org/pod/Mojolicious)
instalado. Tamabém é necesário o [nodejs](https://nodejs.org) para que funcione o destaque de código.
E também outros módulos Perl 5, instalados executando:

    $ cpanm --installdeps .

---------

## Precisamos de Ajuda!

Perl 6 não é uma linguagem de programação pequena, e documentá-la requer bastante esforço. Qualquer ajuda é bem-vinda.

Algumas maneira de nos ajudar:

  * Adicionando documentacão de classes, roles, métodos e operadores.
  * Adicionando exemplos de uso à documentacão existente.
  * Revisando e corrigindo.
  * Abrindo issues no GitHub se acha que falta documentacão.
  * Fazendo `git grep TODO` neste repositório, e substituindo os items TODO por documentação.

[Esta página](https://github.com/perl6/doc/issues) tem uma lista de issues atuais e partes da documentação que faltam.
[CONTRIBUTING](CONTRIBUTING.md) explica brevemente como começar a contribuir.

--------
## Algumas questões:

**P:** Por que não estão incluindo a documentação no código fonte do CORE?<br>
**R:** Várias razões:

  1. Esta documentação pretende ser universal com respeito a uma versão dada de uma especificacão, e não necesariamente estar
  ligada a uma implementação específica de Perl 6.

  2. O tratamento das implementações ao Pod 6 é inconsistente; assim se evita impactos potenciais durante a execução.

  3. Um repo separado na conta do Perl 6 de GitHub convida mais contribuidores e editores a participar.

**P:** Eu deveria incluir os métodos das superclases ou dos roles?<br>
**A:** Não. A versão HTML já os inclui, e o `p6doc` também.

--------

## Objetivo

> Quero que p6doc e docs.perl6.org se tornem o recurso número 1 para consultar quando quiser conhecer qualquer
> característica do Perl 6, seja a linguagem ou seus tipos e rotinas. Quero que seja útil para todo programador de Perl 6.
>
>    -- moritz

--------

# ENV VARS

- `P6_DOC_TEST_VERBOSE` como `true` para mostrar mensajens durante a execução do conjunto de testes. Prático para depurar testes
que falham.
- `P6_DOC_TEST_FUDGE` muda testes `skip-test` para TODO no teste `xt/examples-compilation.t`.

# LICENÇA

O código neste repositório está disponível sob a Artistic License 2.0 como publicado pela Perl Foundation. O arquivo
[LICENSE](LICENSE) contém o texto completo.

Este repositório também contém código de terceiros que podem ter outra licença, em cujo caso indicam o copyright e licença no
topo do próprio arquivo. Atualmente incluem:

* jQuery e jQuery UI: Copyright 2015 jQuery Foundation e outros contribuidores;
  [Licença MIT](http://creativecommons.org/licenses/MIT)
* [plugin jQuery Cookie](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [Licença MIT](http://creativecommons.org/licenses/MIT)
* Exemplos do StackOverflow [Licença MIT](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [Licença MIT](http://creativecommons.org/licenses/MIT)
