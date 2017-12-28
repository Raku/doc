# 5to6-perlfunc

# Perl5到Perl6函数速查

# 概述

本文档是尽最大可能列出Perl5内建函数，在perl6中替代函数以及可能的用法上的差异。

# 备注

此文档不会具体的解释函数，仅尝试引导你从Perl5的 perlfunc文档过渡到他们在Per6的
对应的功能和提法， 如果想了解Perl6函数的完整文档，请参阅 Perl6文档。

通用的理念是：Perl6比Perl5 更面向对象，在Perl6中，一切皆对象，然而如果你不想这么做的话，
perl6足够灵活到可以让你避免使用面向对象风格。 意思就是，不管怎样，有很多函数调用由 
`function(@args)`风格变为了现在的 `@args.function`风格（很少情况下，仅有方法调用），
这在下面的正文中会很显然，不过这可以让更快的进入意境。

还有，除非另有说明，“function”一词意思就是一个`function(@args)`风格的函数，同时“method”
一词代表一个`@args.function`风格的函数。

# Perl函数列表

## 文件测试

- -X FILEHANDLE
- -X EXPR
- -X DIRHANDLE
- -X

    对于文件测试 Perl 6给了你两种选择，你可以使用智能匹配(`~~`)或者调用对应的方法。
    在Perl6中进行文件测试，你不必像传统方式一样需要打开一个文件句柄（当然你仍然可以
    使用文件句柄）， 简单的向文件名字后面追加`.IO`即可。 下面是使用智能匹配检测一个
    文件是否可读的示例：

        '/path/to/file'.IO ~~ :r

    你仍然可以利用一个已经打开的文件句柄完成测试，现在我们有一个文件句柄`$fh`，用这种
    方法实现同样功能的列子为：

        $fh.r

    大多数之前的文件测试都有和智能匹配一起使用的带冒号的版本：

        :e 是否存在
        :d 目录
        :f 文件
        :l 符号连接
        :r 可读
        :w 可写
        :x 可执行
        :s 大小
        :z 零大小

    所有这些测试也都可以作为方法使用（不加冒号）。

    下面的三种测试_只有_方法调用版本：

        $fh.modified; # -M $fh
        $fh.accessed; # -A $fh
        $fh.changed;  # -C $fh

    Perl5中其它的文件测试操作在还未在 Perl6中实现。
    详细文件测试的文档请访问[File test operators](#type-io-path-file_test_operators)。

    [io](#language-io).有更多的关于读写文件的信息，还有下面的`open()`小节对你也会有帮助。

## abs

- abs VALUE

    作为函数(`abs($x)`)，或者类方法。需要注意的是，方法绑定的优先级大于-（负号），所以，
    `-15.abs`将作为 `-(15.abs)`求值， 结果是-15，对这种情况，你需要做类似于`(-15).abs`的处理。

    在缺少一个值的时候，abs可以工作在`$_`上面，但是不是一个函数，而是一个方法，你需要用`.abs`
    替换比较简单的`abs`来调用它。

## accept

- accept NEWSOCKET, GENERICSOCKET

    `accept` 是一个在服务器端调用的方法，例如`$server.accept()`，该方法不再是返回一个封装的地址，
    而是返回一个socket，最通常常用于某些类型IO::Socket对象。

## alarm

- alarm SECONDS

    \[需要进一步研究\]已经没有`alarm()`了，有建议用新的并发特性取代它，比如`Promise.in`，但是为了
    真正模拟它可能需要进一步研究。

## atan2

- atan2 Y, X

    即可以作为函数又可以作为方法使用,下面的两种方式是等价的

        atan2(100);
        100.atan2;

## bind

- bind SOCKET, NAME

    \[需要进一步研究\]在Perl6没有和socket相关函数`bind()`类似的函数，据估计，socket绑定在创建
    一个新的socket对象的时候完成。

## binmode

- binmode FILEHANDLE

    作为替代方法，你可以在打开文件的时候使用`:bin`文件模式，比如`my $fh = open("path/to/file", :bin);`。

## bless

- bless REF, CLASSNAME

    因为Perl6中类的创建发生了改变，可能会比 Perl5中更少被用到，现在它是一个方法也是一个函数。 Perl6文档中说，
    它可以创建一个和invocant类型一样的新的对象，使用命名参数初始化属性，然后返回 创建的对象。如果你正在移植
    一个Perl5的模块到Perl6，很有可能你想使用`new`来创建对象，而不是`bless`，虽然有些情况下，后者也还很有用。

## break

- break

    在Perl6中被移除，如果你想跳出`given`结构块，你可能需要了解下`proceed`和`succeed`，具体地址为:
    [here](#language-control-proceed)。

## caller

- caller EXPR

    在Perl6中有两种不同的方式获取调用者的信息，基础功能现在通过[callframe](https://metacpan.org/pod/callframe)提供。 然而，Perl6不仅为子例程，
    而且为一般的块结构调用帧，所以可能存在多个帧可供查看。下面的代码可以获取 `caller`可以返回的基本信息：

        my $frame   = callframe(0); # 或者直接callframe()
        my ($subroutine, $package);
        if $frame.code ~~ Routine {
            $subroutine = $frame.code.name;
            $package    = $frame.code.package;
        }
        my $file    = $frame.file;
        my $line    = $frame.line;

    Perl5中的`caller`返回的其它其他的细节在Perl6中都没有意义。
    
   你还可以通过使用动态变量获取当前的帧或者例程帧的一些信息,这些动态变量包括：

   [&?ROUTINE](/language/variables#Compile-time_variables)，
   [&?BLOCK](/language/variables#Compile-time_variables),
   [$?PACKAGE](/language/variables#Compile-time_variables),
   [$?FILE](/language/variables#Compile-time_variables),和
   [$?LINE](/language/variables#Compile-time_variables)

在许多情况下，[Backtrace](https://docs.perl6.org/type/Backtrace)是获取调用栈信息
的更好的方法。

## chdir

- chdir EXPR

    和perl5一样。

## chmod

- chmod LIST

    和Perl5中一样的函数，只是8进制数的表示有些不大一样（是`0o755`而不是`0755`），你也能把它作为方法使用，
    比如`$fh.chmod(0o755)`。

## chomp

- chomp VARIABLE

    `chomp`的行为和Perl5中有些不同，它对目标不产生影响，而是返回一个去除逻辑换行符的新的目标,例如
    `$x = "howdy\n";$y = chomp($x);`结果`$x`为“howdy\\n”以及`$y`为“howdy”。同样也可以作为方法使用，
    例如`$y = $x.chomp`。和其他很多方法一样，它也可以以修改并赋值模式运行，例如`$x.=chomp`，结果`$x`
    的值为"howdy"。

## chop

- chop VARIABLE

    和`chomp`一样，在Perl6中，它返回被截取以后的字符串，而不是直接截取替换，比如`$x = "howdy";$y = chop($x);`，
    结果是`$x`为“howdy”以及`$y`为“howd”。同样可以做为方法使用：`$y = $x.chop`。

## chown

- chown LIST

    `chown`已经去除.

## chr

- chr NUMBER

    和Perl5的相似，把目标强制转换成整数，然后返回其Unicode码指向的字符， 可以作为函数或者方法使用：

        chr(65); # "A"
        65.chr;  # "A"

## chroot

- chroot FILENAME

    似乎在Perl6中不存在。

## close

- close FILEHANDLE

    和Perl5中一样，关闭一个文件句柄，返回一个布尔值。`close $fh`和 `$fh.close`都是可以的。

## closedir

- closedir DIRHANDLE

    Perl6中未提供`closedir`函数。他的功能可以用IO::Dir的一个方法代替。

## connect

- connect SOCKET, NAME

    使用[connect](#routine-connect)用来从[IO::Socket::Async](#type-io-socket-async)去同步socket
    或者创建一个同步的socket[IO::Socket::INET](#type-io-socket-inet)。

## continue

- continue BLOCK
- continue

    perl6中新建`NEXT`块取代`continue`块，和perl5`continue;` 语法更像的是`proceed`/`succeed`用法。

## cos

- cos EXPR

    和Perl5中一样,同时也能作为对象方法使用,例如`(1/60000).cos`。

## crypt

- crypt PLAINTEXT, SALT

    Perl6还未实现。

## dbm functions

- dbmclose HASH
- dbmopen HASH, DBNAME, MASK

    这些函数在Perl5中很大程度上被取代了，不太可能出现在Perl6中（尽管Perl6的数据库
    实现还未成熟的）。

## defined

- defined EXPR

    它可能能以你期望的那样工作，但是从技术上讲对于类型对象它返回`False`，其它情况返回`True`。
    它使得当你没有为一个东西赋值时`$num.perl`会返回`Any`或者当你赋值了返回当前值更有意义。 
    当然，你也可以作为一个方法使用它:`$num.defined`。

## delete

- delete EXPR

    Perl6通过使用`:delete`副词的新副词语法取代了它，例如`my $deleted_value = %hash{$key}:delete;`和
    `my $deleted_value = @array[$i]:delete;`。

## die

- die LIST

    和Perl5版本功能相似，但是Perl6的异常机制比Perl5更强大，更灵活，参见[exceptions](#language-exceptions)。
    如果你想忽略堆栈踪迹和位置，就像Perl5中的`die "...\n"` ，可用：

        note "...";
        exit 1;

## do

- do BLOCK

    和Perl5版本的功能相似，不过注意`do`和BLOCK之间必须留空白。

- do EXPR

    被Perl6的`EVALFILE`取代了。

## dump

- dump LABEL

    根据S29描述,`dump`已被废弃。

## each

- each HASH

    没有完全等效的函数，不过你可以使用`%hash.kv`，它会返回一个键值列表，比如： 
    `for %hash.kv -> $k, $v { say "$k: $v" }`

    顺便，我们这里的`->`称为箭头语句块，虽然文档中有很多这种例子，但是并没有
    一个关于它是如何运作的清晰的解释。 
    [https://design.perl6.org/S04.html#The\_for\_statement](https://design.perl6.org/S04.html#The_for_statement)对你可能有些帮助，还有设计文档的
    [https://design.perl6.org/S06.html#%22Pointy\_blocks%22](https://design.perl6.org/S06.html#%22Pointy_blocks%22)， 另外还有[https://en.wikibooks.org/wiki/Perl\_6\_Programming/Blocks\_and\_Closures#Pointy\_Blocks](https://en.wikibooks.org/wiki/Perl_6_Programming/Blocks_and_Closures#Pointy_Blocks)

## eof

- eof FILEHANDLE

    在Perl6中没有eof函数了，只能作为一个对象方法，例如`$filehandle.eof`，如果文件已经到达末尾
    它会返回`True`。 

## eval

- eval EXPR
- eval EXPR

    被[EVAL](#routine-eval)代替。注意`EVAL` 不做任何[异常处理](#language-exceptions)!

## evalbytes

- evalbytes EXPR

    Perl6中不存在。

## exec

- exec LIST

    Perl6中没有提供跟Perl5中的`exec`类似的函数，`shell`和`run`类似于Perl5中的`system`，
    但是`exec`执行系统命令不返回结果的特性，需要用`shell($command);exit();`或者
    `exit shell($command);`来实现。

    但是这些解决方法都不能实现用一个新程序来_接替__replacing_你当前perl进程的行为。
    注意到，他们不可能作为长时间运行的守护程序，定时的通过重新执行exec来反馈他们的状态
    或者强制执行系统清理。他们也不能实现`exec`给操作系统返回错误值的功能

    如果你想用`exec`的这些功能，你可以通过`NativeCall`调用 `exec*`系函数。请查看系统的
    `exec`函数使用手册。（或者其他类似的系统调用函数，比如`execl`, `execv`, `execvp`,
    或者`execvpe`）。（注意，这些函数通常不同的系统之间表现也是不同的）。

## exists

- exists EXPR

    Perl6不提供这样的函数,用后缀副词代替:

        %hash{$key}:exists;
        @array[$i]:exists;

## exit

- exit EXPR

    和perl5几乎一样。

## exp

- exp EXPR

    和perl5一样,也能作为对象方法：`5.exp`

## fc

- fc EXPR

    和perl5几乎一样。

## fcntl

- fcntl FILEHANDLE, FUNCTION, SCALAR

    Perl6未提供。

## \_\_FILE\_\_

- \_\_FILE\_\_

    用`$?FILE`代替。

## fileno

- fileno FILEHANDLE

    S32说明作为对象方法，目前还未实现。

## flock

- flock FILEHANDLE, OPERATION

    目前还未实现。

## fork

- fork

    未作为内建函数，可以通过`NativeCall`接口使用。例如：`use NativeCall; sub fork returns int32 is
    native { * }; say fork;`。

## formats

- format
- formline PICTURE, LIST

    Perl6中没有内建的formats.

## getc

- getc FILEHANDLE

    和Perl5一样从输入流中读取一个字符，也可以作为一个对象方法调用：`$filehandle.getc`。

## getlogin

- getlogin

    S32中在列，目前还未实现。

## getpeername

- getpeername SOCKET

    S29中在列, 但是对其实现还未明确。

## getpgrp

- getpgrp PID

    还未实现。

## getpriority

- getpriority WHICH, WHO

    还未实现。

## get and set functions

- getpwnam NAME
- getgrnam NAME
- gethostbyname NAME
- getnetbyname NAME
- getprotobyname NAME
- getpwuid UID
- getgrgid GID
- getservbyname NAME, PROTO
- gethostbyaddr ADDR, ADDRTYPE
- getnetbyaddr ADDR, ADDRTYPE
- getprotobynumber NUMBER
- getservbyport PORT, PROTO
- getpwent
- getgrent
- gethostent
- getnetent
- getprotoent
- getservent
- setpwent
- setgrent
- sethostent STAYOPEN
- setnetent STAYOPEN
- setprotoent STAYOPEN
- setservent STAYOPEN
- endpwent
- endgrent
- endhostent
- endnetent
- endprotoent
- endservent

    \[需要进一步研究\]似乎这个列表中的函数可以被一些Roles比如 User,Group等处理。

## getsock\*

- getsockname SOCKET
- getsockopt SOCKET, LEVEL, OPTNAME

    \[需要进一步研究\]现在看起来可能被实现成某种IO::Socket对象，但是具体细节不详。

## glob

- glob EXPR

    在S32中有实例，但是似乎没有实现。

## gmtime

- gmtime EXPR

    `localtime`, `gmtime`的各种功能似乎在DateTime对象里，为获取一个UTC格式的当前时间的`DateTime`对象，
    可以用： `my $gmtime = DateTime.now.utc`。

## goto

- goto LABEL
- goto EXPR
- goto &NAME

   goto还未实现。

## grep

- grep BLOCK LIST
- grep EXPR, LIST

    在Perl6依然存在，不过需要注意的是代码块之后需要一个逗号，例如
     `@foo = grep { $_ = "bars" }, @baz`。
    也可以作为对象方法使用： `@foo = @bar.grep(/^f/)`。

## hex

- hex EXPR

    用副词形式`:16`取代了，例如：`:16("aF")`返回175。

    另外，可以使用 `.base`方法得到同样的结果：`0xaF.base(10)`。

    碰巧 `.Str`默认显示的是10进制，所以如果你`say 0xaF`，它依然会打印175，
    但这样不够直观，不是最好的方式。

## import

- import LIST

    首先在Perl5中它一直不是内建的函数，在Perl6中，典型地，函数可以声明为导出或者不导出，
    所有可导出的函数可一起导出，同时，有选择的导出也行，但是这超出了本文档的范围，详见
    [this section](#language-5to6-nutshell-importing_specific_functions_from_a_module)。

## index

- index STR, SUBSTR, POSITION

    和perl5表现一样，同时可作为对象方法：
    `"howdy!".index("how"); # 0`

## int

- int EXPR

    在Perl6里面它是和Perl5中一样的truncate（截断）函数（也可作为对象方法），你直接使用它作为
    Perl5代码的移植版本，但是在Perl6中，你可以对一个数字方便地直接调用`int`方法。 
    `3.9.Int; # 3`和`3.9.truncate`等效。

## ioctl

- ioctl FILEHANDLE, FUNCTION, SCALAR

    目前还未实现。

## join

- join EXPR, LIST

    和Perl5中表现一致，也可以作为对象方法：`@x.join(",")`

## keys

- keys HASH

    和Perl5中表现一致，也可以作为对象方法：`%hash.keys`

## kill

- kill SIGNAL, LIST
- kill SIGNAL

    无预定义的核心对应项存在，一种不是方便的方法是通过调用[NativeCall](#language-nativecall)
    接口：

        use NativeCall;
        sub kill(int32, int32) is native {*};
        kill $*PID, 9; # OUTPUT: «Killed␤»

    傻进程可以通过创建Proc::ASync，然后使用L«`Proc::Async.kill` method|/type/Proc::Async#method\_kill»。

## last

- last LABEL
- last EXPR
- last

    和perl5一样.

## lc

- lc EXPR

    和Perl5中表现一致，也可以作为对象方法：`"UGH".lc`

## lcfirst

- lcfirst EXPR

    未定义。

## length

- length EXPR

    被`chars`取代，通常作为一个方法使用(`$string.chars`),也能作为函数用。

## \_\_LINE\_\_

- \_\_LINE\_\_

    被`$?LINE`取代。

## link

- link OLDFILE, NEWFILE

    See [link](https://metacpan.org/pod/link)

## listen

- listen SOCKET, QUEUESIZE

    文档中没有明确的描述，似乎`listen`是IO::Socket对象的一个方法。

## local

- local EXPR

    Perl6中相应的是`temp`。然而他不像`local`，指定的变量的值，不会马上重置：
    它保持他的原始值，直到赋值给它。

## localtime

- localtime EXPR

    `localtime`的大部分的功能都可以在`DateTime`中找到，`localtime`特定的部分如下：

    注意在Perl6中的范围并不是0开始的，上面的例子已经显示这点。

    好像没有一种明确的方式可以得到Perl5中的`$isdst`对应的值，Perl5中提供的`scalar(localtime)`
    已经不可用了,`$d.Str`会返回类似“2015-06-29T12:49:31-04:00”的字串。

## lock

- lock THING

    Perl6中,是Lock类的一个方法。

## log

- log EXPR

    Perl6中也可用，也可以作为对象方法：例如`log(2)`和`2.log`等效。

## lstat

- lstat FILEHANDLE
- lstat EXPR
- lstat DIRHANDLE
- lstat

    可能在Perl6中的`IO`类的某处实现了，具体目前还不是很清楚。

## m//

- m//

    正则表达式在Perl6中有点不一样，但是匹配操作依然存在，如果你想重写Perl5的代码，
    最重要的区别就是`=~`被智能匹配运算符`~~`取代，类似地，`!~`被`!~~`取代，
    正则操作的设置都是副词并且复杂，具体请浏览[Adverbs](#language-regexes-adverbs)。

## map

- map BLOCK LIST
- map EXPR, LIST

    作为一个函数,和Perl5中不同的地方是，其代码块后面必须跟着一个逗号，同时也能作为一个方法使用： 
    `@new = @old.map: { $_ * 2 }` 。

## mkdir

- mkdir FILENAME, MASK
- mkdir FILENAME

    和Perl5一样

- mkdir

    不带参数的形式(隐式$\_为变量`$_`)Perl6中不允许。

## msg\*

- msgctl ID, CMD, ARG
- msgget KEY, FLAGS
- msgrcv ID, VAR, SIZE, TYPE, FLAGS
- msgsnd ID, MSG, FLAGS

    无内建地支持，可能会出现在某些扩展模块中。

## my

- my VARLIST
- my TYPE VARLIST
- my VARLIST : ATTRS
- my TYPE VARLIST : ATTRS

    和Perl5一样。

## next

- next LABEL
- next EXPR
- next

    Perl中无差异。

## no

- no MODULE VERSION
- no MODULE LIST
- no MODULE
- no VERSION

    在Perl6中，它是类似于`strict`一样的编译指示，但是作用对象不是模块，
    并不清楚它是否有版本功能， 因为目前有些东西有争议，我觉得没有。

## oct

- oct

    被副词格式`:8`取代,例如：`:8("100")`返回 64。

    如果你想处理`0x`, `0o`,或者`0b`开头的字符串，你可以使用C«prefix:<+>»操作符。

## open

- open FILEHANDLE, EXPR
- open FILEHANDLE, MODE, EXPR
- open FILEHANDLE, MODE, EXPR, LIST
- open FILEHANDLE, MODE, REFERENCE
- open FILEHANDLE

    相对于Perl5最明显的改变就是文件模式的语法，以只读方式打开一个文件，你需要使用`open("file", :r)`，
    以只写、读写以及追加的方式打开需要分别使用 `:w`, `:rw`和`:a`，另外还有
    一些关于编码以及如何处理换行的选项，具体参见[here](#routine-open)。

## opendir

- opendir DIRHANDLE, EXPR

    无这个函数。可以用 L«`&dir`/`IO::Path.dir`|/routine/dir» 代替。

## ord

- ord EXPR

    和Perl5中一样，也支持对象方法：`"howdy!".ord; # 104`。

## our

- our VARLIST
- our TYPE VARLIST
- our VARLIST : ATTRS
- our TYPE VARLIST : ATTRS

    在Perl6表现一致。

## pack

- pack TEMPLATE, LIST

    在Perl6中可用，模板的选项比Perl5更严格，详细文档可以参考[unpack](#routine-unpack)

## package

- package NAMESPACE
- package NAMESPACE VERSION
- package NAMESPACE BLOCK
- package NAMESPACE VERSION BLOCK

    S10表明`package`在Perl6中是可用的，但是只适用于代码块，例如:`package Foo { ... }`表示
    后面的代码块是属于package Foo的，当使用`package Foo;`声明格式时有一种特殊情况，当它作为
    文件的第一条语句时表明文件中接下来的代码都是Perl5的代码，但是它的有效性目前尚不清楚。
    实际上，因为模块和类的声明需要不同的关键字（比如`class`），你基本上不可能会在Perl6中直接
    使用`package`。

## \_\_PACKAGE\_\_

- \_\_PACKAGE\_\_

    被`$?PACKAGE`取代。

## pipe

- pipe READHANDLE, WRITEHANDLE

    根据你的需求的不同，进程（或者[Concurrency tutorial](#language-concurrency)）内部数据交互的话
    请浏览L«`Channel`|/type/Channel»。进程之间数据交互用 L«`Proc`|/type/Proc»。 

## pop

- pop ARRAY

    Perl6中可用，也可用作对象方法，例如： `my $x = pop@a;` 和`my $x = @a.pop;`都是可以的。

## pos

- pos SCALAR

    Perl6中已去除，和其功能最相近是:`:c`副词，如果`$/`设置过，它默认是`$/.to`，否则为 `0`。
    更多的信息请浏览[Continue](#language-regexes-continue)。

## print

- print FILEHANDLE LIST
- print FILEHANDLE
- print LIST
- print

    `print`在Perl6中可以函数形式使用，默认输出到标准输出。作为函数使用print并且使用文件句柄输出时，
    可以用方法调用。比如，`$fh.print("howdy!")`。

## printf

- printf FORMAT, LIST
- printf

    Perl6中其功能类似。详情请看[sprintf](https://docs.perl6.org/type/Str#sub_sprintf)。如果输出到文件
    句柄，使用对该句柄的L«`.printf`|/type/printf»方法调用。

## prototype

- prototype FUNCTION

    Perl6中已去除，和其功能最相近是`.signature`，例如：`say &sprintf.signature`，结果是"(Cool $format, \*@args)"。

## push

- push ARRAY, LIST

    在Perl6中依然可用，也能以方法调用形式使用：`@a.push("foo");`，_注意:_数组内插行为和Perl5中不同：
    `@b.push: @a`:将会把`@a`作为单个元素压入到`@b`中，更多请参考[append method](#type-array-method_append)。

## quoting

- q/STRING/
- qq/STRING/
- qw/STRING/
- qx/STRING/

    这些用法过渡到Perl6的一些建议：

         q/.../ # 依然与使用单引号相同 
        qq/.../ # 依然与使用双引号相同
        qw/.../ # 更类似于Perl6中的C<< <...> >>

    同时也增加了一些引号构造或类似的用法。详细见[quoting](#language-quoting)。

- qr/STRING/
被`rx/.../`取代。
- quotemeta EXPR

    没有直接的等价用法，例如，没有直接返回字符串中所有ASCII非单词转义字符的操作。
    然而，在正则表达式中使用`$foo`会被视为字符串字面的字符，使用`<$foo>`
    会将`$foo`的内容作为正则代码直接内插到表达式中，注意尖括号和它在正则表达式
    外部的行为有点不同。更多详情，浏览[https://design.perl6.org/S05.html#Extensible\_metasyntax\_(%3C...%3E)](https://design.perl6.org/S05.html#Extensible_metasyntax_\(%3C...%3E\))

## rand

- rand EXPR

    `rand`和Perl5中功能一样，但是现在你不需要给它提供参数了。把它作为一个方法使用
    就会是这样的效果，例如，Perl5中的`rand(100)`等价于Perl6中的`100.rand`。 另外，
    你还可以通过`(^100).pick`获取一个随机的整数，为什么要这么做？，可以参考[^ operator](#language-operators-prefix_-5e)
    操作符和[pick](#routine-pick)得到你要的答案。

## read

- read FILEHANDLE, SCALAR, LENGTH, OFFSET

    `read`函数在Perl6中是IO::Handle和IO::Socket中实现的，它从关联的句柄或者套接字
    读取指定数量的字节（而不是字符），关于 Perl5中的偏移目前的文档中还没提到过。

## readdir

- readdir DIRHANDLE

    已去除，遍历一个目录的内容，请参考[dir routine](#type-io-path-routine_dir)。

## readline

- readline

    已去除，你可以使用`.lines`方法获得类似功能，更多细节请参考[io](#language-io)。

## readlink

- readlink EXPR

    貌似已去除。

## readpipe

- readpipe EXPR
- readpipe

    貌似在Perl6中不可用，但是`qx//`的功能可用，所以可能在某些类中偷偷地使用。

## recv

- recv SOCKET, SCALAR, LENGTH, FLAGS

    出现在IO::Socket类中，目前还没有明确文档。

## redo

- redo LABEL
- redo EXPR
- redo

    在Perl6未变化。

## ref

- ref EXPR

    已经去除，S29指出“如果你真的想获得类型名字，你可以使用`$var.WHAT.perl`，如果你真的想
    使用P5的ref机制，可以用`Perl5::p5ref`.”，但是目前`Perl5::p5ref`并不存在...

## rename

- rename OLDNAME, NEWNAME

    还可用。

## requires

- require VERSION

    没有可替代功能。

## reset

- reset EXPR

    没有可替代功能。

## return

- return EXPR

    虽然没有明确的文档，但是在Perl6中可用。

## reverse

- reverse LIST

    在Perl6中，你只能使用`reverse(@a)`或者`@a.reverse`反转一个列表，
    要反转一个字符串，请使用`.flip`方法。

## rewinddir

- rewinddir DIRHANDLE

    \[需要更多研究\]目前没有一个明显的可替代的功能，可能在`IO::Path`的一些
    方法会提供类似的功能，截止目前还不确切。

## rindex

- rindex STR, SUBSTR, POSITION

    和Perl5中功能类似，还支持对象方法方式，例如：`$x =
    "babaganush";say $x.rindex("a");say $x.rindex("a", 3); # 5, 3`。

## rmdir

- rmdir FILENAME

    和Perl5中功能类似，还支持对象方法方式，例如:`rmdir "Foo";`和`"Foo".IO.rmdir;`
    相同。

## s///

- s///

    在Perl6中，正则表达式的语法有一些不同，但是置换操作是存在的。 
    如果你想重用Perl5的代码，最重要的区别是用`~~`替换`=~`， 同样，
    用 `!~~`替换`!~`。正则操作的选项都变成了副词并且类型丰富，请查看
    [Adverbs page](#language-regexes-adverbs)。

## say

- say FILEHANDLE
- say LIST
- say

    `say`可被当做函数使用，默认输出到标准输出。如果需要输出到文件句柄，需要在句柄
    后加一个冒号，例如，`say $fh: "Howdy!"`。冒号是作为“调用者标记”来使用的， 
    关于它的讨论见[https://design.perl6.org/S03.html#line\_4019](https://design.perl6.org/S03.html#line_4019)。 
    你也可使用对象方法的形式调用`$fh.say("howdy!")`。

## scalar

- scalar EXPR

    已去除。

## seek

- seek FILEHANDLE, POSITION, WHENCE

    还没有正式文档，不过它在`IO::Handle`类下。

## seekdir

- seekdir DIRHANDLE, POS

    还没有正式文档，但是将会在`IO`的类中实现，可能是`IO::Path`。

## select

- select FILEHANDLE

    “`select`作为一个全局概念已经没了”，当我问到select时，我被告知$\*OUT以及类似的
    变量在动态作用域内是可重写的，还有模块`IO::Capture::Simple` (链接[https://github.com/sergot/IO-Capture-Simple](https://github.com/sergot/IO-Capture-Simple))
    也可以用来实现和`select`功能相同的事情。

## semctl

- semctl ID, SEMNUM, CMD, ARG

    核心中不再包含。

## semget

- semget KEY, NSEMS, FLAGS

    核心中不再包含。

## semop

- semop KEY, OPSTRING

    核心中不再包含。

## send

- send SOCKET, MSG, FLAGS, TO

    可在`IO::Socket`类中找到.

## setpgrp

- setpgrp PID, PGRP

    核心中不再包含,可能会在POSIX模块中找到。

## setpriority

- setpriority WHICH, WHO, PRIORITY

    核心中不再包含,可能会在POSIX模块中找到。

## setsockopt

- setsockopt SOCKET, LEVEL, OPTNAME, OPTVAL

    没有文档化，但是可能隐藏在`IO`类相关的模块中。

## shift

- shift ARRAY
- shift EXPR
- shift

    即可以作为函数使用，又可以作为方法使用,`shift @a`和`@a.shift`是等价的。

## shm\*

- shmctl ID, CMD, ARG
- shmget KEY, SIZE, FLAGS
- shmread ID, VAR, POS, SIZE
- shmwrite ID, STRING, POS, SIZE

    核心中不再包含,可能会其他模块中找到。

## shutdown

- shutdown SOCKET, HOW

    核心中不再包含,可能被挪到了`IO::Socket`模块。

## sin

- sin EXPR

    即可以作为函数使用，又可以作为对象方法调用，`` sin(2)和`2.sin`是等价的。 ``

## sleep

- sleep EXPR

    和Perl5中的功能一样，截止本文档编写，它还可以对象方法调用，但确定已被废弃，
    将来可能会去掉。

## sockets

- socket SOCKET, DOMAIN, TYPE, PROTOCOL
- socketpair SOCKET1, SOCKET2, DOMAIN, TYPE, PROTOCOL

    没有文档化，但是可能在`IO::Socket`类相关的模块中。

## sort

- sort SUBNAME LIST

    `sort`在 Perl6中还存在，不过表现有所不同。`$a`和`$b`不再是内置地特殊变量（见 [5to6-perlvar](https://metacpan.org/pod/5to6-perlvar)），
    还有不在返回正数，负数，或者0，而返回`Order::Less`, `Order::Same`, 或者`Order::More` 对象
    详见[sort](#routine-sort)。最后它也支持作为对象方法调用，例如，`sort(@a)`等价于`@a.sort`。

## splice

- splice ARRAY, OFFSET, LENGTH
- splice ARRAY, OFFSET
- splice ARRAY
- splice EXPR, OFFSET, LENGTH, LIST
- splice EXPR, OFFSET, LENGTH
- splice EXPR, OFFSET
- splice EXPR

    Per6中仍可用，也支持对象方法形式，例如，`splice(@foo, 2, 3,
    <M N O P>);`等价于 `@foo.splice(2, 3, <M N O P>);`。

## split

- split /PATTERN/, EXPR, LIMIT
- split /PATTERN/, EXPR
- split /PATTERN/

    跟Perl5中大致相同。不过，有一些例外，要达到使用空字符串的特殊行为，
    你必须真正的使用空的字符串,即 `//`的特殊情况不再视为空的字符串。 
    如果你向split传递了一个正则表达式，它会使用这个正则表达式，
    字符串按照字面意思来解析。 如果你想让结果中包含分隔的字符，你需要
    指定命名参数`:all`，比如：`split(';', "a;b;c",
    :all) # a ; b ; c`。分隔出的空的块不会像Perl5那样被移除，如必须这样的行为
    功能请浏览`comb`。 split的详细说明在 `split`。同时，split也可以作为
    对象方法使用：`"a;b;c".split(';')`。

- split

    见上面的描述，空参数版本必须配合限制为空字符串调用，例如 
    `$_ = "a;b;c"; .split("").say(); # .split.say不正确`。 

## sprintf

- sprintf FORMAT, LIST

    Works as in Perl 5. The formats currently available are:

    和Perl5一样工作，格式化字符现在支持这些：


|  符号         |                解释                      |
| ------------- |:----------------------------------------:|
|        %      |字面的百分比符号                          |
|        c      |给定代码代表的字符                        |         
|        s      |字符串 |
|        d      |有符号整数，十进制 |
|        u      |无符号整数，十进制 |
|        o      |无符号整数，八进制 |
|        x      |无符号整数，十六进制 |
|        e      |浮点数，科学计算法表示 |
|        f      |浮点数，固定精度表示 |
|        g      |浮点数，使用%e或者%f表示 |
|        X      |类似x，但是使用大写字母 |
|        E      |类似e，但是使用大写E |
|        G      |类似g，但是使用大写G（如果适用）          |

    兼容符号:

|  符号         |     解释         |
| ------------- |:----------------:|
|     i    |和% d同义 |
|     D    |和%ld同义 |
|     U    |和%lu同义 |
|     O    |和%lo同义 |
|     F    |和%f 同义 |

    和Perl5不兼容:

|  符号         |     解释         |
| ------------- |:----------------:|
|     n  |  会抛出运行时异常| 
|     p  |  会抛出运行时异常| 

    以下用来修饰整数，他们不需要操作数，语义并不是固定的

|  符号         |                解释                    |
| ------------- |:--------------------------------------:|
|    h  |  解释为native “short” 类型（通常是int16）| 
|    l  |  解释为native ”long” 类型（通常是int32或者int64| 
|    ll |  解释为native“long long” 类型（通常是int64）| 
|    L  |  解释为native“long long” 类型（通常是int64）| 
|    q  |  理解为native“quads” 类型（通常是int64或者更大）| 

## sqrt

- sqrt EXPR

    可以作为方法和函数使用，`sqrt(4)`和`4.sqrt`等价。

## srand

- srand EXPR

    可用。

## stat

- stat EXPR
- stat DIRHANDLE
- stat

  由于该函数是POSIX特异的，所以不会做为内建函数实现，可能通过`NativeCall`接口实现。

## state

- state VARLIST
- state TYPE VARLIST
- state VARLIST : ATTRS
- state TYPE VARLIST : ATTRS

    可用, 具体参考[state](#syntax-state).

## study

- study SCALAR
- study

    `study`不在支持.

## sub

- sub NAME BLOCK
- sub NAME(PROTO) BLOCK
- sub NAME : ATTRS BLOCK
- sub NAME(PROTO) : ATTRS BLOCK

    毋庸置疑，例程仍然可用。例程还支持签名，它允许你指定参数，不过，在缺少预定义
    的情况下（并且只在缺少签名的情况下），`@_`仍然包含当前传递给函数的参数。 
    所以，从理论上讲，如果从Perl5移植到Perl6你不用对函数做特殊转变（不过你应该
    考虑使用签名）。 所有这些详见[functions](#language-functions)。

## \_\_SUB\_\_

- \_\_SUB\_\_

    被`&?ROUTINE`替代。

## substr

- substr EXPR, OFFSET, LENGTH, REPLACEMENT
- substr EXPR, OFFSET, LENGTH
- substr EXPR, OFFSET

    支持函数以及对象方法两种形式：`substr("hola!", 1, 3)`和`"hola!".substr(1, 3)`都
    返回"ola"。

## symlink

- symlink OLDFILE, NEWFILE

    See [symlink](https://metacpan.org/pod/symlink)

## syscall

- syscall NUMBER, LIST

    非内建函数。很可能在某个模块实现，目前还不确定。

## sys\*

- sysopen FILEHANDLE, FILENAME, MODE
- sysopen FILEHANDLE, FILENAME, MODE, PERMS
- sysread FILEHANDLE, SCALAR, LENGTH, OFFSET
- sysread FILEHANDLE, SCALAR, LENGTH
- sysseek FILEHANDLE, POSITION, WHENCE

    和非系统版本的函数一样，有可能在`IO`类中。

## system

- system LIST
- system PROGRAM LIST

    同样的功能，你需要使用([run](#routine-run))或者[shell routine](#routine-shell))。

## syswrite

- syswrite FILEHANDLE, SCALAR, LENGTH, OFFSET
- syswrite FILEHANDLE, SCALAR, LENGTH
- syswrite FILEHANDLE, SCALAR

    和`sysopen`以及其他同类函数一样，被挪到了`IO`类中。

## tell

- tell FILEHANDLE

    在`IO::Handle`,不过简单提了一句，还没有文档。

## telldir

- telldir DIRHANDLE

    可能在`IO::Path`,还没有文档

## tie

- tie VARIABLE, CLASSNAME, LIST
- tied VARIABLE

    \[需要进一步研究\] S29中指出变量类型已经被容器类型替代，
    很不幸，这意味着实际中将不会有此函数定义。

## time

- time

    “返回当前时间的Int类型的表达”，虽然目前文档还没有说明它具体如何表示当前时间，
    不过看起来依然和Perl5一样是从纪元开始的秒数。

## times

- times

    Not available in Perl 6.

## tr///

- tr///

和Perl5类似，唯一需要注意的是范围指定不同了。 你必须使用“a..z“替代“a-z”，
也就是使用Perl的范围操作符。在 Perl6中，C<tr///>提供一个对象方法版本，
叫做C<.trans>。他增加了一些附加特性。

Perl5的C</r>标识符被C<TR///>操作符代替了；C<y///>还没有替代方法。

## truncate

- truncate FILEHANDLE, LENGTH
- truncate EXPR, LENGTH

    极有可能在`IO::Handle`模块中，还没有相关文档。

## uc

- uc EXPR

    支持函数以及对象方法两种形式。`uc("ha")`和`"ha".uc`都返回 "HA"。

## ucfirst

- ucfirst EXPR
- ucfirst

    已被去除，现在函数 [`tc`](#routine-tc)可以完成你想做的事。

## undef

- undef EXPR

    `undef`被去除，你不能undefine函数，与其功能最接近的一个值是`Nil`，
    但你可能用不到。在Perl6中，如果要使用诸如`(undef, $file, $line) = caller;`的语句，
    你可以直接获得文件名以及行数而不是忽略`caller`的第一个返回值。`caller`已经被`callframe`
    替代。所以Perl6中实现这样的功能的语句是 `($file, $line) =
    callframe.annotations<file line`;>。

## unlink

- unlink LIST

    依然可用，可以作为对象方法使用：`"filename".IO.unlink`。

- unlink

    零参数（隐式参数`$_`）版本在Perl6中不再可用。

## unpack

- unpack TEMPLATE, EXPR
- unpack TEMPLATE

    在Perl6中可用，模板设置比Perl5中限制更多，目前的文档请查看[here](#routine-unpack)。

## unshift

- unshift ARRAY, LIST
- unshift EXPR, LIST

    在Perl6中可用，也支持对象方法调用形式。`unshift(@a, "blah")`等价于`@a.unshift("blah")`。

## untie

- untie VARIABLE

    \[需要进一步研究\] 根据S29，方法中对变量绑定的操作被容器类型取代，所以tie和unite功能不是很明确，
    这在tie部分已经提到。

## use

- use Module VERSION LIST
- use Module VERSION
- use Module LIST
- use Module
- use VERSION

    在Perl5中，脚本的运行可能需要一个最低的Perl运行时本。在Perl6中，可以指定被不同Perl6运行时
    遵循的规范的版本（比如`6.c`）。

## utime

- utime LIST

    无对应的函数.

## values

- values HASH
- values ARRAY
- values EXPR

    在Perl6中可用，也支持对象方法调用，`values %hash`和`%hash.values`相同。

## vec

- vec EXPR, OFFSET, BITS

    S29中指出，应该使用定义`bit`,`uint2`, `uint4`等类型的buffer/array来取代vec，
    虽然还不是很明确，不过功能已经在实现中。

## wait

- wait

    \[需要深入研究\] 目前尚不明确被谁取代了，`Supply`中提供了一个方法`await`，`Channel`
    和`Promise`中提供了方法`wait`，这些函数跟Perl5中的`wait`联系目前还不明确。

## waitpid

- waitpid PID, FLAGS

    和`wait`一样，这个函数的安排并不明确

## wantarray

- wantarray

    Perl6中由于种种原因不在支持wantarray函数，具体这些原因可浏览[reasons](#language-faq-why_is_wantarray_or_want_gone-_can_i_return_different_things_in_different_contexts)。

    这里有几种简单的方式来实现wantarray的功能：

    首先，因为Perl6并不需要特殊的引用语法把`List`或者`Array`包装成`Scalar` ，
    简单的返回一个列表只需要：

        sub listofstuff {
            return 1, 2, 3;
        }
        my $a = listofstuff();
        print $a;                      # 输出 "123"
        print join("<", listofstuff()) # 输出 "1<2<3"

    其次，最普遍应用是提供一个行或者元素的数组，简单的打印数组输出一个优美的字符串。
    你通过使用`.Str`方法来达到这个目的：

        sub prettylist(*@origlist) {
            @origlist but role {
                method Str { self.join("<") }
            }
        }
        print prettylist(1, 2, 3);  # 输出 "1<2<3"
        print join(">", prettylist(3, 2, 1)); # 输出 "3>2>1"

    在上面的例子中，返回的列表可能是惰性的，`.Str` 方法将不会被调用知道其对象具体化，
    所以如果没有被请求之前，不会生成对象，从而不会有额外的工作。

    另一种场景是需要创建一个可以在空上下文使用，但是赋值时会拷贝的修改器。通常情况下
    在Perl6中不需要这样做，因为你可以通过使用`.=`运算符快捷地实现生成副本方法到修改器
    的转换：

        my $a = "foo\n";
        $a.ords.say; # 输出 "(102 111 111 10)"
        $a .= chomp;
        $a.ords.say; # 输出 "(102 111 111)"

    但是如果你想在两种操作下使用同一个函数名，大多数情况下你可以混入一个在结果发现自己
    处于空上下文的时会自动调用的`.sink`方法来完成，这样会产生一些警告，所以，并不建议
    这么做：

        multi sub increment($b is rw) {
            ($b + 1) does role { method sink { $b++ } }
        }
        multi sub increment($b) {
            $b + 1
        }
        my $a = 1;
        increment($a);
        say $a;                 # 输出 "2"
        my $b = increment($a);
        say $a, $b;             # 输出 "2 3"
        # 用户将会意识到这之后他们不应该意外sink一个存储的值，尽管这需要一些功夫
        sub identity($c is rw) { $c };
        $a = 1;
        $b = increment($a);
        identity($b);
        $a.say;                  # 输出 "2"

## warn

- warn LIST

    `warn`抛出一个异常。简单地将信息打印到`$*ERR`中，你可以使用`note`函数。 
    更多的异常的文档，请查看[Exceptions](#language-exceptions)。

## write

- write FILEHANDLE
- write EXPR
- write

    格式化输出已经移除了，这些函数在Perl6中不再可用。

## y///

- y///

    tr///的同义词已经移除了，对于此功能请参考["//" in tr](https://metacpan.org/pod/tr#pod)。

