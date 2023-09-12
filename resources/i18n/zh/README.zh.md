# Raku 官方文档

[![Build Status](https://travis-ci.org/Raku/doc.svg?branch=master)](https://travis-ci.org/Raku/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0) [![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/Raku/doc) [![CircleCI](https://circleci.com/gh/Raku/doc.svg?style=shield)](https://circleci.com/gh/Raku/doc/tree/master)

本文档的 HTML 版本位于 [https://docs.raku.org/](https://docs.raku.org/) 和
[`rakudocs.github.io`](https://rakudocs.github.io) （后者更新更频繁）。
目前推荐使用这种方式来访问文档。

## Docker 镜像

官方文档的 Docker 镜像地址为 [`jjmerelo/perl6-doc`](https://hub.docker.com/r/jjmerelo/perl6-doc) 。
这个镜像包含了文档的一份副本，对应的端口为 3000。你可以这样运行这个镜像：

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

## 安装 rakudoc

请查看 https://github.com/Raku/rakudoc 来了解在命令行查看文档的工具。

## 构建 HTML 文档

注意：如果你只是想要一份 HTML 站点的副本，而不想自己处理构建，你可以从这里克隆：[`https://github.com/rakudocs/rakudocs.github.io`](https://github.com/rakudocs/rakudocs.github.io)。

本文档可以渲染为静态 HTML 页面和/或在本地网站服务。此过程涉及创建预编译文档的缓存，以便加快之后的生成速度。

你需要安装以下这些才能生成文档：

* perl 5.20 或更新。
* node 10 或更新。
* graphviz。
* [Documentable](https://github.com/Raku/Documentable)。

在 Ubuntu 中，请按照以下说明进行安装：

    sudo apt install perl graphviz # 默认情况下，18.04 中未安装 perl
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    cpanm --installdeps .
    zef install --deps-only . ; # 在这个检出内运行

> 你可以用任何方式安装 perl 和 node，包括使用版本管理器，只要它们可以从命令行运行即可。

这应该安装了所有依赖，现在你可以克隆本存储库并开始构建：

    git clone https://github.com/Raku/doc.git # 克隆存储库
    cd doc # 进入克隆的存储库
    # 生成 CSS 和 JS，安装高亮模块并构建缓存和页面
    make html

只有在第一次构建缓存时才需要这样做。当源代码发生变化（由你自己完成或从本存储库中拉取）后，运行

    make update-html

将只会重新生成有变化的页面。

文档将在 `html` 子目录中生成。你可以使用任何静态 Web 服务器指向该目录，也可以使用基于 Mojolicious 的开发服务器，运行

    make run

这会在 3000 端口服务文档。

## 生成 EPUB 和/或“单页 HTML”文档

本文档也可以生成 EPUB 格式以及“单页 HTML”格式。请注意，有些功能（如类型部分中继承的方法和类型图，以及代码示例的语法高亮）在这些格式中（暂时）不可用。

你需要安装以下这些：

* Pod::To::BigPage 0.5.2 或更新。
* Pandoc（仅 EPUB）。

在 Ubuntu 或 Debian 上，你可以按照以下说明安装：

    zef install "Pod::To::BigPage:ver<0.5.2+>"
    sudo apt install pandoc     # 如果你想生成 EPUB

现在你已经安装了依赖关系，克隆这个仓库，并生成 EPUB 或“单页 HTML”文档。

    git clone https://github.com/Raku/doc.git # 克隆存储库
    cd doc      # 进入克隆的存储库
    make epub           # 生成 EPUB 格式，
                        # 对于“单页 HTML”格式，使用 `make bigpage`

生成的 EPUB 位于存储库根目录下，名为 `raku.epub`，生成的“单页 HTML”在 `html/raku.html`。

## nginx 配置

生成的文档的最新版本仅包含静态 HTML 页面。所有页面都以 `.html` 结尾；不过大多数内部链接不使用该后缀。大多数 Web 服务器（例如，服务 GitHub 页面的服务器）都会自动为你添加它。裸服务器不会。你需要向配置中添加这些以使其工作：

```
    location / {
        try_files $uri $uri/ $uri.html /404.html;
    }
```

这将为你重定向 URL。可能需要在其他服务器应用中做出同样的配置。

---------

## 我们需要帮助！

Raku 不是小语言，为它做文档并维护这些文档需要付出很大的努力。我们会感激任何形式的帮助。

以下是一些帮助我们的方式：

 * 添加缺少的 class，role，method 或 operator 的文档。
 * 为现有文档添加使用示例。
 * 校对与更正文档。
 * 通过 GitHub 的 issue 系统报告缺少的文档。
 * 在本存储库下执行 `git grep TODO`，并用实际文档替换 TODO。

[Issues 页面](https://github.com/Raku/doc/issues)列出了当前的 issue 和已知缺失的文档。[CONTRIBUTING 文档](../../../CONTRIBUTING.md)简要描述了如何开始贡献文档。

--------

## 注记：

**Q:** 为什么不把文档内嵌到 Rakudo 的核心开发文件中？<br />
**A:** 有以下几点：

  1. 这份文档与 Raku 的特定版本的语言标准相关联，
     而不是跟某个 Raku 的具体实现相绑定。
  2. 处理内嵌的 Pod 的功能还不太稳定，使用单独的文档仓库
     可以避免潜在的运行时错误。
  3. 一个 Raku GitHub 账号下的单独的仓库能吸引更多
     潜在的贡献者。

**Q:** 编写文档时我应该包括父类和 role 的方法吗？<br />
**A:** 不用。HTML 版本的文档自动包括了这些方法。

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

- 设置 `RAKU_DOC_TEST_VERBOSE` 为真值以在运行测试时输出详细信息，这在调试不通过的测试时很有帮助。
- 设置 `RAKU_DOC_TEST_FUDGE` 将在 `xt/examples-compilation.t` 测试中把标记为 `skip-test` 的代码实例当做 TODO 处理。

# 更新

现在暂时是手动更新。这大概需要改进。

# 许可证

本仓库代码使用 Perl 基金会发布的 Artistic License 2.0 协议，你可以在 [LICENSE](../../../LICENSE) 文件中查看完整的内容。

本仓库可能包括使用其他协议的第三方代码，这些文件在它们的首部注明了版权和协议。目前包括：

* 来自 Stack Overflow 的示例； [MIT License](http://creativecommons.org/licenses/MIT) ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/Raku/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* 来自 https://github.com/christianbach/tablesorter 的表格排序插件；
  [MIT License](http://creativecommons.org/licenses/MIT)
