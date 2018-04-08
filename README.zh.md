# Perl 6 官方文档 【意译】

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

HTML文档 [https://docs.perl6.org/](https://docs.perl6.org/).
这个是当前推荐的文档.

还有命令行工具 "p6doc"帮助文档.

(如果你通过GitHub浏览本数据仓, 大部分文件显示不正确,
缘由是GitHub 把 Perl 6 Pod识别成 Perl 5 POD).

## 其他语言README

[English README](README.md)

## 安装 p6doc

本模块可通过Perl 6模块生态系统提供. 使用命令

    zef install p6doc

安装可执行文件, 让它在你的可执行行路径中可用.

## 使用 p6doc

针对 Rakudo `perl6` 执行本地路径, 尝试命令

    ./bin/p6doc Str

查看类`Str`文档, 或者

    ./bin/p6doc Str.split

查看类`Str`中`split`方法. 你可以跳过`./bin` 部分如果你已经通过`zef`安装了它 . 你也可以使用

    p6doc -f slurp

浏览标准函数的文档可能需要一段时间, 取决于你磁盘的速度和rakudo版本.

-------

## 编译 HTML 文档

在checkout目录运行如下命令安装依赖:

    zef --deps-only install .

如果用 [`rakudobrew`](https://github.com/tadzik/rakudobrew), 也可以运行下面命令,
升级已安装执行文件:

    rakudobrew rehash

此外 Perl 6 的依赖, 需要安装 `graphviz` , 在 Debian 可执行下面命令

    sudo apt-get install graphviz

编译web文档, 运行命令

    $ make html

注意还需要安装 [nodejs](https://nodejs.org)
生成 HTML 内容使用上面命令, 特别是`node` 命令在你滴环境变量 `PATH`可用.

页面生成后, 可本地查看通过运行 `app.pl` 程序:

    $ make run

可通过浏览器[http://localhost:3000](http://localhost:3000)浏览文档示例.

需要安装 [Mojolicious](https://metacpan.org/pod/Mojolicious)
与 [nodejs](https://nodejs.org) 来展示高亮效果.
有可能需要一些附加模块; 通过下面安装它们

    $ cpanm --installdeps .

---------

## 希望得到帮助!

Perl 6不是一种小语言,记录它需要付出很大的努力.任何帮助都值得赞赏.

一些帮助我们的方式:

 * 添加缺少的类, 角色, 方法 或运算符文档
 * 针对现有文档添加使用示例
 * 校对与更正文档
 * 通过github开放问题告诉我们缺少的文档.
 * 在本数据仓执行`git grep TODO`, 用实际文档替换TODO.

[Issues page](https://github.com/perl6/doc/issues)列出了当前的问题，
已知缺失部分的文档, [CONTRIBUTING](CONTRIBUTING.md)简要说明如何开始贡献文档.

--------

## Some notes:

**Q:** Why aren't you embedding the docs in the CORE sources?<br>
**A:** Several reasons:

  1. This documentation is intended to be universal with
     respect to a given version of the specification,
     and not necessarily tied to any specific Perl 6
     implementation.
  2. Implementations' handling of embedded POD is still
     a bit uneven; this avoids potential runtime impacts.
  3. A separate repo in the perl6 Github account invites
     more potential contributors and editors.

**Q:** Should I include methods from superclasses or roles<br>
**A:** No. The HTML version already includes methods from superclasses and
       roles, and the `p6doc` script will be taught about those as well.

**Q:** Which license is this stuff under?<br>
**A:** Both code and documentation are available under the Artistic License 2.0
       as published by The Perl Foundation. See the [LICENSE](LICENSE) file for the full
       text.

--------

## Vision

> I want p6doc and doc.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Perl 6 programmer.
>
>    -- moritz

--------

## Wishlist stuff:

 *  Perl 6 implementations could embed `P<...>` tags in their source
    code that would then inline the corresponding entry from `p6doc`.
    This would enable things like `&say.WHY` to (dynamically!)
    retrieve the documentation string from `p6doc`, without having
    to duplicate the documentation in the `CORE.setting` sources
    or to encode the documentation into the binaries.

    Example:

        # In Rakudo's src/core/IO.pm:

        #= P<p6doc/&print>
        sub print(|$) { ... }

        #= P<p6doc/&say>
        sub say(|$) { ... }

        #= P<p6doc/&note>
        sub note(|$) { ... }

# ENV VARS

- `P6_DOC_TEST_VERBOSE` to a true value to display verbose messages during test suite run.
Helpful when debugging failing test suite.
- `P6_DOC_TEST_FUDGE` fudges `skip-test` code examples as TODO in `xt/examples-compilation.t` test

# LICENSE

See [LICENSE](LICENSE) file for the details of the license of the code in this repository.

This repository also contains code authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
