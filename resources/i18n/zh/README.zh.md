# Perl 6 官方文档

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0) [![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

网站 [https://docs.perl6.org/](https://docs.perl6.org/)提供 HTML 版本的文档。目前我们推荐通过网站阅读文档。

本仓库还提供命令行工具 p6doc 用于阅读文档（详见下文）。

## Docker 镜像

官方文档的 Docker 镜像地址为 [`jjmerelo/perl6-doc`](https://hub.docker.com/r/jjmerelo/perl6-doc)。这个镜像包含了一份 Web 版本的文档，对应的端口为 3000。你可以这样运行这个镜像：

    docker run --rm -it -p 3000:3000 jjmerelo/perl6-doc

或者，如果你想发布到其他端口：

    docker run --rm -it -p 31415:3000 jjmerelo/perl6-doc

现在，可以通过浏览器访问 http://localhost:3000 （或者 31415 端口，取决于你使用了哪一个命令）。

## 其他语言版本的 README

* [英文版 README](../../../README.md)
* [荷兰文版 README](../nl/README.nl.md)
* [法文版 README](../fr/README.fr.md)
* [德文版 README](../de/README.de.md)
* [意大利文版 README](../it/README.it.md)
* [日文版 README](../jp/README.jp.md)
* [葡萄牙文版 README](../pt/README.pt.md)
* [西班牙文版 README](../es/README.es.md)

## 安装 p6doc

本模块可通过 Perl 6 模块生态系统获得。使用命令

    $ zef install p6doc

安装可执行文件并添加到执行路径（PATH）中。

**注意**: 由于 Pod6 的解析规则改变，在 2018.06 之前的版本将无法通过测试从而无法安装，你可以选择升级到最新的版本或使用 `zef install --force p6doc` 来解决这个问题。无法通过测试并不影响 p6doc 的使用。

## 使用 p6doc

把 `perl6` 添加到 `PATH` 中后，可以使用命令

    $ ./bin/p6doc Str

查看 `Str` 类的文档；或者使用命令

    $ ./bin/p6doc Str.split

查看 `Str` 类中的 `split` 方法。如果你已经使用 `zef` 安装了 `p6doc`，那么可以省略 `./bin`。你也可以使用命令

    $ p6doc -f slurp

浏览标准函数的文档。命令的响应可能会花点时间，这取决于磁盘的速度和 Rakudo 的版本。

-------

## 构建 HTML 文档

在本仓库顶级目录下运行下面的命令安装依赖：

    $ zef --deps-only install .

如果你使用 [`rakudobrew`](https://github.com/tadzik/rakudobrew)，也可以运行下面命令更新已安装执行文件：

    $ rakudobrew rehash

此外为了满足本仓库 Perl 6 代码的依赖，还需要安装 `graphviz`，在 Debian 可执行下面命令

    $ sudo apt-get install graphviz

一切就绪，运行下面的命令构建 Web 页面

    $ make html

> 为了生成最准确的结果，我们推荐使用最新的发行版。准确的说，比 2018.11 更新的任何版本。

请注意，为了通过上面的命令生成 HTML 文本，必须安装 [nodejs](https://nodejs.org)，特别地，可执行的 `node` 命令路径被添加到 `PATH` 里。

页面生成后，可以通过运行 `app.pl` 程序在本地查看这些页面：

    $ make run

打开浏览器并跳转到 [http://localhost:3000](http://localhost:3000) 以浏览文档页面。

为了正确显示代码高亮，需要安装 [Mojolicious](https://metacpan.org/pod/Mojolicious)和 [nodejs](https://nodejs.org)。安装 Mojolicious 时可能需要安装一些附加的依赖模块，通过下面的命令安装它们

    $ cpanm --installdeps .

如果你已经安装了 `pandoc`，那么你可以通过以下命令生成一个 epub 版本的文档

    $ make epub

---------

## 我们需要帮助！

Perl 6 不是小语言，为它做文档需要付出很大的努力。我们会感激任何形式帮助。

以下是一些帮助我们的方式：

 * 添加缺少的 class，role，method 或 operator 的文档
 * 为现有文档添加使用示例
 * 校对与更正文档
 * 通过 GitHub 的 issue 系统报告缺少的文档
 * 在本仓库下执行 `git grep TODO`，使用实际文档替换 TODO

[Issues 页面](https://github.com/perl6/doc/issues)列出了当前的 issue 和已知的缺失文档。[CONTRIBUTING 文档](CONTRIBUTING.md)简要地说明了如何开始为文档工程作出贡献。

--------

## 注记：

**Q:** 为什么不把文档内嵌到 Rakudo 的核心开发文件中？

**A:** 起码有以下几点：

  1. 这份文档与 Perl 6 的一份特定的语言标准相关联，
     而不是跟某个 Perl 6 的具体实现相绑定。
  2. 处理内嵌的 Pod 的功能还不太稳定，使用单独的文档仓库
     有利于避免运行时错误。
  3. 一个 perl6 GitHub 账号下的单独的仓库能吸引更多
     潜在的贡献和编辑。

**Q:** 编写文档时我应该包括父类和 role 的方法吗？

**A:** 不用。HTML 版本的文档自动的包括了这些方法，`p6doc` 脚本也会自动地处理这些。

--------

## 愿景

> I want p6doc and docs.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Perl 6 programmer.
>
>    -- moritz

--------

# 环境变量

- 设置 `P6_DOC_TEST_VERBOSE` 为真值以在运行测试时输出详细信息，这在 debug 测试不通过的时候很有帮助。
- 设置 `P6_DOC_TEST_FUDGE` 将在 `xt/examples-compilation.t` 测试中把标记为 `skip-test` 的代码实例当做 TODO 处理。

# 协议

本仓库代码使用 Perl 基金会发布的 Artistic License 2.0 协议，可以在 [LICENSE](LICENSE) 文件中查看完整的内容。

本仓库可能包括使用其他协议的第三方代码，这些文件在它们的首部注明了版权和协议。目前包括：

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
