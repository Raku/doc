# Raku 官方文档

[![Build Status](https://travis-ci.org/Raku/doc.svg?branch=master)](https://travis-ci.org/Raku/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0) [![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/Raku/doc) [![CircleCI](https://circleci.com/gh/Raku/doc.svg?style=shield)](https://circleci.com/gh/Raku/doc/tree/master)

本文档的 HTML 版本位于 [https://docs.raku.org/](https://docs.raku.org/) 和
[`rakudocs.github.io`](https://rakudocs.github.io) （后者实际上更新更频繁）。
目前推荐使用这种方式来访问文档。

本仓库还提供命令行工具 `p6doc` 用于阅读文档（见下）。

## Docker 镜像

官方文档的 Docker 镜像地址为 [`jjmerelo/perl6-doc`](https://hub.docker.com/r/jjmerelo/perl6-doc) 。
这个镜像包含了一份 Web 版本的文档，对应的端口为 3000。你可以这样运行这个镜像：

    docker run --rm -it -p 3000:3000 jjmerelo/perl6-doc

或者，如果你想发布到其他端口：

    docker run --rm -it -p 31415:3000 jjmerelo/perl6-doc

现在，可以通过浏览器访问 http://localhost:3000 （或者 31415 端口，视情况而定）。

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

本模块可通过 Raku 模块生态系统获得。使用命令

    $ zef install p6doc

安装可执行文件并添加到执行路径（PATH）中。

**注意**: 由于 Pod 的解析规则改变，在 2018.06 之前的版本将无法通过测试从而无法安装，你可以选择升级到最新的版本或使用 `zef install --force p6doc` 来解决这个问题。无法通过测试并不影响 p6doc 的使用。

## 使用 p6doc

把 `rakudo` 添加到 `PATH` 中后，可以使用命令

    $ ./bin/p6doc Str

查看 `Str` 类的文档；或者使用命令

    $ ./bin/p6doc Str.split

查看 `Str` 类中的 `split` 方法。如果你已经使用 `zef` 安装了 `p6doc`，那么可以省略 `./bin`。你也可以使用命令

    $ p6doc -f slurp

浏览标准函数的文档（在这种情况下实际上会返回多个结果，你可以分别查看）。命令的响应可能会花点时间，这取决于磁盘的速度和 Rakudo 的版本。

-------

## 构建 HTML 文档

本文档可以渲染为静态 HTML 页面并/或在本地网站服务。
此过程涉及创建预编译文档的缓存，以便加快之后的生成速度。

> 建立文档有许多先决条件，你可能并不想亲自做。
> 不过，如果你需要 HTML 文档的本地副本，请通过克隆 https://github.com/rakudocs/rakudocs.github.io 进行下载。

以下是生成文档需要安装的先决条件：

* perl 5.20 或更新。
* node 10 或更新。
* graphviz 。
* [Documentable](https://github.com/Raku/Documentable) 。

请按照以下说明（在 Ubuntu 中）进行安装

    sudo apt install perl graphviz # 默认情况下，18.04 中未安装 perl
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    cpanm --installdeps .
    zef install Documentable

> 你可以用任何方式安装 perl 和 node ，包括使用版本管理器，只要它们可以从命令行运行即可。

这应该安装了所有的必备条件，现在你可以 clone 本存储库并开始构建：

    git clone https://github.com/Raku/doc.git # clone 存储库
    cd doc # 移动到本存储库的副本
    make for-documentable # 生成 CSS 和 JS 并安装高亮模块
    documentable start -a -v --highlight # 构建缓存并生成页面

只有在第一次构建缓存时才需要这样做。当源代码发生变化（由你自己完成或从本存储库中拉取）后，运行

    documentable update

将只会重新生成有变化的页面。

文档将在 `html` 子目录中生成。你可以使用任何静态Web服务器指向该目录，也可以使用基于 Mojolicious 的开发服务器，运行

    make run

这会在 3000 端口服务文档。

## nginx 配置

生成的文档的最新版本仅包含静态 HTML 页面。所有页面都以 `.html` 结尾；不过大多数内部链接不使用该后缀。大多数Web服务器（例如，服务 GitHub 页面的服务器）都会自动为你添加它。裸服务器不会。你需要向配置中添加这些以使其工作：

```
    location / {
        try_files $uri $uri/ $uri.html /404.html;
    }

```

这将为你重定向 URL 。可能需要在其他服务器应用中做出同样的配置。

---------

## 我们需要帮助！

Raku 不是小语言，为它做文档并维护这些文档需要付出很大的努力。我们会感激任何形式的帮助。

以下是一些帮助我们的方式：

 * 添加缺少的 class ，role ，method 或 operator 的文档
 * 为现有文档添加使用示例
 * 校对与更正文档
 * 通过 GitHub 的 issue 系统报告缺少的文档
 * 在本仓库下执行 `git grep TODO`，使用实际文档替换 TODO

[Issues 页面](https://github.com/Raku/doc/issues)列出了当前的 issue 和已知的缺失文档。[CONTRIBUTING 文档](../../../CONTRIBUTING.md)简要地说明了如何开始贡献文档。

--------

## 注记：

**Q:** 为什么不把文档内嵌到 Rakudo 的核心开发文件中？

**A:** 起码有以下几点：

  1. 这份文档与 Raku 的一份特定的语言标准相关联，
     而不是跟某个 Raku 的具体实现相绑定。
  2. 处理内嵌的 Pod 的功能还不太稳定，使用单独的文档仓库
     有利于避免运行时错误。
  3. 一个 Raku GitHub 账号下的单独的仓库能吸引更多
     潜在的贡献和编辑。

**Q:** 编写文档时我应该包括父类和 role 的方法吗？

**A:** 不用。HTML 版本的文档自动包括了这些方法，`p6doc` 脚本也会自动处理这些。

--------

## 愿景

> I want p6doc and docs.raku.org to become the No. 1 resource to consult
> when you want to know something about a Raku feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Raku programmer.
>
>    -- moritz

--------

# 环境变量

- 设置 `P6_DOC_TEST_VERBOSE` 为真值以在运行测试时输出详细信息，这在调试不通过的测试时很有帮助。
- 设置 `P6_DOC_TEST_FUDGE` 将在 `xt/examples-compilation.t` 测试中把标记为 `skip-test` 的代码实例当做 TODO 处理。

# 更新

现在暂时是手动更新。这大概需要改进。

# 协议

本仓库代码使用 Perl 基金会发布的 Artistic License 2.0 协议，可以在 [LICENSE](../../../LICENSE) 文件中查看完整的内容。

本仓库可能包括使用其他协议的第三方代码，这些文件在它们的首部注明了版权和协议。目前包括：

* jQuery 与 jQuery UI 库： Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie 插件](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* 来自 Stack Overflow 的示例 [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/Raku/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* 来自 https://github.com/christianbach/tablesorter 的表格排序插件；
  [MIT License](http://creativecommons.org/licenses/MIT)
