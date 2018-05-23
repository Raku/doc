# PERL6の公式文書

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

ここにHTML版があります [https://docs.perl6.org/](https://docs.perl6.org/)。これを読むのがおすすめです。

また、"p6doc"と呼ばれるコマンドラインツールがあります。

あなたがこのリポジトリをGitHubで閲覧しているのなら、ほとんどのファイルは正しく表示されないかもしれません。 GitHubはPerl 6 PodをPerl 5 Podとみなすからです。

## 外国語のREADME

* [README in Chinese](README.zh.md)
* [README in Italian](README.it.md)
* [README in English](README.md)
* [README in German](README.de.md)
* [README in Spanish](README.es.md)
* [README in French](README.fr.md)

## p6docの使用

`PATH`にRakudo `perl6`が入った状態で、

    $ ./bin/p6doc Str

と打つと`Str`クラスの文書を閲覧することができます。また、

    $ ./bin/p6doc Str.split

と打つと、`Str`クラスの`split`メソッドの文書を閲覧することができます。zefでインストールした場合は、`./bin`を抜いて

    $ p6doc -f slurp

と打つと標準的な関数の文書を閲覧することができます。これは時間がかかることがあります。

-------

## HTMLの文書の構築

チェックアウトしたディレクトリで依存関係をインストールしてください:

    $ zef --deps-only install .

[`rakudobrew`](https://github.com/tadzik/rakudobrew)を使用している場合は、次のコマンドも実行してください:

    $ rakudobrew rehash

<!-- Note: The Building the HTML documentation section is partially completed -->
