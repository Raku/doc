# 从Perl5到Perl6指导 - 语法

# 从Perl5到Perl6的语法差异

# 概述

本文档旨在指导Perl5开发者快速熟悉和过渡到Perl6的语法和环境，会尽可能
全面的对比他们perlsyn的异同。

# 注意

本文档不会详细描述Perl6的语法细节，而是尝试说明Perl5中相关语法在Perl6中
的实现。详细的语法，请参考相关文档。

# 自由风格

Perl6在很大程度上继承了Perl自由的风格。 然而，在部分情况下不可避免的存在
违反自由风格的语法和实现，比如Perl5中，可以省略关键字后的空格（例如
`<while($x < 5)`>或`my($x, $y)`)。 在Perl6中，必须留要空格的，如
`<while ($x < 5)`>或`my ($x, $y)`。 然而，Perl6 中，你可以完全省略括号：
`while $x < 5`。 这同样适用于if ，for 等。

在Perl5中，你可以在数组或者哈希与下标访问之间，以及后缀运算符之前
保留空白。 所以,`$seen {$_} ++`是合法的，而现在不行，必须是`%seen{$_}++` 。

如果它让你感觉更好，你可以使用反斜杠转义空白，这可以使空白出现在本来禁止的地方。
详细信息请查看 [Whitespace](#language-5to6-nutshell-whitespace)。

## 声明

我们曾经在[Functions](/language/5to6-perlfunc)提到过，Perl6 中没有`undef`。
一个已经声明的，但是未初始化的标量变量值为变量类型。诸如，`my　$x;say $x;`; 
输出“(Any)”，`my Int $y;say $y;`将会输出“(Int)”。

## 注释

和Perl5一样，# 开始一段注释到行尾。

内嵌式注释起始于一个#号和反引号(`` #` ``)，紧跟着是一个开括号字符，然后直到匹配的闭括号字符。
例如：

    if #`( why would I ever write an inline comment here? ) True {
        say "something stupid";
    }

和Perl5中一样，可以使用pod直接创建多行注释,`=begin comment`用于注释
之前，`=end comment`在注释之后。

## 布尔值

Perl5和Perl6一个不同是Perl6认为字符串`"0"`为真。数值型`0`依然为假，
并且支持用前缀运算符`+`强制字符串`"0"`为数值型，从而为假。 此外，
Perl6中加入了真正的布尔（Boolean）类型，所以，在多数情况下，T
rue和False都是可用的，无需担心数值的真假。

## 语句修饰符

绝大多数语句修饰符依然可用都可用，有少数有例外。

首先,`for`循环是唯一类似Perl5 `foreach`风格的循环，并且不再支持C风格的循环。
C风格的循环，请使用`loop`，`loop`不再用做语句修饰符。

Perl6中，不再支持`do {...} while $x`格式，必须用`repeat`格式的`do`。和
 `do {...} until $x` 类似。

## 复合语句

最大的变化是`given`已经成了正式语法，相关信息请参考[this page](#language-control-given)。

## 循环控制

`next`, `last`,和`redo`没有改变。

`continue`被删除，可以通过在循环体内使用`NEXT`语句块来实现相同功能。

    # Perl 5
    my $str = '';
    for (1..5) {
        next if $_ % 2 == 1;
        $str .= $_;
    }
    continue {
        $str .= ':'
    }
    
    =begin code
    # Perl 6
    my $str = '';
    for 1..5 {
        next if $_ % 2 == 1;
        $str ~= $_;
        NEXT {
            $str ~= ':'
        }
    }

## For循环

在上面我提到过，C风格的`for`循环在Perl6中被`loop`循环代替。要写
一个无限循环，你不需要`loop (;;) {...}`样式的C语法，而是直接省略
表达式来表示：`loop {...}`。

## Foreach循环

在Perl5中，for额外用来支持C风格的`for`循环，和`foreach`同义。 在Perl6
中`for`只用于`foreach`循环。

## Switch语句

Perl6开始支持真正的switch语句，由`given`语句提出，用`when`和 `default`
处理各个分支的情况。基本语法是：

    given EXPR {
        when EXPR { ... }
        when EXPR { ... }
        default { ... }
    }

详细语法，请浏览[here](#language-control-given).

## Goto语句

`goto`目前还未实现。标签功能已经实现，可以作为`next`, `last`和`redo`的
跳转目标：

```
FOO:                         # 标签用分号结尾，和Perl 5一样
for ^10 {
    say "outer for before";
    for ^10 {
        say "inner for";
        last FOO;
    }
    say "outer for after";   # 由于"last"改行不会执行
}
# outer for before
# inner for
```
goto相关信息，请浏览
[https://design.perl6.org/S04.html#The\_goto\_statement](https://design.perl6.org/S04.html#The_goto_statement)。

## 占位语句

`...`(还有`!!!`和`???`)被用户创建一个预计函数的占位符。在Perl6中用法要更
复杂一点，详细细节可浏览[https://design.perl6.org/S06.html#Stub\_declarations](https://design.perl6.org/S06.html#Stub_declarations)。
也就是说，尽管它的功能在Perl6中被扩展了，似乎没有明显的理由不让占位语句的行为
还保持正常。

## PODs: 内嵌式文档

Perl6的POD相比较Perl5变化很大。其中最大的不同是需要用`=begin pod`和`=end pod`
开始和结束pod的内容。 还有一些其他的微调（注意由于这些差异使得一般pod解释器不能
正常工作）。例如，我在写本文档时发现，("|")在``代码中有特殊的含义，并且
插入一个字面量的 "|" 方法并不明确。你最好使用Perl6解释器检查你的pod，可以通过`--doc`
开关来实现，例如`perl6 --doc Whatever.pod`。这会把所有的问题输出到标准错误输出
(取决于perl6的安装位置，你可能需要指定 `Pod::To::Text`的位置)。
关于Perl6 pod文档的详细信息，请浏览[https://design.perl6.org/S26.html](https://design.perl6.org/S26.html)。
