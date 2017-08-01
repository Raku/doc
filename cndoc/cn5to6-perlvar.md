# 5to6-perlvar

# Perl5到Perl6指南 - 特殊变量

# 概述

本文档旨在全面（希望是）列出说明Perl5特殊变量在Perl6体系中的实现
，必要时对两者差异进行说明。

# 注意

本文档不会解释Perl6变量的完整用法，而尝试引导perl程序员从Perl5特殊变量
过度到Perl6相应的用法。 关于Perl6特殊变量的全部文档，请参考相关Perl6
文档。

# 特殊变量

## 通用变量

- $ARG
- $\_


    谢天谢地，`$_`还像Perl5中那样是一般默认变量，Perl6中的主要差异是对其通过.
    调用方法。 例如,Perl5中的`say $_`在 Perl 6中可以用`$_.say`表示。 而且，
    由于它是默认变量，我们可以省略它的名字，所以`.say`表达也是正确的。

- @ARG
- @\_

    因为Perl6有了函数签名，你的参数通过签名设置，不再依赖`@_`。 实际上，如果
    你使用函数签名，再使用`@_`也不能覆盖已经存在的签名。

    然而，如果你没有使用函数签名，`@_`将会像Perl5那样包含你传递给函数的实参。 
    同时，对于 `$_`，你可以对其调用对象方法。对`@_`你需要指名调用方法，比如
     `@_.shift`可以工作，`.shift`则会报错。

- $LIST\_SEPARATOR
- $"

    截止当前，Perl6中并没有列表分隔符的替代变量。 设计文档S28也没有提到这样的变量，
    所以对其不要报太大希望。

- $PROCESS\_ID
- $PID
- $$


    `$$`被`$*PID`替换。

- $PROGRAM\_NAME
=item $0


    Perl6中，可以通过`$*PROGRAM-NAME`获得到程序的名字。

    注意：$0在Perl6中包含了匹配结果的第一个捕获（即捕获变量现在从$0开始而不是$1） 

- $REAL\_GROUP\_ID
- $GID
- $(

    现在实际组编号（real group id）是通过`$*GROUP.Numeric`提供，`$*GROUP.Str`
    返回组名，而不是它的编号。

- $EFFECTIVE\_GROUP\_ID
- $EGID
- $)

    目前，Perl6貌似还不支持获取有效组编号（effective group id）。

- $REAL\_USER\_ID
- $UID
- $<

    当前用户编号（real user id）现在通过`$*USER.Numeric`提供,`$*USER.Str`
    返回用户名，而不是它的编号。

- $EFFECTIVE\_USER\_ID
- $EUID
- $>

    目前，Perl6貌似还不支持获取有效用户编号（effective user id）。

- $SUBSCRIPT\_SEPARATOR
- $SUBSEP
- $;

    Perl6中没有下标分隔符变量（subscript separator variable），
    如果你的Perl5代码还在使用它，那代码几乎肯定是非常老了。

- $a
- $b

    $a和$b在Perl6中没有特殊的含义，sort()并不区别对待它们，它们只是一般变量。

    他们的功能被扩展为更加通用的占位符参数，占位符变量用twigil `^`声明。例如，`$^z`。
    它们可以在裸露块或者一个没有显式参数列表的子例程内使用。 参数将会以Unicode顺序赋值
    给相应的占位符变量，也就是说即使变量在块内以`($^q, $^z, $^a)`形式出现，它们被赋值
    的顺序将会是`($^a, $^q,$^z)`。因此：

    想更详细了解占位符变量，请参考[this page](#language-variables-the_-_twigil)

- %ENV

    %ENV已经被$\*ENV取代了，注意这个哈希的键可能不同于Perl5中的。 在写下本文时，
    唯一的不同似乎是`OLDPWD`并没有出现在Perl6的 %\*ENV 中。

- $OLD\_PERL\_VERSION
- $\]

    Perl的版本已经被`$*PERL.version`取代，对于“6.b”版本的beta版,`$*PERL`中
    会包括“Perl6(6.b)”。

- $SYSTEM\_FD\_MAX
- $^F

    虽然设计文档(S28)表明将会变成`$*SYS_FD_MAX`，但现在并没有实现。

- @F

    \[需要深入研究\] 关于这个功能目前有些混乱，设计文档S28表明Perl5中的`@F`被`@_`取代，
    但是目前并不清楚它如何工作。同时，目前还有一些有争议的问题，Perl5到Perl6的迁移文档
    表明rakudo还没有实现选项`-a`和`-F`。

