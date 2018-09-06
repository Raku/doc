# FAQ  perl6最常问到的问题

# 一般性问题

## Rakudo和Perl 6 有啥区别?

正确的说法是， [Rakudo](http://rakudo.org/) 是perl6的的实现。它是目前最完全的实现版本，
当前还存在其他几个实现，将来也许会有更多的实现。Perl 6是语言的定义。
目前来讲，Perl 6和Rakudo名称可以通用。

=head2 Perl6 发布了么?

是的2015年12月25日圣诞节，正式发布了Rakudo 2015.12第一个正式版本。

## 第一个perl版本是6.0.0?

NO，perl 6 第一个正式发布版是v6.c（c代笔Christmas圣诞节）。
接下来发布的版本是带点版本（比如，v6.3.2）,或者大版本的话（v6.d）

运行`perl6 -v`会输出编译器版本号：

    $ perl6 -v

输出”This is Rakudo version 2017.07 built on MoarVM version 2017.07
implementing Perl 6.c“。

## Perl v6.d 大概什么时候发布?

目前还没有确切的日期，尽管[2018 Diwali Day](https://en.wikipedia.org/wiki/Diwali)
看起来是发布同名版本C<Diwali>的相当不错的候选日子。（Diwali Day印度排灯节 2018年为11月07）

绝大部分的`6.d`特性已经实现，并且在Rakudo编译版本中无需特殊的pragmas就可以使用，
并不会和6.c的specification冲突。

最小集的特性和行为，可以通过`use v6.d.PREVIEW`pragma自动加载。剩下的大概3100
新的提交的语言特性行为还需要确定。
 
[perl6book.com](https://perl6book.com) 给出了一些Perl 6 纸质出版图书和电子书可供参考。

在参考第三方文档的时候注意下发布时间，2015年Perl 6正式发布之前的文档可能有些内容已经太旧了。

## perl6开始之旅,我应该安装什么?

Mac用可安装Rakudo Star DMG包，下载地址：
[http://rakudo.org/downloads/star](http://rakudo.org/downloads/star)

Windows用户可以通过Rakudo Star MSI安装. 你必须事先安装Windows Git和Strawberry Perl5
然后用zef包管理软件安装perl6模块。

Linux用户直接下载Rakudo Star L<http://www.perl6.org/downloads/> ，然后编译安装。
Linux和Mac用户也可以通过操作系统发行方或者第三方的二进制包安装,发行方包可能版本会老一点。
我们应该避免使用Rakudo 2015.12之前的版本（非正式版本）。

我们也提供Rakudo Star docker容器的镜像，地址为 [https://hub.docker.com/\_/rakudo-star/](https://hub.docker.com/_/rakudo-star/)

## 对于perl老司机我对 Rakudo的开发感兴趣，有啥好的建议？

最简便的方法是clone[仓库](https://github.com/rakudo/rakudo)并且[编译它](https://github.com/zoffixznet/r#table-of-contents)。

这样我们可以随时得到最新进展的，最小测试的，可能有部分bug的。如果你对
Perl6编译器感兴趣，通过以下链接获得信息：
[Z-Script helper tool](https://github.com/zoffixznet/z)

可以通过
(https://raw.githubusercontent.com/rakudo/rakudo/nom/VERSION) 可以安装月度发布版本。

部分人也可以选择[rakudobrew](https://github.com/tadzik/rakudobrew),这允许我们安装多版本
rakudo，从中选择自己喜欢的版本。

请先浏览文档[rakudobrew](https://github.com/tadzik/rakudobrew#making-new-scripts-available)
这个工具相当于perl5的perlbrew或者python，ruby的相应的多版本管理工具。

无论以上哪一种方法，你都需要从生态系统安装：
[zef](https://modules.perl6.org/dist/zef:github) 和
[p6doc](https://modules.perl6.org/dist/p6doc:github)

生态系统链接如下：
[ecosystem](http://modules.perl6.org/)

## 上哪里找Perl6的文档?

请浏览[官方文档站](https://docs.perl6.org/)(特别是他的["Language"部分](https://docs.perl6.org/language.html)。
还有[资源页](https://perl6.org/resources/))。

有关内容我们总结了一个[资源表](http://htmlpreview.github.io/?https://github.com/perl6/mu/blob/master/docs/Perl6/Cheatsheet/cheatsheet.html)
在参考第三方文档的时候注意下发布时间，2015年Perl 6正式发布之前的文档可能有些内容已经太旧了。

你可以通过[在线perl6频道](https://webchat.freenode.net/?channels=#perl6)寻求帮助
或者通过谷歌[搜索聊天记录](https://www.google.com/search?q=site:irclog.perlgeek.de+inurl:perl6)。

=head2 Perl 6有perldoc不?

是的，就是本文档`p6doc`，目前在Perl 6生态系统。和`Rakudo Star`绑定发布，如果你需要通过月度发布
你可以通过`zef`来安装。

## 我怎么找到有关Perl 6的书籍？

下面是一些Perl 6图书列表，请忽略排列顺序：

-  [Perl&nbsp;6 at a Glance](https://deeptext.media/perl6-at-a-glance/), by Andrew Shitov

-  [Think Perl&nbsp;6: How to Think Like a Computer Scientist](http://greenteapress.com/wp/think-perl-6/), by Laurent Rosenfeld.

-  [Perl&nbsp;6 Fundamentals](https://www.apress.com/us/book/9781484228982), by Moritz Lenz

-  [Parsing with Perl 6 Regexes and Grammars](https://smile.amazon.com/dp/1484232275/), by Moritz Lenz

-  [Learning Perl&nbsp;6](https://www.learningperl6.com/), by Brian D. Foy (In July 2018, this is in a very advanced publication s\
tage)

-  [Metagenomics](https://www.gitbook.com/book/kyclark/metagenomics/details), by Ken Youens-Clark

-  [Learning to program with Perl&nbsp;6: First Steps](https://www.amazon.com/gp/product/B07221XCVL), by JJ Merelo

-  [Perl&nbsp;6 Deep Dive](https://www.packtpub.com/application-development/perl-6-deep-dive"), by Andrew Shitov

## Perl6 specification是什么?

Perl6 specification是指perl6 官方的测试套件.我们称它为[roast](https://github.com/perl6/roast)，
托管在github上。 任何编译测试通过的就会加入到Perl 6 specification。

Roast的主分支对应最新的开发版本，它仍未划入任何的specification。其他分支则对应于不同的specific版本。
例如，"6.c.errata"。 6.c-errata版本是个已经发布了的仅仅行了测试错误（errata）的分支，而master是未发布
版本。随着工作的进展，形成下一个版本。目前的状态不一定是下个版本的规格特性，对于一些新的特性，可能审查
加入下个发布中去。

## 有Perl6相关主题的字汇表么?

是的, 其链接为[glossary](#language-glossary).

## 作为一个perl程序员，我想知道Perl5和Perl6的不同点是啥?

本文档的[Language部分](https://docs.perl6.org/language.html)，有几个`5to6-`的指导教程。
其中最主要的是[5to6-nutshell guide](https://docs.perl6.org/language/5to6-nutshell)。

## 我是一位Ruby程序，我该怎么快速入门perl6?

请浏览'rb-nutshell'文档，链接为[https://docs.perl6.org/language/rb-nutshell](https://docs.perl6.org/language/rb-nutshell)

# 模块

## Perl6有没有CPAN?

有，和Per5的[CPAN](http://cpan.org/)一样,CPAN已经完全支持Perl6。唯一的区别是用[PAUSE](http://pause.perl.org/)
升级模块时候，你必须选择`Perl 6`为目标目录。并且上传的Perl 6 模块需要通过
[modules.perl6.org](https://modules.perl6.org/)浏览，而不是[MetaCPAN](https://metacpan.org/)

[`App::Mi6`工具](https://modules.perl6.org/l/App::Mi6)
模块可用于，简化这个更新流程。最新版本的[`zef`模块安装](https://github.com/ugexe/zef)
自动的检查CPAN上最新版本的模块，以及[GitHub-based ecosystem](https://github.com/perl6/ecosystem/)。

通过CPAN浏览模块功能很快就快实现[modules.perl6.org主页](https://modules.perl6.org/)。(暂时地，可以通过
[json文件](https://github.com/ugexe/Perl6-ecosystems/blob/master/cpan.json)浏览)。

## 我能在Perl6中使用perl模块么?

没问题，通过 [Inline::Perl5](https://github.com/niner/Inline-Perl5/)可以很好的运行大多数的perl5模块，甚至
包括Catalyst和DBI.

## 我能在Perl6中执行c和c++么?

[Nativecall](https://docs.perl6.org/language/nativecall)使这工作变的非常简单.

## Nativecall不能找到libfoo.so，我的系统中只有libfoo.so.1.2!

这是Debian系linux运行Nativecall常见的问题.你需要安装C<libfoo-dev>包，并对缺失的问题设置符号链接。

## 那些传统的UNIX库函数如何调用?

利用Nativecall调用它们非常简单。同时还有一个生态系统模块[POSIX](https://github.com/cspencer/perl6-posix)也可用.

## Rakudo有核心的标准库么?

[Rakudo Star发行包](https://rakudo.perl6.org/downloads/star/)携带很多有用的了
[模块](https://github.com/rakudo/star/tree/master/modules)。
Rakudo编译器发布仅仅包括一些最常用的[基本模块](https://docs.perl6.org/language/modules-core)。
更多的模块在[ecosystem](http://modules.perl6.org/)。

## 有没有类似B::Deparse的模块？我如何处理AST?

使用`--target=optimize`命令行选项来预览程序中的AST。例如：
`perl6 --target=optimize -e 'say "hi"'`。
静态优化后，`optimize`赋给AST处理目标，同时目标 `ast`给予AST前面的步骤。
可通过运行`perl6 --stagestats -e ""`得到所有可用目标的列表。

## 什么是预编译?

当你第一次载入一个模块时，Rakudo会将它编译成字节码，并且将其存储在磁盘里，之后需要再次载入此模块时，Rakudo
会直接读取这些编译好的字节码，从而节省了编译时间，极大地提高运行速度。

## 在模块支持循环依赖关系吗？

不，不支持有循环依赖，如果试图这么做，会报`Circular module loading detected`的错误提示。

很可能你可以使用[roles](/language/objects#Roles)满足的需求。不要用`A.pm6`依赖`B.pm6`
并且`B.pm6`依赖`A.pm6`，你可以用`A-Role.pm6`和`B-Role.pm6`，并且在`A.pm6`和`B.pm6`
类中分别实现这些角色。这样你就可以可以依赖`A-Role.pm6`和`B-Role.pm6`，而不会用循环依赖。

Perl6不支持循环依赖的原因之一是一次解析特性。当我们是使用A，意味着解析B，当使用B时候，解析A
会陷入无限循环。

请注意，Perl 6没有“1个文件对应一个类”的限制，并且是循环的
单个编译单元（例如文件）内的循环依赖关系是可能的，因此另一个可能的解决方案把类放入同一个编译单元。

# 语言特性

## 我怎么样能dump出Perl6的数据结构 (和perl5的Data::Dumper一样有类似的模块么?）

典型地是使用`say`例程，对"gist" 对象的dump使用`gist`方法。更多细节可以通过
`perl`方法，这通常会返回 [`EVAL`](/routine/EVAL)样式的代码表示。

如果使用是[rakudo implementation](https://rakudo.org)，你可以使用其特有的
[non-standard `dd` routine](/programs/01-debugging#Dumper_function_dd)例程来dump
他的输出与`.perl`类似，包含更多多的信息。例如:

       my $foo = %( foo => 'bar' );
       say $foo.perl;   # 输出: «${:foo("bar")}␤»
       say $foo;        # 输出: «{foo => bar}␤»

       # 在rakudo实现中，支持非标准的例程
       dd $foo;         # 输出: «Hash $foo = ${:foo("bar")}␤»

同时perl6生态系统也有几个[专门的模块](https://modules.perl6.org/s/dump)提供更完善
的数据结构dump，包括支持带彩色的输出等。

## Perl6命令行(REPL)下我如何得到输入命令的历史?

请安装[Linenoise](https://github.com/hoelzro/p6-linenoise/) 模块.

对Unix系的操作系统另外还有一个方法就是使用rlwrap。在debian系操作系统可以通过
运行以下命令安装。

    for code :lang<shell>
    sudo apt-get install rlwrap


## 为什么Rakudo编译这样报错?

如果 当前输出是编译时错误，否则是运行时错误。

例如:

    =begin code :skip-test
    say 1/0;   # 试图对0整除

    sub foo( Int $a, Int $b ) {...}
    foo(1)     # ===抱歉!=== 编译时报错 ...
    =end code

## `(Any)` 是啥?

[Any](/type/Any)是最高层的基类，其它绝大多数类都继承它。`Any`类型对象最为变量和参数
未明确指类型时候的[默认值](/type/Attribute#index-entry-trait_is_default_%28Attribute%29-Trait_is_default)
这意味着当你答应一个没有任何值`gist`变量时候会输出`(Any)`。比如使用[`say` routine](/routine/say):

    =begin code
    my $foo;
    say $foo; # 输出: «(Any)␤»
    
    my Int $baz;
    say $baz; # 输出: «(Int)␤»
    
    my $bar = 70;
    say $bar; # 输出: «70␤»
    =end code

为了测试一个变量是否具有定义的值，使用L<DEFINITE>和L<defined>例程。其他几个测试定义与否结构有：
[`with`, `orwith`,以及`without`](/syntax/with%20orwith%20without)语句，
[`<//>`(/routine/$SOLIDUS$SOLIDUS)，`andthen`, `notandthen`,以及`orelse`操作符。还有
[type constraint smileys](/type/Signature#Constraining_Defined_and_Undefined_Values)。

## `so`是什么?

`so`是一个弱优先级操作符，强制为[Bool](#type-bool)。
它和`?` 前缀操作符具有相同语义，类似于`and`和低优先级的`&&`。

实例:

    say so 1|2 == 2;    # 输出: «True␤»

本例中的，比较的结果(是一个 [Junction](#type-junction)),被转化为布尔型打印。

## `:D` 和 `:U` 修饰的意义?

在perl6中，类和其他类型都是对象，并且只能通过其自己类型的类型检查。

例如,如果你定义一个变量

    my Int $x = 42;

然后你不仅可以给他赋值整数（那就是，类实例Int），还有`Int` 类型对象自己。

如果你要排除类型对象，你可以附加`:D` 类型笑脸，他带包已"定义".

    =begin code :skip-test
    my Int:D $x = 42;
    $x = Int;            # 异常退出:
                         # 给$x赋值是类型检查错误;
                         # 期待 Int:D 但是赋值的是Int
    =end code
类似的，C<:U> 限制为未定义的值，也就是说，类型对象。如果你限制既不能为类型对象
也不能为实例，你可以用C<:_>.

## 修饰符 `-->` 有啥作用?

L«-->|/type/Signature#Constraining\_Return\_Types» 为限制返回为一个类型或者一个定义的值.

例子，限制为一个类型:

    =begin code :skip-test
    sub divide-to-int( Int $a, Int $b --> Int ) {
            return ($a / $b).narrow;
    }

    divide-to-int(3, 2)
    #  返回值类型检查失败期待Int但是返回Rat
    =end code

例子，限制为一个定义的返回值:

    sub discard-random-number( --> 42 ) { rand }
    say discard-random-number;
    # 输出: «42␤»

在本例中，由于返回值已经定义，所以最终值被抛弃。

## 我怎么从Junction抽取一个值?


如果你想从[Junction](#type-junction)中，抽取值，你可能做错了，你需要的应该是
[Set](#type-set)。

Junctions表示匹配的意思，不用来做操作的。如果你费用坚持这样做，你可以滥用自动线程：

    sub eigenstates(Mu $j) {
        my @states;
        -> Any $s { @states.push: $s }.($j);
        @states;
    }

    say eigenstates(1|2|3).join(', ');
    # 打印出 1, 2, 3 或者一个置换方法。

## 如果Str为不可改变,  `s///` 如何工作? `$i++` 如何工作?

perl6中，许多基本类型的值都是不可改变的，但是存放他们的变量却不是，C<s///> 操作符是对
变量的操作，操作是会生成一个新的字符串对象。同样，C<$i++>也是工作C<$i>变量上，并不是对
值本身的操作。

知道这点后，我们一般就不会试图去修改一个字符串（比如`'hello' ~~ s/h/H/`）
但是可能不经意间使用 `map`做了这样事情:

      my @foo = <hello world>.map: { s/h/H/ } ; # 抛出异常，
                                               # "Cannot modify an immutable Str (hello)"

      my @bar = <hello world>».subst-mutate: 'h', 'H'; # 抛出异常，
                                                            # "Cannot resolve caller subst-mutate(Str: Str, Str);
                                                            # the following candidates match the type but require
                                                            # mutable arguments: ..."
实际上，要做的不是修改原始值，而是返回一个新的值得操作

     my @foo = <hello world>.map: { S/h/H/ };  # ['Hello','world']
     my @bar = <hello world>».subst: 'h', 'H'; # ['Hello','world']

更多信息，可以浏览 [containers](/language/containers)。

## 数组引用和自动解引用是怎么回事?需要`@`前缀么？

在perl6中，一切皆引用，所以专门谈论引用意义不大。标量变量也能直接包含数组：

    my @a = 1, 2, 3;
    say @a;                 # 输出: «[1 2 3]␤»
    say @a.^name;            # 输出: «(Array)␤»

    my $scalar = @a;
    say $scalar;            # 输出: «[1 2 3]␤»
    say $scalar.^name;       # 输出: «(Array)␤»

最大的不同是插入标量中的数组当为列表上下文的一个值，而数组则会循环迭代。

    =begin code :skip-test
    my @a = 1, 2, 3;
    my $s = @a;

    for @a { ... }          # 循环3次
    for $s { ... }          # 只会循环一次

    my @flat = flat @a, @a;
    say @flat.elems;            # 输出: «6␤»

    my @nested = flat $s, $s;
    say @nested.elems;          # 输出: «2␤»
    =end code

你可以用`@( ... )` 或者 用表达式的`.list`方法，强制展开，或者用`$( ... )`为item上下文
或者通过表达式的C<.item>方法调用。


更多信息请浏览[`Perl 6: Sigils,变量,和容器`文章](https://perl6advent.wordpress.com/2017/12/02/)

## 为什么要用sigil? 不能没有他们么?

有几个原因:

- 便于解释变量为字符串
- 给不同种类的变量和twigils隔离为微命名空间，避免命名冲突
- 可以便捷地区分单复数
- 就像自然语言中的强制性动名词标记，是大脑最直白处理的方式
- 但他也不是强制的，你也可以自定义sigil（如果你介意引起歧义的话）

## Str类型不支持关联索引?

你可能是想混用字符解释器和关键字，比如HTML签

    =begin code :skip-test
    my $foo = "abc";
    say "$foo<html-tag>";
    =end code

perl6认为`$foo`为一个哈希，而C«&lt;html-tag>»会被当成字符哈希键。我们用一个
大括号来加深理解：

    my $foo = "abc";
    say "{$foo}<html-tag>";

## perl6中有协程么? `yield`呢?

perl6没有像python一样的`yield`语句，但是它通过懒列表提供类似地函数式功能。
有两种普遍的方法写协程，返回懒列表

    =begin code :skip-test
    # 第一种方法, gather/take
    my @values = gather while have_data() {
        # do some computations
        take some_data();
        # do more computations
    }

    # 第二种方法, 对一个懒列表使用.map或者类似的方法
    
    my @squares = (1..*).map(-> \x { x² });
    =end code

## 为什么我不能从new方法初始一个私有属性，我该怎么操作?

诸如下面代码：

    class A {
        has $!x;
        method show-x {
            say $!x;
        }
    }
    A.new(x => 5).show-x;

输出不为5。私有属性是_private_，这意味着对外不可见。如果默认构造函数可以初始化他们的话，
他们就可能暴露在公共API.

如果你坚持要这样做，可以增加一个`submethod BUILD`来初始化他们：

    class B {
        has $!x;
        submethod BUILD(:$!x) { }
        method show-x {
            say $!x;
        }
    }
    B.new(x => 5).show-x;

`BUILD`会被默认的构造函数调用（间接地，查看
[Object Construction](#language-objects-object_construction)了解更多），构造函数调用
所有用户传递过来的命名的参数。`:$!x` 是命名为`x`的命名参数，当带 `x`命名参数被调用
时，他的值会被绑定到属性 `$!x`。

如果不这样做。如果名称是公有的，这样定义`$.x`也是没有害处。因为默认外部视图是只读的，
你仍然只能通过内部地 `$!x`操作它。

## `say`, `put` 和 `print` 有啥区别?

最明显地差异是`say`和`put`输出会自带换行符，但是`print`没有。

其他的不同是：`print`和`put`通过调用`Str`方法把所有参数项会当成一个字符串，`say`则
是用 `gist`方法。你也可以为你的创建`gist`方法，用于创建一个相对人性化解释的`Str`。
所以它可以让我们可自由的掉忽略那些不太重要的对象信息，从而了解对象的本质。

或者完全的不同，`$obj.Str` 给出一个字符表达，`$obj.gist`给出一个简单对象总结，适合人
类理解。`$obj.perl`会给出一个perl式的表达，对象会被从新生成。

例如：类型对象，也叫做“未定义值”，字符化结果为一个空串，并且给予警告。而`gist`方法会返回
一个被括号括起来的类型的名称（表示除了类型外没有任何值）。

    my Date $x;     # $x包含一个Date类型对象
    print $x;       # 输出为空和警告
    say $x;         # 输出: «(Date)␤»

如果你想显示对象的debugging形式，最好用`dd`，这样他就会用`$obj.perl`把信息输出到标准错误
而不是标准输出，这样就不会干扰你“正常”的程序输出了。

`say`适合于随意人性化的解释，`dd`适合于随意地debugging输出；`print`和`put`更普遍用于
程序输出。
`put`是`print`和`say`的混合。既像`print`一样能调用对象的`Str`方法,又和`say`一样支持
在输出最后添加换行符。

## `token`和`rule`有何不同 ?

&lt;regex>,`token`和`rule` 都用于引入正则表达式，但是语法上略有不同。

`token`意味着`:ratchet`或者`:r`修饰符，这会防止规则被回溯。

`rule` 表示`:ratchet`和`:sigspace`（简写为`:s`）修饰符，意味着规则不可以回溯，并且将
正则表达式中空白符号作为 C«<.ws>» 调用(不捕获)（例如，可以用来匹配空格，除了两单词之间的空格）。
正则表达式开头和每个可选分支|的开头空白会被忽略。

`regex` 定义一个没有任何暗示修饰符的纯正则.

## `die`和`fail`有啥不同?

`die`抛出一个异常.

`fail` 返回一个`Failure`对象.（如果在词法范围内调用定义过 `use fatal;`），`fail`抛出一个异常
而不是返回)。  

`Failure`是一个非抛出或者“懒”异常。它一个包含了异常的对象，如果你想用 `Failure`作为普通对象
抛出一个异常。或者在sink上下文中忽略它。

`Failure`在`defined`检查中返回`False`，你可以用 `exception`方法抽取异常。

## `Pointer`和`OpaquePointer`有什么不同?

`OpaquePointer`已经过时，被`Pointer`取代了.

## 为什么可以Perl6标识符中使用冒号对?

[标识符中使用冒号对, 作为名称的一部分](https://docs.perl6.org/language/syntax#Identifiers)
对这个问题[Larry Wall教主的回答](https://github.com/perl6/doc/issues/1753#issuecomment-362875676)

    We already had the colon pair mechanism available, so it was a no-brainer to use that to extend any name that needs to be able to quote uniquefying but non-standard characters (or other information with a unique stringification to such characters).

## 我们大家怎么输入Unicode字符呢?

这个取决于操作系统，窗口环境以及编辑器。这个页面[entering Unicode characters](/language/unicode_entry)
给出了常见操作系统和编辑器下的录入方法

# Perl6实现

## 下个版本的Rakudo Star何时发布?

Rakudo Star现在按照季度发布，浏览[rakudo.org About](http://rakudo.org/about/)获得更多信息。

## 那种perl6实现可用的?

目前，开发最完善是Rakudo（支持多虚拟机后端）。曾经的实现包括Niecza (.NET）和 Pugs (Haskell)。
其他客用的实现请浏览[Perl 6 Compilers](https://www.perl6.org/compilers/)

## Rakudo使用什么语言开发的?

我们可以最直接告诉你Rakudo基本上都是用perl6开发的。说的细一点的话，Rakudo使用perl和 NQP ("Not
Quite Perl")混合开发的。NQP是一个轻量地类perl6虚拟机环境。它设计用perl6语法来实现高级别
虚拟机（比如MoarVM and JVM）编译器和类库。

## NQP使用什么语言开发的?


NQP是以下各部分构成 (1) NQP代码, (2) 底层虚拟机使用的各种语言
(3) 一些第三方的 C和库, 以及(4)一些早期编译进程的运行时启动文件 

## perl6是Lisp嘛?

  不能说是，也不能说完全不是 (not (not Nil))

## 我怎么编译我的脚本为单独的可执行文件

可以使用诸如[`App::InstallerMaker::WiX`](https://modules.perl6.org/dist/App::InstallerMaker::WiX)
的工具。它可以让你创建你脚本的编译安装包。截止目前还不支持生成单独的执行程序。

更多信息可以参考github上的讨论：
`https://github.com/MoarVM/MoarVM/issues/875`

# Perl 6 发行版

## 下个版本的 Rakudo Star何时发布?

Rakudo Star发版一般来说按季度发布，发布公告在[rakudo.org](https://rakudo.org/posts)

# Meta问题和文化

## 为什么Perl6名字要带Perl?

关于这个问题教主Larry这样回答的：
[Rule 1](http://perldoc.perl.org/5.12.4/perlhack.html#DESCRIPTION)

… As opposed to some other name that did not imply all the things
that the higher number might indicate on other languages.

… 相比较换个不能说明任何事情的名字，一个高的版本号也可能暗示是一个完全不同语言。

perl社区认为Perl5和Perl6是姊妹语言，他们有很多共同点，解决了许多相同的问题，
但是Perl6并不为了取代Perl 5。事实上，两种语言互相影。

## Perl6怎么样了? 现在可以了么?

尽管编程语言和他们的编译不是一个是与非得二元问题。因为还牵扯到语言本身和实现的
问题，他们会变越来越好用。根据个人需求的不同，perl6及编译器可能是可用或者不可用。
（截止目前，目前99.9的功能都实现了，只是还稍微有点慢 \_\_译者）。

6.c版本（2015圣诞节）是Perl 6首次正式发布版本,发布包括一个验证套件和的编译器。

## 我为什么要学习Perl6? 他有啥重大改进和特性?

perl6实现了通常其他程序中没有的许多伟大的想法。虽然有几种语言提供了这些特性中的部分，
但没有一种语言能支持所有这些： 

- Perl6提供了过程式，面向对象和函数式编程方法.
- 简单一致的语法, 数据结构使用类型前缀标志严格区别.
- 全字符Unicode支持，包括 Annex #29.
- 清晰，更可读的正则表达式;更多的功能，更深层次的可用性.命名正则表达式提高可用性.
- Junctions允许多种可能的测试; 例如, $a == 1|3|42 ( 表示 $a 等于1，3 或者 42).
- 动态变量提供一个可选的词法作用域，对应于全局变量.
- 立足于通过组合性和词法范围来阻止“超距行为“; 例如, imports一直为法范围.
- 易于理解地一致作用域规则和闭包.
- 强大的面向对象，支持类和角色（一切皆对象）。继承，子类型，代码重用.
- 对象和元对象的内省机制 (金字塔一样一层层堆起来).
- 元对象协议允许元组编程，而无需代码生成和解析.
- 子例程和方法签名，方便地位置和命名参数解包。
- 基于数量，类型和可选附加代码的不同签名对特定子例程（方法）实现多路指配.
- 对未知子例程和不可能调度的编译时错误报告。
- 可选地、无额外运行时损耗的渐进类型检测。还支持可选类型注解。
- 基于编译/运行状态內省的高级错误报告，实现更有用，更精确地错误信息。
- 代码快(比如BEGIN/END)允许代码在范围入口和结尾运行, 循环的first/last/next以及其他很多更特殊的语法。
- 高级并发模型,实现隐式、显式多进程处理，超越基本的线程和锁机制。 perl6的并发机制还提供了丰富地（可插拔）工具集。
- 多核越来越普遍，perl6的并发可以用隐式（例如，用>>.方法）和显式（start { code }）。摩尔定律都要失效了，支持多核才是硬道理。
- 结构化语言支持以实现代码的异步执行。
- Supplies允许事件驱动的代码执行 (比如定时器,信号,或者文件系统事件).
- 利用react/whenever/supply关键字方便构建交互，开发事件驱动的应用.
- 尽可能惰性求值,需要时时候才即时出值。例如，懒列表，甚至无限懒列表，比如斐波纳契序列或所有素数。
- 原生数据类型，更快，更底层地处理。
- 非常简单地基于[NativeCall](/language/nativecall)的外部C/C++接口。
- 易用地Perl5(CPAN)和Python模块：[Inline::Perl5](https://modules.perl6.org/dist/Inline::Perl5:cpan:NINE)和[Inline::Python](https://modules.perl6.org/dist/Inline::Python)的调用接口。
- 可同时安装和加载模块的多个版本。
- 便捷的跟新/升级策略，简化系统管理。
- 利用Rats（有理数）简单实现精度无损的数值计算（比如1/3，而不是用浮点数来近似估算）。
- 实现数据和代码解析的可扩展语法(Perl6就是用他解析自己)。
- Perl6是一个支持多变的语言 (定义自己的函数,操作符,特征和数据类型, 修改自定义的解析器)。
- 大量可选的数据类型，加上可自定义的类型。
- 多维度构型或者原生数组，合适的边界检查。
- 当特定条件发生时，可在语法解析期间任何随时执行代码。
- 自定义一个操作符或者增加一个trait特征就像定义子例程一样简单。
- 给任何操作数自动生成超操作符(系统的或者自定义的操作皆可)。
- 运行在多种后端虚拟机。目前有MoarVM和JVM, 正在开发中的JavaScript,还可能更多的。
- JIT热代码路径运行时优化。
- 小系统(例如,树莓派)和大型处理器上的运行。
- 垃圾回收机制: 不及时的销毁，所以没有必要的引用计数，使用phasers的时间行为。
- 属性可以在运行时混合到任何实例化对象。例如, 允许添加范围外数据。
- 具有多路劲分配和自动使用消息生成的MAIN子例程，实现快捷的命令行访问接口。
- 用更少的代码实现更紧凑的程序。命名的霍夫曼编码实现更好的可读性。
- 用简单的递归接口定义懒列表，任何类通过提供单个方法提供最小化支持。
- perl6秉承了perl一贯原则: "Perl是不同的。简而言之，Perl旨在"使容易的工作变得容易，使困难的工作变得可能"。和"条条大道通罗马”。
现在会有更多-Ofun添加进来。

    请浏览 [特性对比矩阵](https://perl6.org/compilers/features) 查看更多实现细节.

## Perl6够快么?

那要取决于你要拿它做什么。Rakudo开发的秉承“工作的更合适，而不更快”的宗旨。一些部分
已经足够快，还有一些还需要改善。

相比较其他动态语言perl6提供了很多JIT特性，还有很大性能提升空间。

下面提供了写粗略的基准脚本，表明如果使用了复杂的模块的任务上Perl6比Perl5要快，与此同时，如果
不涉及这些重模块Perl5则会更快。类似地，和其他语言比较也是这样。

在你的系统运行下面脚本，结果可能会让你大吃一惊。

例子:

    =begin code :skip-test
    # Perl6 版本
    use v6.c;

    class Foo { has $.i is rw };

    for 1..1_000_000 -> $i {
        my $obj = Foo.new;
        $obj.i = $i;
    }

    # Perl5 版本
    package Foo;
    use Moose;

    has i => (is => 'rw');

    __PACKAGE__->meta->make_immutable;

    for my $i (1..1_000_000) {
        my $obj = Foo->new;
        $obj->i($i);
    }

    1;

    # 另一个Perl5版本，相比较Moose/Perl6版本，提供少量仅仅需要特性，更简单程序。
    
    package Foo;
    
    use Mojo::Base -base;

    has 'i';

    for my $i (1..1_000_000) {
        my $obj = Foo->new;
        $obj->i($i);
    }

    1;

   #  你可能希望多性能对比，他可以运行在perl5（with perl -Mbigint)和perl6下

    my ($prev, $current) = (1, 0);

    for (0..100_000) {
        ($prev, $current) = ($current, $prev + $current);
    }
    print $current;

