# Perl5到Perl6指南 - 特殊变量

# Perl5和Perl6特殊变量比较

# 概述

本文档旨在全面（希望是）列出说明Perl5特殊变量在Perl6体系中的实现
，必要时对两者差异进行说明。

# 说明

本文档尝试指导读者Perl5特殊变量过度到Perl6相应的用法。
关于完整Perl6特殊变量文档，请参考相关Perl6文档。

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
- `$"`

截止当前，Perl6中并没有列表分隔符的替代变量。L<https://design.perl6.org/S28.html|S28>
设计文档也没有提到这样的变量。
所以不要过多关注它。

Perl6中，可以通过C<$*PROGRAM-NAME>获得到程序的名字。
注意：C<$0>在Perl6中包含了匹配结果的第一个捕获（即捕获变量现在从$0开始而不是$1）

- $PROCESS\_ID
- $PID
- $$

    `$$`被`$*PID`替换。

- $PROGRAM\_NAME
- $0

    Perl6中，可以通过`$*PROGRAM-NAME`获得到程序的名字。

    注意：$0在Perl6中包含了匹配结果的第一个捕获（即捕获变量现在从$0开始而不是$1） 

- $REAL\_GROUP\_ID
- $GID
- $(

Perl 6中组信息通过`$*GROUP`操作，这是[`IntStr`]|(/type/IntStr)类型的对象
因此，可以将其当做字符串或者数字来用。

组id可以通过`+$*GROUP`获取，组名通过`~$*GROUP`。

- $EFFECTIVE\_GROUP\_ID
- $EGID
- $)

    目前，Perl6貌似还不支持获取有效组编号（effective group id）。

- $REAL\_USER\_ID
- $UID
- $<

Perl 6中用户信息通过`$*USER`操作，它是[IntStr](/type/IntStr)类型的对象
因此，可以把它当做字符串或者数字（和`$*GROUP`组信息类似）。

用户id可以通过`+$*USER`获取，用户名通过`~$*USER`。

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
- $]

perl 6在线版本中是`$*PERL`特殊变量，是一个对象。
向前兼容版本通过`$*PERL.version`，他返回信息类似于`v6.c`。Perl解释器完整直接获取
是通过`~$*PERL`，他会返回类似`Perl 6 (6.c)`的信息。

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

这个变量还不明确，可取决于你对“操作系统的名称”如何理解，[S28](https://design.perl6.org/S28.html)
设计文档中有三种不同的建议，对应三种不同的答案。

 关于运行时环境信息现在有三个对象保存其信息：

= `S2<$*KERNEL` 提供运行操作系统内核的信息
= `$*DISTRO` 提供操作系统发行版的信息
= `$*VM` 提供Perl6虚拟机相关的信息

对以上的对象，通常都支持一下方法:

+ `version`提供了组件的版本号
+ `name`提供了组件的简缩名
+ `auth`提供了组件的已知作者

以下面的代码为例，打印以上组件的信息：

```
for $*KERNEL, $*DISTRO, $*VM -> $what {
    say $what.^name;
    say 'version '  ~ $what.version
        ~ ' named ' ~ $what.name
        ~ ' by '    ~ $what.auth;
}

# Kernel
# version 4.10.0.42.generic named linux by unknown
# Distro
# version 17.04.Zesty.Zapus named ubuntu by https://www.ubuntu.com/
# VM
# version 2017.11 named moar by The MoarVM Team
```
以上对象的`name`的`Str`方法将返回简略版本信息。

所有对象的每个方法，都有益于辨别当前运行时实例，更多信息用`.^methods`去内审
上面的信息。

- %SIG

无对应的变量。为了让你的代码在接收到信号后执行，你可以调用[signal](https://docs.perl6.org/routine/signal#(Supply)_sub_signal)
子例程，它会返回一个 `Supply`对象，用来做触发。

```
=for code :lang<perl5>
$SIG{"INT"} = sub { say "bye"; exit }

=for code
signal(SIGINT).tap: { say "bye"; exit }; loop {}
```

或者，如果你用一般性代码来测试具体收到哪个信号:

```
=for code
signal(SIGINT).tap: -> $signal { say "bye with $signal"; exit }; loop {}
```
一个更傻瓜的方法，是在事件驱动的情况下使用信号：
```
=for code
react {
    whenever signal(SIGINT) {
        say "goodbye";
        done
    }
}
```
- $BASETIME
- $^T

    被`$*INIT-INSTAN`取代。不像Perl5，它不是从公元纪元开始的秒数，而是一个`Instant`对象，使用以原子
    秒为单位的小数表示。

- $PERL\_VERSION
- $^V

    和`$]`一样，该变量也被`$*PERL.version`取代。

- ${^WIN32\_SLOPPY\_STAT}

    Perl6不提供类似变量。

- $EXECUTABLE\_NAME
- $^X

   被`$*EXECUTABLE-NAME`取代。注意到Perl 6中还有`$*EXECUTABLE`是个<IO>对象。

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

    `$/`现在包含着[匹配](/type/Match)的对象，所以Perl5中`$&`的行为可以对它字符串化来获得,
例如`~$/`。`$/.Str`也是OK的，但是`~$/`是更通用的形式。

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

    正读取文件的名字现在通过`$*ARGFILES.path`得到。

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

对[IO::Path](https://metacpan.org/pod/IO::Path)或者
[IO::Handle](https://metacpan.org/pod/IO::Handle)类型，
可在递归中使用[lines](https://metacpan.org/pod/lines)属性。

你可以对其调用`.kv`方法，可以取得一个列表和值交叉的列表（每两行递归循环）

```
=begin code

for "foo".IO.lines.kv -> $n, $line {
    say "{$n + 1}: $line"
 }
 # OUTPUT:
 # 1: a
```
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

    由于没有缓冲，目前还没有该选项。目前支持实验性质的`open`。没有全局变量，
TTY处理,默认无缓冲，其他地，对特定的`IO::Handle`,L`open`设置`out-buffer`为零
或者使用`!out-buffer`。

- ${^LAST\_FH}

    未实现。

### 格式相关变量

Perl6中没有内建的格式变量。

## 错误变量

由于Perl 6中错误变量发生了变化，本文档不会分别介变化的细节。

引用Perl 6的[文档](/language/variables#index-entry-%24!)，"$!是错误变量"，就这么多。所有的错误变量
看来都被$!吃了，与Perl6的其它部分一样，它是一个对象，根据用法的不同错误类型
返回不同的结果或者[exceptions](/type/Exception)。

特别地，当处理[exceptions](/type/Exception)时候，`$!`会提供有关抛出异常的信息，
假设程序没有被中止的话：

```
try {
    fail "Boooh";
    CATCH {
        # within the catch block
        # the exception is placed into $_
        say 'within the catch:';
        say $_.^name ~ ' : ' ~ $_.message;
        $_.resume; # do not abort
    }
}

# outside the catch block the exception is placed
# into $!
say 'outside the catch:';
say $!.^name ~ ' : ' ~ $!.message;
```

以上代码输出如下：
```
within the catch:
X::AdHoc : Boooh
outside the catch:
X::AdHoc : Boooh
```
因此，如前所述，`$!`变量保存了异常对象。

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

