PERLの文書化

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

ここにHTMLの版がある [https://docs.perl6.org/](https://docs.perl6.org/)。このHTMLのを読むください。



あまりにも["p6doc"]と呼ばれるコマンド行があります。

あなたは参照でGITHUBと展示 宜しくじゃないです。[Perl 6 Pod]ですしかしGITHUB[PERL 5 POD]で決め込む。

## 外国語のREADME

* [README in Chinese](README.zh.md)
* [README in Italian](README.it.md)
* [README in English](README.md)

# [p6doc]の安置

`PATH`の`perl6`で[Rakudo]タイプしてください。

    $ ./bin/p6doc Str

`Str`クラスの文書化読んでください。

    $ ./bin/p6doc Str.split

`split`形式の`Str``./bin`抜きタイプしてくださいとあなたは`zef`でインスコ 。も行うください

    $ p6doc -f slurp

それは時間がかかることがあります 。

-------

## HTMLの文書化建てる

従属インスコくださいで[checkout]の ディレクトリ

    $ zef --deps-only install .

[`rakudobrew`](https://github.com/tadzik/rakudobrew)使うと此れで エグゼキュートください 。

    $ rakudobrew rehash