- @INC


    在Perl6中已经去除，请用“use lib”操作需要搜索的模块仓库路径。与@INC最接近的只有$\*REPO
    了，但是因为Perl6有预编译功能，它和@INC的工作方式完全不同。

         # 打印编译模块仓库的列表
         .say for $*REPO.repo-chain;

- %INC


    已去除，因为各个仓库负责记住哪些模块已经加载了。你可以获取所有加载模块（编译单元）的列表，
    比如：

- $INPLACE\_EDIT
- $^I

    S28建议使用$\*INPLACE\_EDIT，但是还未完成。

- $^M

    S28建议使用$\*EMERGENCY\_MEMORY，但是还未完成

- $OSNAME
- $^O

    这个变量还不明确，可取决于你对“操作系统的名称”如何理解，S28有三种不同的建议，
    并且对应的有三种不同的答案。在OS X机器上:

        say $*KERNEL; # 输出 "darwin (14.3.0)"
        say $*DISTRO; # 输出 "macosx (10.10.3)"

    在任何一个变量上使用调用`.version`将会返回版本号,`.name`将会是内核或者发行版的名字。
    这些对象还包含了其它的信息。

    S28还列出了$\*VM（我的rakudo star目前给出的是“moar (2015.5.63.ge.7.a.473.c)”），
    但我不清楚VM跟操作系统是如何关联的。

- %SIG

    \[需要深入研究\]没有等价的变量，S28显示此功能应该Perl6中的事件过滤器(event filters)以及
    异常转换（exception translation）处理。

- $BASETIME
- $^T

    被$\*INITTIME取代。不像Perl5，它不是从公元纪元开始的秒数，而是一个Instant对象，使用以原子
    秒为单位的小数表示。

- $PERL\_VERSION
- $^V

    和`$]`一样，该变量也被`$*PERL.version`取代。

- ${^WIN32\_SLOPPY\_STAT}

    Perl6不提供类似变量。

- $EXECUTABLE\_NAME
- $^X

    被`$*EXECUTABLE-NAME`取代。 注意它在Perl6中是一个`IO`对象，所以使用`~$*EXECUTABLE-NAME`
    将会得到一个接近于Perl5实现的`Str`。

## 正则相关变量

### 性能问题

下面会讲到，`` $` ``, `$&`和`$'`在Perl6中已被删除。主要通过`$/`的变体取代，随着它们的消除，
Perl5中与之相关的性能问题不会再产生。

- $<_digits_> ($1, $2, ...)

    这些在Perl6中保留下的变量和Perl5中的功能一样，唯一区别是它们现在从`$0`开始而不是之前的 `$1`。 
    此外，它们是匹配变量`$/`的下标项的同义词，例如，`$0`等价于`$/[0]`，`$1`等价于`$/[1]`， 
    以此类推。

- $MATCH
- $&

    `$/`现在包含着匹配的对象，所以Perl5中`$&`的行为可以对它字符串化来获得,例如`~$/`。`$/.Str`也
    是OK的，但是`~$/`是更通用的形式。

- ${^MATCH}

    因为前述的性能问题已经不再存在了，所以这个变量在Perl6中不再使用了。

