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

Perl 6生态系统有一个模块[P5math](https://modules.perl6.org/dist/P5math)，可以替代Perl5 abs
的功能。

## accept

- accept NEWSOCKET, GENERICSOCKET

    `accept` 是一个在服务器端调用的方法，例如`$server.accept()`，该方法不再是返回一个封装的地址，
    而是返回一个socket，最通常常用于某些类型IO::Socket对象。

Perl 6生态系统模块 [P5caller](https://modules.perl6.org/dist/P5caller)的`caller`函数具有
相似功能。

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

和perl5差不多，但是必须带参数。`chdir()`（用来查询HOME和LOGDIR）功能不再支持。
在Perl6中，L<chdir>只能改变`$*CWD`动态变量，不能实际改版默认目录。如有必要，需要
专门的动态变量例程 L«`&*chdir`|/routine/&*chdir»来实现此种需求。
这是因为，每个OS线程没有默认目录这个概念。从Perl 6开始，不再是使用fork，而是使用
线程，对其而言，当前目录的概念应该是 `$*CWD`动态变量，该变量是词法范围的，所以
线程安全。

Perl 6生态系统有模块 [P5chdir](https://modules.perl6.org/dist/P5chdir)，和perl5
`chdir`函数功能相似，包括查询HOME和LOGDIR。


## chmod

- chmod LIST

    和Perl5中一样的函数，只是8进制数的表示有些不大一样（是`0o755`而不是`0755`），你也能把它作为方法使用，

## chomp

- chomp VARIABLE

`chomp`的行为和Perl5中有些不同，它对目标不产生影响，而是返回一个去除逻辑换行符的新的目标,例如
`$x = "howdy\n";$y = chomp($x);`结果`$x`为“howdy\n”以及`$y`为“howdy”。同样也可以作为方法使用，
例如`$y = $x.chomp`。和其他很多方法一样，它也可以以修改并赋值模式运行，例如`$x.=chomp`，结果`$x`
的值为"howdy"。

注意，不带参数的`chomp()`函数Perl不在支持。

Perl 6生态系统模块[P5chomp](https://modules.perl6.org/dist/P5chomp)提供函数`chomp`，实现Perl5`chomp`函数类似功能
和表现。

## chop

- chop VARIABLE

和`chomp`一样，在Perl6中，它返回被截取以后的字符串，而不是直接截取替换，比如`$x = "howdy";$y = chop($x);`，
结果是`$x`为“howdy”以及`$y`为“howd”。同样可以做为方法使用：`$y = $x.chop`。

注意，不带参数的`chop()`函数Perl不在支持

Perl 6生态系统模块[P5chomp](https://modules.perl6.org/dist/P5chomp)提供函数`chop`，实现Perl5`chop`函数类似功能
和表现。


## chown

- chown LIST

    `chown`已经去除.

## chr

- chr NUMBER

    和Perl5的相似，把目标强制转换成整数，然后返回其Unicode码指向的字符， 可以作为函数或者方法使用：

        chr(65); # "A"
        65.chr;  # "A"

Perl 6生态系统模块[P5chr](https://modules.perl6.org/dist/P5chr）的`chr`函数实现Perl5
`chr`函数类似功能。

## chroot

- chroot FILENAME

    似乎在Perl6中不存在。

## close

- close FILEHANDLE

不带参数的`close()`，Perl 6不再支持。

## closedir

- closedir DIRHANDLE

Perl6不再支持。

Perl 6生态系统模块 [P5opendir](https://modules.perl6.org/dist/P5opendir)的`closedir`
提供类似功能。

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

和Perl5中一样。

`cos`支持缺省参数时候对`$_`操作，但是不再是个函数，而是作为一个对象方法通过`.cos`调用。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math）提供函数 `cos`实现Perl5中类似
功能和表现。

## crypt

- crypt PLAINTEXT, SALT

Perl6还未实现。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math）提供函数`crypt`实现
P而l5中类似功能和表现。


## dbm functions

- dbmclose HASH
- dbmopen HASH, DBNAME, MASK

    这些函数在Perl5中很大程度上被取代了，不太可能出现在Perl6中（尽管Perl6的数据库
    实现还未成熟的）。

## defined

- defined EXPR

它可能能以你期望的那样工作，但是从技术上讲对于类型对象它返回`False`，其它情况返回`True`。
它使得当你没有为一个东西赋值时`$num.perl`会返回`Any`或者当你赋值了返回当前值更有意义。
当然，你也可以作为一个方法使用它:`$num.defined`。并且任何新创建的类都可以有自己的
`.defined`方法，可以用来判断何时以及如何是未定义的。

注意，不带参数的`defined()`，Perl 6中不再支持。

Perl 6生态系统模块[P5defined](https://modules.perl6.org/dist/P5defined）提供函数`defined`
实现Perl5中类似功能和表现。

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

Perl 6生态系统模块[P5each](https://modules.perl6.org/dist/P5each）提供函数`each`
实现Perl5中类似功能和表现。

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

和perl5一样,`exp`缺省参数时候对`$_`操作，但是不再是个函数，而是作为一个对象方法通过`.cos`调用。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math)提供函数`exp`
实现Perl5中类似功能和表现。

## fc

- fc EXPR

但是不带参数的形式不再支持。

Perl 6生态系统模块[P5fc](https://modules.perl6.org/dist/P5fc)提供函数`fc`
实现Perl5中类似功能和表现。

## fcntl

- fcntl FILEHANDLE, FUNCTION, SCALAR

    Perl6未提供。

## \_\_FILE\_\_

- \_\_FILE\_\_


被`$?FILE`代替。但是表现稍有不同，他必须是绝对地址，而不是Perl5中的相对地址

Perl 6生态系统模块[P5__FILE__](https://modules.perl6.org/dist/P5__FILE__)
提供函数`__FILE__` 实现Perl5中类似功能和表现。

## fileno

- fileno FILEHANDLE

`IO::Handle`的`native-descriptor`方法类似的`fileno`。

Perl 6生态系统模块[P5fileno](https://modules.perl6.org/dist/P5fileno)
提供函数`fileno` 实现Perl5中类似功能和表现。

## flock

- flock FILEHANDLE, OPERATION

    目前还未实现。

## fork

- fork

未作为内建函数，可以通过`NativeCall`接口使用，但是结果表现大不相同。

Perl 6提供扩展提供支持内部使用以及线程中使用。然而，`fork`仅克隆`fork`线程
结果是同进程的其他线程不可见，处于未知状态，还可能导致锁定。即使是Perl6程序
没有明确启用线程，编译器也会生成一些预编译的进程,Perl6 运行时VMs也会生成它内建
的工作线程来执行优化和GC的后台任务。因此，线程的很稳定，在这种情况下没有理由还
需要`fork`的功能。

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

不会再实现。

Perl 6生态系统模块[P5getpriority](https://modules.perl6.org/dist/P5getpriority)
提供函数`getpgrp`实现Perl5中类似功能和表现。

## getppid

不会再实现。

Perl 6生态系统模块[P5getpriority](https://modules.perl6.org/dist/P5getpriority)
提供函数`getppid`实现Perl5中类似功能和表现。

## getpriority

- getpriority WHICH, WHO

Perl 6生态系统模块[P5getpriority](https://modules.perl6.org/dist/P5getpriority)
提供函数`getpriority`实现Perl5中类似功能和表现。

## get and set functions

-  endpwent

-  getlogin

-  getpwent

-  getpwnam NAME

-  getpwuid UID

-  setpwent

Perl 6生态系统模块 [P5getpwnam](https://modules.perl6.org/dist/P5getpwnam)
`setpwent`实现Perl5中类似功能和表现。

-  endgrent

-  getgrent

-  getgrgid GID

-  getgrnam NAME

-  setgrent

Perl 6生态系统模块[P5getgrnam](https://modules.perl6.org/dist/P5getgrnam)
提供函数`endgrent`, `getgrent`, `getgrgid`, `getgrnam` 以及
`setgrent`实现Perl5中类似功能和表现。

-  endnetent

-  getnetbyaddr ADDR, ADDRTYPE

-  getnetbyname NAME

-  getnetent

-  setnetent STAYOPEN

Perl 6生态系统模块[P5getnetbyname](https://modules.perl6.org/dist/P5getnetbyname)
提供函数 `endnetent`, `getnetent`, `getnetbyaddr`, `getnetbyname`以及
`setnetent`实现Perl5中类似功能和表现。

-  endservent

-  getservbyname NAME, PROTO

-  getservbyport PORT, PROTO

-  getservent

-  setservent STAYOPEN

Perl 6生态系统模块[P5getservbyname](https://modules.perl6.org/dist/P5getservbyname)
提供函数 `endservent`, `getservent`, `getservbyname`,`getservbyport`以及
`setservent`实现Perl5中类似功能和表现。

-  endprotoent

-  getprotobyname NAME

-  getprotobynumber NUMBER

-  getprotoent

-  setprotoent STAYOPEN
 
 Perl 6生态系统模块[P5getprotobyname](https://modules.perl6.org/dist/P5getprotobyname)
提供函数`endprotoent`, `getprotoent`, `getprotobyname`,`getprotobynumber`以及
`setprotoent`实现Perl5中类似功能和表现。

-  gethostbyname NAME

-  gethostbyaddr ADDR, ADDRTYPE

-  gethostent

-  sethostent STAYOPEN

-  endhostent

[需要进一步研究]似乎这个列表中的函数可以被一些Roles比如 User,Group等处理。


-  glob EXPR

在核心中还不能用，尽管一些功能可以通过L<dir>例程以及他的`test`参数提供。

更多信息请浏览生态系统中的[`IO::Glob`模块](https://modules.perl6.org/dist/IO::Glob)

## gmtime

- gmtime EXPR

`localtime`, `gmtime`的各种功能似乎在DateTime对象里，为获取一个UTC格式的当前时间的`DateTime`对象，
可以用： `my $gmtime = DateTime.now.utc`。

Perl 6生态系统模块[P5localtime](https://modules.perl6.org/dist/P5localtime)
提供函数`gmtime`实现Perl5中类似功能和表现。

## goto

- goto LABEL
- goto EXPR
- goto &NAME

`goto LABEL`语法已经被接受，但是运行时部分的`goto`还未实现。所以以下语句
会报运行时错误：

    FOO: goto FOO; # Label.goto() not yet implemented. Sorry

## grep

- grep BLOCK LIST
- grep EXPR, LIST

    在Perl6依然存在，不过需要注意的是代码块之后需要一个逗号，例如
     `@foo = grep { $_ = "bars" }, @baz`。
    也可以作为对象方法使用： `@foo = @bar.grep(/^f/)`。

## hex

- hex EXPR

Perl 6中表达式必须明确指定。

用副词形式`:16`取代了，例如：`:16("aF")`返回175。

另外，可以使用 `.base`方法得到同样的结果：`0xaF.base(10)`。

碰巧 `.Str`默认显示的是10进制，所以如果你`say 0xaF`，它依然会打印175，
但这样不够直观，不是最好的方式。

Perl 6生态系统模块[P5hex](https://modules.perl6.org/dist/P5hex)
提供函数`hex`实现Perl5中类似功能和表现。

## import

- import LIST

    首先在Perl5中它一直不是内建的函数，在Perl6中，典型地，函数可以声明为导出或者不导出，
    所有可导出的函数可一起导出，同时，有选择的导出也行，但是这超出了本文档的范围，详见
    [this section](#language-5to6-nutshell-importing_specific_functions_from_a_module)。

## index

- index STR, SUBSTR, POSITION

和perl5表现一样，同时可作为对象方法：
`"howdy!".index("how"); # 0`

和Perl 5主要的不同是，当子符串没有发现时返回`Nil`而不是`-1`，这个特性在和`with`
语一起使用时非常有用。比如：

     with index("foo","o") -> $index {
         say "Found it at $index";
     }
     else {
         say "Not found"

    }

Perl 6生态系统模块[P5index](https://modules.perl6.org/dist/P5index)
提供函数`index`实现Perl5中类似功能和表现。

## int

- int EXPR

在Perl6里面它是和Perl5中一样的truncate（截断）函数（也可作为对象方法），你直接使用它作为
Perl5代码的移植版本，但是在Perl6中，你可以对一个数字方便地直接调用`int`方法。
`3.9.Int; # 3`和`3.9.truncate`等效。

需要注意的是`int`在Perl 6中具有具体意义。是一种类型，用于显式定义是一个原生整型：

    my int $a = 42; #  原生整数，和Perl 5 整数值类似。

`int`缺省参数时候对 `$_`操作，但不是能简单函数调用，而是用`.int`方法调用。

Perl 6生态系统模块[P5math](https://modules.perl6.org/dist/P5math)
提供函数`int`实现Perl5中类似功能和表现。

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

和Perl5中表现一致，也可以作为对象方法：`"UGH".lc`在Perl 6中一个表达式
必须是必须执行。
Perl 6生态系统模块[P5lc](https://modules.perl6.org/dist/P5lc)
提供函数`lc`实现Perl5中类似功能和表现。

## lcfirst

- lcfirst EXPR

未定义。
Perl 6生态系统模块[P5lcfirst](https://modules.perl6.org/dist/P5lcfirst)
提供函数`lcfirst`实现Perl5中类似功能和表现。

## length

- length EXPR

被`chars`取代，通常作为一个方法使用(`$string.chars`),也能作为函数用。

Perl 6生态系统模块 [P5length](https://modules.perl6.org/dist/P5length)
提供函数`length`实现Perl5中类似功能和表现。

## \_\_LINE\_\_

- \_\_LINE\_\_

被`$?LINE`取代。

Perl 6生态系统模块 [P5__FILE__](https://modules.perl6.org/dist/P5__FILE__)
提供函数 `__LINE__` 实现Perl5中类似功能和表现。

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

Perl 6生态系统模块 [P5localtime](https://modules.perl6.org/dist/P5localtime)
提供函数 `localtime` 实现Perl5中类似功能和表现。

## lock

- lock THING

目前在Perl 6中还没有对应的功能。Perl 6有`Lock`类用来创建Lock对象，可以根据需求为
locked或者unlocked，但是这样的锁定不能指向外部的对象。

## log

- log EXPR

和Perl相同，`log`缺省参数对`$_`操作，但是不能不作为函数，你需要通过`.log`调用
而不是`log`方法。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math)
提供函数 `log` 实现Perl5中类似功能和表现。

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

和Perl5一样。但是当给多级目录的参数时候，它会用同样的掩码自动生成不存在的中层目录（和Perl 5中
File::Path 模块中make_path的功能相似）。

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

Perl 6生态系统模块 [P5hex](https://modules.perl6.org/dist/P5hex)
提供函数n `oct` 实现Perl5中类似功能和表现。

## open

- open FILEHANDLE, EXPR
- open FILEHANDLE, MODE, EXPR
- open FILEHANDLE, MODE, EXPR, LIST
- open FILEHANDLE, MODE, REFERENCE
- open FILEHANDLE

相对于Perl5最明显的改变就是文件模式的语法，以只读方式打开一个文件，你需要使用`open("file", :r)`，
以只写、读写以及追加的方式打开需要分别使用 `:w`, `:rw`和`:a`，另外还有
一些关于编码以及如何处理换行的选项，具体参见L<here|/routine/open>。

Perl 6生态系统模块 [P5opendir](https://modules.perl6.org/dist/P5opendir)
提供函数n `opendir` 实现Perl5中类似功能和表现。

## opendir

- opendir DIRHANDLE, EXPR

    无这个函数。可以用 L«`&dir`/`IO::Path.dir`|/routine/dir» 代替。

## ord

- ord EXPR

和Perl5中一样，也支持对象方法：`"howdy!".ord; # 104`。

注意不带参数的`ord()`Perl6不再支持。

Perl 6生态系统模块 [P5chr](https://modules.perl6.org/dist/P5chr)
提供函数 `ord` 实现Perl5中类似功能和表现。

## our

- our VARLIST
- our TYPE VARLIST
- our VARLIST : ATTRS
- our TYPE VARLIST : ATTRS

    在Perl6表现一致。

## pack

- pack TEMPLATE, LIST

在Perl6中可用，当实验性质的 `use experimental :pack`被指定时，`pack`需要被调用。
模板的选项比Perl5更严格，详细文档可以参考L<unpack|/routine/unpack>。

Perl 6生态系统模块 [P5pack](https://modules.perl6.org/dist/P5pack)
提供函数 `pack` 实现Perl5中类似功能和表现。

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

被`$?PACKAGE`取代。但是与`__PACKAGE__`有稍许不同，因为它实际上是package对象，你必须通过
 `.^name`方法获得字符串。

Perl 6生态系统模块 [P5__FILE__](https://modules.perl6.org/dist/P5__FILE__)
提供函数 `__PACKAGE__` 实现Perl5中类似功能和表现

## pipe

- pipe READHANDLE, WRITEHANDLE

    根据你的需求的不同，进程（或者[Concurrency tutorial](#language-concurrency)）内部数据交互的话
    请浏览L«`Channel`|/type/Channel»。进程之间数据交互用 L«`Proc`|/type/Proc»。 

## pop

- pop ARRAY

Perl6中可用，也可用作对象方法，例如： `my $x = pop@a;` 和`my $x = @a.pop;`都是可以的。

`pop`现在必须后带参数。如果数组为空，在Perl 6中会返回Failure。

如果你想使用数组中定义的值，你可以使用`with`来出来这种情况。

=for code :preamble<my @array;>
with pop @array -> $popped {
    say "popped '$popped' of the array";
}
else {
    say "there was nothing to pop";
}

Perl 6生态系统模块 [P5push](https://modules.perl6.org/dist/P5push)
提供函数 `pop` 实现Perl5中类似功能和表现。

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

Perl 6生态系统模块 [P5print](https://modules.perl6.org/dist/P5print)
提供函数 `print` 实现Perl5中类似功能和表现。

## printf

- printf FORMAT, LIST
- printf

Perl6中其功能类似。详情请看L<sprintf|https://docs.perl6.org/type/Str#sub_sprintf)。如果输出到文件
句柄，使用对该句柄的[`.printf`](/type/printf)方法调用。

Perl 6生态系统模块 [P5print](https://modules.perl6.org/dist/P5print)
提供函数 `printf` 实现Perl5中类似功能和表现。

## prototype

- prototype FUNCTION

    Perl6中已去除，和其功能最相近是`.signature`，例如：`say &sprintf.signature`，结果是"(Cool $format, \*@args)"。

## push

- push ARRAY, LIST

在Perl6中依然可用，也能以方法调用形式使用：`@a.push("foo");`，I<注意:>数组内插行为和Perl5中不同：
`@b.push: @a`:将会把`@a`作为单个元素压入到`@b`中，更多请参考L<append method|/type/Array#method_append>。

需要注意的是Perl 6中  `push`返回操作后的数组，而Perl 5中返回的是元素的个数。

Perl 6生态系统模块 [P5push](https://modules.perl6.org/dist/P5push)
提供函数 `push` 实现Perl5中类似功能和表现。

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
然而，在正则表达式中使用`$foo`会被视为字符串字面的字符，使用`< <$foo` >>
会将`$foo`的内容作为正则代码直接内插到表达式中，注意尖括号和它在正则表达式
外部的行为有点不同。更多详情，浏览(https://design.perl6.org/S05.html#Extensible_metasyntax_(%3C...%3E))

Perl 6生态系统模块 [P5quotemeta](https://modules.perl6.org/dist/P5quotemeta)
提供函数 `quotemeta` 实现Perl5中类似功能和表现。

## rand

- rand EXPR

`rand`和Perl5中功能一样，但是现在你不需要给它提供参数了。把它作为一个方法使用
就会是这样的效果，例如，Perl5中的`rand(100)`等价于Perl6中的`100.rand`。 另外，
你还可以通过`(^100).pick`获取一个随机的整数，为什么要这么做？，可以参考[^ operator](/language/operators#prefix_%5E)
操作符和[pick](/routine/pick)得到你要的答案。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math)
提供函数 `rand` 实现Perl5中类似功能和表现。

## read

- read FILEHANDLE, SCALAR, LENGTH, OFFSET

    `read`函数在Perl6中是IO::Handle和IO::Socket中实现的，它从关联的句柄或者套接字
    读取指定数量的字节（而不是字符），关于 Perl5中的偏移目前的文档中还没提到过。

## readdir

- readdir DIRHANDLE

已去除，遍历一个目录的内容，请参考L<dir routine|/type/IO::Path#routine_dir>。

Perl 6生态系统模块 [P5opendir](https://modules.perl6.org/dist/P5opendir)
提供函数 `readdir` 实现Perl5中类似功能和表现。

## readline

- readline

貌似已去除。如果操作系统的文件系统支持的话，在`IO::Path`中有个方法`resolve` 可以操作符号链接。

Perl 6生态系统模块 [P5readlink](https://modules.perl6.org/dist/P5readlink)
提供函数 `readlink` 实现Perl5中类似功能和表现。

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

已经去除，你可以使用`$var.WHAT.^name`。

Perl 6生态系统模块 [P5ref](https://modules.perl6.org/dist/P5ref)
提供函数 `ref` 实现Perl5中类似功能和表现。

## rename

- rename OLDNAME, NEWNAME

    还可用。

## requires

- require VERSION

    没有可替代功能。

## reset

- reset EXPR

没有可替代功能。

Perl 6生态系统模块 [P5reset](https://modules.perl6.org/dist/P5reset)
提供函数 `reset` 实现Perl5中类似功能和表现。

## return

- return EXPR

    虽然没有明确的文档，但是在Perl6中可用。

## reverse

- reverse LIST

在Perl6中，你只能使用`reverse(@a)`或者`@a.reverse`反转一个列表，
要反转一个字符串，请使用`.flip`方法。

无参数`reverse`的函数在Perl 6中不在支持。

Perl 6生态系统模块 [P5reverse](https://modules.perl6.org/dist/P5reverse)
提供函数 `reverse` 实现Perl5中类似功能和表现。

## rewinddir

- rewinddir DIRHANDLE


Perl 6中不在支持。

Perl 6生态系统模块 [P5rewinddir](https://modules.perl6.org/dist/P5rewinddir)
提供函数 `rewinddir` 实现Perl5中类似功能和表现。

## rindex

- rindex STR, SUBSTR, POSITION

和Perl5中功能类似，还支持对象方法方式，例如：
 
 `$x ="babaganush";
say $x.rindex("a");
say $x.rindex("a", 3); # 5, 3`。

和Perl 5对比主要的不同是当子字串不存在时候返回`Nil`，而不是 `-1`。这在和`with`
语句连接使用时候非常有用。

    with index("foo","o") -> $index {
        say "Found it at $index";
    }
    else {
        say "Not found"
    }

Perl 6生态系统模块 [P5index](https://modules.perl6.org/dist/P5index)
提供函数 `rindex` 实现Perl5中类似功能和表现。

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
关于它的讨论见L<https://design.perl6.org/S03.html#line_4019>。
你也可使用对象方法的形式调用`$fh.say("howdy!")`。

Perl 6生态系统模块 [P5print](https://modules.perl6.org/dist/P5print)
提供函数 `say` 实现Perl5中类似功能和表现。

## scalar

- scalar EXPR

已去除。

CPAN Butterfly Plan 创建了模块支持一些函数，`:scalar`命名的参数表明函数的
具有`scalar`类似的行为。

## seek

- seek FILEHANDLE, POSITION, WHENCE

还没有正式文档，不过位于`IO::Handle`类中。

Perl 6生态系统模块 [P5seek](https://modules.perl6.org/dist/P5seek)
提供函数 `seek` 实现Perl5中类似功能和表现。

## seekdir

- seekdir DIRHANDLE, POS

Perl 6 不支持。

Perl 6生态系统模块 [P5opendir](https://modules.perl6.org/dist/P5opendir)
提供函数 `seekdir` 实现Perl5中类似功能和表现。

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

不会再实现。
Perl 6生态系统模块 [P5getpriority](https://modules.perl6.org/dist/P5getpriority)
提供函数 `setpgrp` 实现Perl5中类似功能和表现。

## setpriority

- setpriority WHICH, WHO, PRIORITY

不会再实现。

Perl 6生态系统模块 [P5getpriority](https://modules.perl6.org/dist/P5getpriority)
提供函数 `setpriority` 实现Perl5中类似功能和表现。

## setsockopt

- setsockopt SOCKET, LEVEL, OPTNAME, OPTVAL

    没有文档化，但是可能隐藏在`IO`类相关的模块中。

## shift

- shift ARRAY
- shift EXPR
- shift

即可以作为函数使用，又可以作为方法使用,`shift @a`和`@a.shift`是等价的。

缺省参数版本不在支持。而且，如果数组为空，则会返回Failure。

如果要明确返回定义的数组元素，你需要使用`with`语句来做判断。

```
=for code :preamble<my @array;>
with shift @array -> $shifted {
    say "shifted '$shifted' of the array";
}
else {
    say "there was nothing to shift";
}
```

Perl 6生态系统模块 [P5shift](https://modules.perl6.org/dist/P5shift)
提供函数 `shift` 实现Perl5中类似功能和表现。

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

和Perl 5中一样。`sin`缺省参数时候对`$_`操作。但是不在作为函数使用，但是
你可以将其当做对象方法通过 `.sin`调用，而不是简单的`sin`函数。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math)
提供函数 `sin` 实现Perl5中类似功能和表现。

## sleep

- sleep EXPR

和Perl 5中的一样的使用，但是不在限制为整数值的秒数。并且他返回值一直为 Nil。
如果你有意通过`sleep`返回值来确保sleeping到特定时间，你可以用`sleep-until`，
它会返回`Instant`。

如果你意图让代码运行N秒，并且不在意具体那个进程运行，请使用`Supply.interval`的
`react`和`whenever`方法。

Perl 6生态系统模块 [P5sleep](https://modules.perl6.org/dist/P5sleep)
提供函数 `sleep` 实现Perl5中类似功能和表现。

## sockets

- socket SOCKET, DOMAIN, TYPE, PROTOCOL
- socketpair SOCKET1, SOCKET2, DOMAIN, TYPE, PROTOCOL

    没有文档化，但是可能在`IO::Socket`类相关的模块中。

## sort

- sort SUBNAME LIST

    `sort`在 Perl6中还存在，不过表现有所不同。`$a`和`$b`不再是内置地特殊变量（见 [Special Variables](/language/5to6-perlvar)），
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

可以Perl 5中一样。缺省值的`sqrt`对 `$_`运算，但是不能当做函数使用，而是当
做对象方法你需要用`.sqrt`调用。

Perl 6生态系统模块 [P5math](https://modules.perl6.org/dist/P5math)
提供函数 `sqrt` 实现Perl5中类似功能和表现。

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

Perl 6生态系统模块 [P5study](https://modules.perl6.org/dist/P5study)
提供函数 `study` 实现Perl5中类似功能和表现。

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

被`&?ROUTINE`替代，有点不同的是它实际上是 `Sub`（或者`Method`）对象，你需要
通过调用`.name`获得一个字串。

Perl 6生态系统模块 [P5__FILE__](https://modules.perl6.org/dist/P5__FILE__)
提供函数 `__SUB__` 实现Perl5中类似功能和表现。

## substr

- substr EXPR, OFFSET, LENGTH, REPLACEMENT
- substr EXPR, OFFSET, LENGTH
- substr EXPR, OFFSET

    支持函数以及对象方法两种形式：`substr("hola!", 1, 3)`和`"hola!".substr(1, 3)`都
    返回"ola"。

## symlink

- symlink OLDFILE, NEWFILE

    见[symlink](https://metacpan.org/pod/symlink)。

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

Perl 6中不再支持。

Perl 6生态系统模块 [P5opendir](https://modules.perl6.org/dist/P5opendir)
提供函数 `telldir` 实现Perl5中类似功能和表现。

## telldir

- telldir DIRHANDLE

    可能在`IO::Path`,还没有文档

## tie

- tie VARIABLE, CLASSNAME, LIST
- tied VARIABLE

Perl 6 对应的scalar是`Proxy`容器，例如：

```
    sub lval() {
      Proxy.new(
        FETCH => method () { ...},
        STORE => method ($new) { ... }
      )
    }

 ```
这是使得`lval`为一个左值子例程。无论任何值请求，会调用`FETCH`方法。而如果在
一个赋值语句中使用，则会调用`STORE`方法。

对函数和哈希（对象为`Positional`和（或） `Associative`角色），唯一需要提供的方法
使得和Perl 5 `tie`一样功能的。这些说明详细描述在`Subscripts`部分。

Perl 6生态系统模块 [P5tie](https://modules.perl6.org/dist/P5tie)
which exports `tie` / `tied` 实现Perl5中类似功能和表现。

## time

- time

返回从epoch开始的秒数（`Int`对象），和Perl一样。

## times

- times

Perl 6中不支持。

Perl 6生态系统模块 [P5times](https://modules.perl6.org/dist/P5times)
提供函数 `times` 实现Perl5中类似功能和表现。

## tr///

- tr///

和Perl5类似，唯一需要注意的是范围指定不同了。 你必须使用“a..z“替代“a-z”，
也就是使用Perl的范围操作符。在 Perl6中，C<tr///>提供一个对象方法版本，
叫做C<.trans>。他增加了一些附加特性。

Perl5的C</r>标识符被C<TR///>操作符代替了；C<y///>还没有替代方法。

## truncate

- truncate FILEHANDLE, LENGTH
- truncate EXPR, LENGTH

目前版本还未实现 (2018.04)。

## uc

- uc EXPR

支持函数以及对象方法两种形式。`uc("ha")`和`"ha".uc`都返回 "HA"。

忽略参数版本的函数不再支持。

Perl 6生态系统模块 [P5lc](https://modules.perl6.org/dist/P5lc)
提供函数 `uc` 实现Perl5中类似功能和表现。

## ucfirst

- ucfirst EXPR
- ucfirst

已被去除，你可以使用标题大写函数[tc>|/routine/tc>。

Perl 6生态系统模块 [P5lcfirst](https://modules.perl6.org/dist/P5lcfirst)
提供函数 `ucfirst` 实现Perl5中类似功能和表现。

## undef

- undef EXPR

`undef`被去除，你不能undefine函数，与其功能最接近的一个值是`Nil`，
但你可能用不到。在Perl6中，如果要使用诸如`(undef, $file, $line) = caller;`的语句，
你可以直接获得文件名以及行数而不是忽略`caller`的第一个返回值。`caller`已经被`callframe`
替代。所以Perl6中实现这样的功能的语句是 `($file, $line) =
callframe.annotations<file line`;>。

Perl 6生态系统模块 [P5defined](https://modules.perl6.org/dist/P5defined)
提供函数n `undef` 实现Perl5中类似功能和表现。

## unlink

- unlink LIST

    依然可用，可以作为对象方法使用：`"filename".IO.unlink`。

- unlink

    零参数（隐式参数`$_`）版本在Perl6中不再可用。

## unpack

- unpack TEMPLATE, EXPR
- unpack TEMPLATE

在Perl6中可用，当在`unpack`调用作用域有`use experimental :pack`指定时，模版选项
限制比Perl 5更严。详见文档L<unpack|/routine/unpack>。

Perl 6生态系统模块 [P5pack](https://modules.perl6.org/dist/P5pack)
提供函数n `unpack` 实现Perl5中类似功能和表现。

## unshift

- unshift ARRAY, LIST
- unshift EXPR, LIST

和Perl 5中使用方法类似，也支持对象方法调用形式：

`@a.unshift("foo");`。

注意，变量展开方式和Perl 5中大有不同：
`@b.unshift: @a` 将会unshift `@a`作为一个独立元素到`@b`中。
更多文档详见[prepend method](/type/Array#method_prepend)

还有就是Perl 6的 `unshift`返回数组对象，而不是Perl 5中的元素个数。

Perl 6生态系统模块 [P5shift](https://modules.perl6.org/dist/P5shift)
提供函数n `unshift` 实现Perl5中类似功能和表现。

## untie

- untie VARIABLE

Perl 6 不在支持，具体在tie部分已经提到。

Perl 6生态系统模块 [P5tie](https://modules.perl6.org/dist/P5tie)
提供函数n `untie` 实现Perl5中类似功能和表现。

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

Perl 6中不再支持。

S29中指出，应该使用定义`bit`,`uint2`, `uint4`等类型的buffer或数组来取代vec，
但是`bit`, `uint2`, `uint4`的支持还未就绪。 `uint8`, `int8`, `uint16`,
`int16`,`uint32`, `int32`, `uint64`, `int64`以及随系统大小的`uint`和`int`
已经可用。包括标量，数组和异形数组（aka矩阵）等形式。

## wait

- wait

    \[需要深入研究\] 目前尚不明确被谁取代了，`Supply`中提供了一个方法`await`，`Channel`
    和`Promise`中提供了方法`wait`，这些函数跟Perl5中的`wait`联系目前还不明确。

## waitpid

- waitpid PID, FLAGS

    和`wait`一样，这个函数的安排并不明确

## wantarray

- wantarray

Perl 6 中没有`wantarray`，但是可以有很多简单的方法可以实现类似功能。

首先，因为Perl6并不需要特殊的引用语法把`List`或者`Array`包装成`Scalar` ，
简单的返回一个列表只需要：

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

