# p6doc -- Perl6的'perldoc'

该文档的html版本链接为： https://docs.perl6.org/ (英文版).

(如果你通过 github浏览本仓库, 显示可能会部分不协调的,因为使用Perl 6 Pod格式, github用的 Perl 5 POD).

最近发现一个很好的[Perl6 博客-深入浅出系列]( https://perl6.online/contents/)，其内容短小精悍，有意将其中文化：

故建了一个仓库，欢迎有志之士加入一起翻译，可以作为Perl6doc翻译的练手

(https://github.com/bollwarm/Perl6_Inside_OUT)

## 文档中文化进度

[Perl6常见问题](cndoc/cnfaq.md) 

[感谢araraloren的翻译](https://github.com/araraloren/perl6-documents-zh/blob/master/language/5to6-nutshell.adoc#%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F)

[从Perl5到Perl6概述](cndoc/cn5to6-overview.md)

[从Perl5到Perl6初步](cndoc/cn5to6-nutshell.md)

[从Perl5到Perl6指南——语法](cndoc/cn5to6-perlsyn.md)

[从Perl5到Perl6指南——函数](cndoc/cn5to6-perlfunc.md)

[从Perl5到Perl6指南——变量](cndoc/cn5to6-perlvar.md)

[从Perl5到Perl6指南——操作符](cndoc/cn5to6-perlop.md)

[从Ruby到Perl6初步](cndoc/cnrb-nutshell.md)

## 安装


本模块可以用过 Perl6 模块生态体系安装，命令为：

    $ zef install p6doc

通过以上命令安装二进制版本，并且确保安装了正确的执行路径下

下载安装正常后, 运行

    p6doc-index build

创建索引。

## 使用

通过Rakudo安装目录`perl6`可以运行

    $ ./bin/p6doc Str

查看类Str的文档，或者通过

    $ ./bin/p6doc Str.split

查看类Str的方法split的文档。你可以跳过./bin部分，如果你通过panda或者zef安装了此模块的话
你也可执行
   
 p6doc -f slurp

来浏览标准函数的文档的，根据你硬盘的速度和Rakudo版本，这个命令可能要慢一点

    $ p6doc -f slurp

## 生成HTML文档


在你的项目目录通过以下命令安装依赖包

    $ zef --deps-only install .

    panda installdeps .       # panda
    zef --depsonly install .  # zef

如果你用的是[`rakudobrew`](https://github.com/tadzik/rakudobrew), 你也可以通过执行下面的命令能够
升级各个模块。

    $ rakudobrew rehash

同时你也必须安装graphviz依赖,用来生成各种图形，在Debian系统你可以通过以下命令安装

    $ sudo apt-get install graphviz

通过以下命令生成文档的web页面：

    $ make html

页面生成以后，你就可以在本地浏览。你通过以下命名启动app.pl的程序（Mojo程序）

    $ make run

这样你就可以通过浏览器输入网址[http://localhost:3000](http://localhost:3000)浏览文档

注意：你必须安装了 [Mojolicious](https://metacpan.org/pod/Mojolicious)
你还的需要[nodejs](https://nodejs.org)来实现高亮。

## 给予帮助!

Perl6工程 并非一个小项目，项目文档需要投入大量的人力精力，我们感谢你给予任何的帮助。
您可以通过各种方式帮助我们:

 * 给类，角色，方法或者操作符等补充缺失的文档
 * 给已有的文档补充使用实例
 * 校对所有文档
 * 通过github提交问题报告缺失的文档
 * 通过本仓库的 `git grep TODO` ，找出TODO项并将其文档化
 * 将本项目国际化（翻译成各国语言）

[项目问题](https://github.com/perl6/doc/issues) 项目问题页面列出了当前的问题和已知缺失的文档
和 [CONTRIBUTING](CONTRIBUTING.md) 简要说明如何开始提供文档。

## 答疑解惑:

**Q:** 为什么本文当没有嵌入到Perl6语言中?<br>
**A:** 有几个原因:

  1. 本文档的意在独立于给定版本，不与任何给定的perl6版本挂钩。 
  2. POD的解析和嵌如工程还不是很稳定，为了避免对运行时造成影响。
  3. 独立于perl6的Github仓库可以让更多的人参与编辑做出贡献。

**Q:** 我需要从superclasses或者roles中引入方法不<br>
**A:** 不需要. HTML版本已经引入了所有的superclasses和roles方法,我们可以通过`p6doc`脚本学习之。

**Q:** 项目的许可协议是?<br>
**A:** 所有的代码和文档都基于the Artistic License 2.0 发行，查看[LICENSE](LICENSE)全文。


## 版本

> I want p6doc and doc.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> I want p6doc and docs.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> Perl 6 programmer.
>
>    -- moritz


> 我希望p6doc和doc.perl6.org成为人们了解perl6特性的首要资源，不管是语言，内建类型和例程。我希望
> 对每位perl6程序员和需要了解perl6的人都给予最大的帮助
                                                         -- moritz

## 想要的格式:

 *  Perl6实现通过在源代码中嵌入`P<...>`，作为相应的p6doc入口，这将使诸如 `&say.WHY`的文档条目成动态获取！
而，而不需要在 `CORE.setting`资源中复制这些文档或者将其编码到二进制文件中。
    
     例如:

        # In Rakudo's src/core/IO.pm:

# LICENSE

See [LICENSE](LICENSE) file for the details of the license of the code in this repository.

This repository also contains code authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
