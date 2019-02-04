# PERL6の公式文書

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

[![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

ここにHTML版があります [https://docs.perl6.org/](https://docs.perl6.org/)。これを読むのがおすすめです。

また、"p6doc"と呼ばれるコマンドラインツールがあります。

あなたがこのリポジトリをGitHubで閲覧しているのなら、ほとんどのファイルは正しく表示されないかもしれません。 GitHubはPerl 6 PodをPerl 5 Podとみなすからです。

## 外国語のREADME

* [README in Chinese](../zh/README.zh.md)
* [README in Italian](../it/README.it.md)
* [README in English](../../../README.md)
* [README in German](../de/README.de.md)
* [README in Spanish](../es/README.es.md)
* [README in French](../fr/README.fr.md)

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

Perl 6の依存関係に加えて、 `graphiviz` がインストールしてある必要があります。
Debian環境なら下記のコマンドでインストールすることができます:

    $ sudo apt-get install graphviz

公式文書のウェブページを構築するには、下記のコマンドを実行するだけで大丈夫です:

    $ make html

上記のコマンドでHTMLのコンテンツを生成するためには[nodejs](https://nodejs.org)が必要になるかもしれないことに注意してください。
また、 `node` の実行ファイルが `PATH` 以下にある必要があります。
加えて、nodejsの依存モジュールをビルドするために `g++` もインストールされている必要があります。
nodejsはコードにシンタックスハイライトをかけたい場合にのみ必要になります。
もしもその必要がない場合は、次のコマンドを実行してください

    $ make html-nohighlight

ページの生成後は、同梱の `app.pl` プログラムを実行させることで、ローカル環境でこれらのページを見ることができます:

    $ make run

次のアドレスをブラウザに入力して閲覧してください:
[http://localhost:3000](http://localhost:3000).

少なくとも [Mojolicious](https://metacpan.org/pod/Mojolicious) がインストールされている必要があります。
またシンタックスハイライトを行いたい場合は [nodejs](https://nodejs.org) が必要になります。
その他の必要なモジュールについては、次のコマンドで全部インストールすることができます:

    $ cpanm --installdeps .

---------

## あなたの助けが必要です！

Perl 6は小さな言語ではありません。したがって、この言語の仕様を文書化するには多大な努力が必要です。
どんな些細なことでも私たちの助けになります。

例えばこんな方法があります:

 * クラス、ロール、メソッド、演算子について抜けていた文書を追加する
 * 使用例を追加する
 * 推敲し文書を修正する
 * GithubでISSUEを開いて抜けている文書についてメンテナーに報告する
 *  `git grep TODO` コマンドをこのリポジトリで実行し、TODOになっている事項を実際の文書に置き換える

[Issues page](https://github.com/perl6/doc/issues) には現在のissueと足りない文書が掲載されています。
また、 [the CONTRIBUTING document](CONTRIBUTING.md)
にはどうやって文書作成に貢献したらよいのか簡潔に述べられています。

--------

## いくつかの注意点:

**Q:** どうしてコアのソースコードに文書を埋め込んでいないのですか?<br>
**A:** いくつか理由があります:

  1. この文書はあるバージョンの仕様に対して共通な内容が掲載されるようになっています。
     特定のPerl 6の実装に対するものではありません。
  2. 埋め込まれたPodに対する扱い方にはまだまだばらつきがあります。
     実行時間に対する影響を避けています。
  3. コアのソースコードとはまた別のリポジトリに対してコントリビューターや編集者を招待しています。

**Q:** スーパークラスやロールのメソッドを含めるべきですか?<br>
**A:** 含めるべきではありません。HTML版の文書にはすでにスーパークラスとロールのメソッドが含まれています。
　　　　また `p6doc` スクリプトが先ほど述べたことと同じことを教えてくれるでしょう。

--------

## ビジョン

> Perl 6の機能について調べているときにp6docとdocs.perl6.orgがこの世界で一番の情報源になってほしい。
> それは言語自体においても、組み込みの型においても、ルーチンにおいてもそうであってほしい。
> この文書がすべてのPerl 6プログラマーにとって便利なものになってほしい。
>    -- moritz

--------

# 環境変数

- `P6_DOC_TEST_VERBOSE` をtrueにするとテストの実行中に詳細なメッセージを表示することができます。実行に失敗したデストをデバッグするときに便利です。
- `P6_DOC_TEST_FUDGE` は `xt/examples-compilation.t` において、`skip-test` なコードを TODO として実行するようにします。

# LICENSE

The code in this repository is available under the Artistic License 2.0
as published by The Perl Foundation. See the [LICENSE](LICENSE) file for the full
text.

This repository also contains code authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