- $PREMATCH
- $\`

    被`$/.prematch`取代。

- ${^PREMATCH}

    因为前述的性能问题已经不再存在了，所以这个变量在Perl6中不再使用了。

- $POSTMATCH
- $'

    被`$/.postmatch`取代。

- ${^POSTMATCH}

    因为有关的性能问题被解决，所以改变量被去除。

- $LAST\_PAREN\_MATCH
- $+

    在Perl6已去除，可以通过使用`$/[*-1].Str`。(`$/[*-1]`将会是匹配对象，
    而不是实际的字符串。想了解更多细节请浏览下面这些文档：

- [\[ \] routine](#routine-5b-20-5d-language_documentation_operators)
- [Whatever](#type-whatever)

    ...还有

- [https://design.perl6.org/S02.html#line\_1126](https://design.perl6.org/S02.html#line_1126)

    ...虽然设计文档并不总是最新的.

- $LAST\_SUBMATCH\_RESULT
- $^N

    S28建议使用`$*MOST_RECENT_CAPTURED_MATCH`，但是现在并没有任何变量与`$^N`
    相符合。

- @LAST\_MATCH\_END
- @+

    和大多数正则表达式相关的变量一样，这个变量的功能或者至少一部分，由Perl6中的变量
    `$/`提供。 或者，在这种情况下，数字变量是它的下标对象的别名，偏移可以使用`.to`
    方法得到，即第一个偏移是`$/[0].to`， 它的同义词是`$0.to`，Perl5提供的`$+[0]`
    由`$/.to`提供。

- %LAST\_PAREN\_MATCH
- %+

    同样，它的功能也被挪到`$/`中，以前的`$+{$match}`，现在为`$/{$match}`。

- @LAST\_MATCH\_START
- @-

    类似于使用`.to`方法取代`@+`,`@-`被`$/`以及它的变种的`.from`方法取代。 第一个
    偏移`$/[0].from`等价于 `$0.from`，Perl5中的`$-[0]`现在用`$/.from`表示。

- %LAST\_MATCH\_START
- %-

    类似于`%+`，`%-{$match}`被`$/{$match}`取代。

- $LAST\_REGEXP\_CODE\_RESULT
- $^R

    无相应的变量。

- ${^RE\_DEBUG\_FLAGS}

    无相应的变量。

- ${^RE\_TRIE\_MAXBUF}

    无相应的变量。

## 文件句柄相关变量

- $ARGV

    正读取文件的名字现在通过`$*ARGFILES.filename`得到。

- @ARGV

    `@*ARGS`包含了当前的命令行参数。.

- ARGV

    被`$*ARGFILES`取代。

- ARGVOUT

    因为`-i`命令行选项现在还没有实现，目前`-i`还没有类似`ARGVOUT`的变量

- $OUTPUT\_FIELD\_SEPARATOR
- $OFS
- $,

    无相应的变量。

- $INPUT\_LINE\_NUMBER
- $NR
- $.

    没有直接可以取代它的变量。

    对[IO::Path](https://metacpan.org/pod/IO::Path)或者[IO::Handle](https://metacpan.org/pod/IO::Handle)类型，可在递归中使用[lines](https://metacpan.org/pod/lines)属性。可以用zip元
    操作符[zip](#language-operators-index-entry-z_-28zip_meta_operator-29)指带
    范围:

        for 1..* Z "foo".IO.lines -> ($ln, $text) {
            say "$ln: $text"
        }
        # OUTPUT:
        # 1: a
        # 2: b
        # 3: c
        # 4: d

    对[IO::CatHandle](https://metacpan.org/pod/IO::CatHandle)类型([$*ARGFILES](/language/variables#index-entry-%24%2AARGFILES)
    是这种)，你可以用[on-switch](/type/IO::CatHandle#method\_on-switch)钩子，
    在句柄变化时候重置行号，并且通过手动增加。

    你也可以用[IO::CatHandle::AutoLines](https://modules.perl6.org/repo/IO::CatHandle::AutoLines)
    和[LN](https://modules.perl6.org/repo/LN)简单地实现这个功能。

- $INPUT\_RECORD\_SEPARATOR
- $RS
- $/

    可以通过文件句柄的`.nl-in`方法获得，例如`$*IN.nl-in`。

- $OUTPUT\_RECORD\_SEPARATOR
- $ORS
- $\\

    通过文件句柄的`.nl-out`方法获得，例如`$*OUT.nl-out`。

- $OUTPUT\_AUTOFLUSH
- $|

    由于没有缓冲，目前还没有该选项。目前支持实验性质的L<open>参数C<:buffer>
目前可以运行。

- ${^LAST\_FH}

    未实现。

### 格式相关变量

Perl6中没有内建的格式变量。

## 错误变量

由于Perl6中错误变量发生了变化，本文档不会分别介变化的细节。

引用Perl6的文档，"$!是错误变量"，就这么多。所有的错误变量
看来都被$!取代，与Perl6的其它部分一样，它可能是一个对象，
根据用法的不同返回不同的结果。 遗憾的是，目前关于它的文档
比较稀少，它可能会如你所想，但我不保证这一点，希望不久的
将来会有更多的信息。

## 编译器相关变量

- $COMPILING
- $^C
- $^D

    目前没有相似的变量。

- ${^ENCODING}

    尽管在Perl5中弃用了，不过可能会有某种相似的`$?ENC`，但是目前还不确定。

- ${^GLOBAL\_PHASE}

    目前没有相似的变量。

- $^H
- %^H
- ${^OPEN}

    Perl6可能有也可能没有与之相似的变量，但是这些是内部变量，你首先应该是避免使用他们—
    这是肯定的，不然Perl6就不会需要你阅读这个文档了。。。

- $PERLDB
- $^P

    Perl6和Perl5的调试器差异较大，所以并没有提供类似的变量。

- ${^TAINT}

    S28申明该变量“待定”，目前还未提供。

- ${^UNICODE}
- ${^UTF8CACHE}
- ${^UTF8LOCALE}

    Unicode相关的变量在Perl6中貌似不存在，但是(可能) 会有类似于`$?ENC`的东西。 
    然而，这还未完全确定。

## 弃用或被移除的变量

不言而喻，因为这些已经从Perl5中删除的变量，没有必要告诉你在Perl6中如何使用它们。

