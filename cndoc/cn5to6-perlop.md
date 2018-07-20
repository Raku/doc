# 从Perl5到Per6指导 - 操作符

# 从Perl5到Per6指导 - 相等和变量

# 概述

本文档旨在全面（希望是）列出Perl5操作符在Perl6中的实现 ，
并在必要时对差异进行说明。

# 注意

本文档不会解释关于操作符的具体细节。而是旨在指导开发者快速从perl5习惯用法
迅速过渡和熟悉到perl6的语法中来。

关于perl6操作符的详细信息，请参考 [Perl 6 documentation](#language-operators).

## 运算符优先级以及关联 

Perl6中运算符的优先级和Perl5有很大的差异，所以此处不在细述。相关信息，请参考
[Operator Precedence](#language-operators-operator_precedence)。

## 术语和列表运算符

在Perl5运算符文档中列出的一元或者列表运算符我们一般认为是函数，比如 `print` 
和`chdir`。诸如此类函数都在[functions](language/5to6-perlfunc)指导，
还有括号依然用于分组。需要注意的是，在Perl 6中，`,`(逗号)用来生成列表，
不是括号，比如：
```
=begin code
my @foo = 1,2,3,4,5;   # 没有括号
.say for 1,2,3,4,5;    # 也没有

my $scalar = (1);      # *不是*列表，没有逗号
my $list   = (1,);     # 一个scalar容器中的一个列表
=end code
```
## 箭头运算符

由于Perl6引用出镜机会不多，所以用对其解引用场合也非常有限。而更普通存在的
对象解引用，箭头要替换成点操作。 而且对象方法调用也是点。所以在Per 6中，
Perl5中的`$arrayref->[7]`被`$arrayref.[7]`取代，同理，`$user->name`
变成了`$user.name`。 胖箭头`=>`现在用于构造 Pairs，详见[Pair term documentation](#language-terms-pair)。

## 自增自减

和Perl5一样可以使用，需要注意的一点是perl6中可以通过调用方法`succ`实现`++`，
`pred`实现 `--`的功能。直接使用`++`， `--`操作内置数值类型时能会造成不可
预知的结果。不过自定义类型也可以定义`succ`和`pred`方法。 所以在这些场合，
你需要关注`++`和`--` 实际做了啥。

## 幂运算

能以期望的那样工作，对比Perl5的`**`运算符，Perl6中它的优先级要高于一元运算符
（例如，-2\*\*4的值是 -(2\*\*4)，而不是(-2)\*\*4）。

## 一元符号运算符

在Perl5中，一元运算符`!`和`-`分别是逻辑非和算术负号，可能需要注意的是它们会分别
将参数强制为`Bool`以及 `Numeric`。 `?^`用做按位取反，有些文档把这操作写做`!` 。

一元运算符`~`在Perl6中是字符串连接运算符，你可以使用 `+^`来完成按位取反，是个
二元运算符。

`+`在Perl6中会对操作数有影响，它会强制转换它的参数为数值类型。

一元运算符`\`已去除，如果你实在想引用一个已经存在的命名变量，你可以使用item上下文，
例如`$aref = item(@array)`。或者你可能更熟悉通过`$`的前缀：`$aref = $@array`。
注意，你实际上并未获得引用，而是一个具有一个应用对象的scalar容器。

你可以通过使用`&` sigil得到一个命名子例程的“引用”：`$sref= &foo`。 
匿名数组、哈希以及子例程在创建时就会立即返回一个底层对象：`$sref = sub { }`

## 绑定运算符

`=~`和`!~`被`~~`和`!~~`替代，那些在对Perl5中智能匹配有顾虑的人现在可以放心使用了，
在Perl6中它们更好用了，强类型意味着不需要那么多的猜测。

## 乘除运算符

二元运算符 `*`, `/`和`%`在Perl5中分别为乘法、除法以及求余。

Perl6中的二元运算符`x` 稍微有些不同，同样的语句`print '-' x 80;`会返回给你一个80横线
的字符串（这点上一样），但是Perl5的 `@ones = (1) x 80;`返回给你一个80长度的由"1"组成的
列表，在Perl6中同样的效果你得用`@ones = 1 xx 80;`。

## 加减运算符

二元运算符`+`和`-`分别为加法和减法,符合预期。

因为`.`现在是方法调用运算符，所以二元运算符`~`代替`.`作为Perl6的连接运算符。

## 位运算符

C« << »和C« >> »被`+<`和`+>`取代。

## 一元命名运算符

上面提到过，请查看[functions](/language/5to6-perlfunc).

## 关系运算符

和Perl5表现一样。

## 比较运算符

`==`和`!=`表现和Perl5中相同。

`<=>`和`cmp`在Perl6中表现大不同。`<=>`作为数值比较运算符，但返回不再是
`-1`, `0`,或者`1`，而是`Order::Less`, `Order::Same`, 或者`Order::More`。 

为了获取Perl5中的&lt;cmp>一样的行为（Perl6它也返回Order对象，而非整数），你需要用
`leg`运算符。

`cmp` 现在根据参数类型的不同可以做`<=>`或者`leg`的操作（兼容两种类型）。

`~~`是Perl5中的智能匹配运算符，和上面提到一样，Perl6是正则匹配操作符了。 对于
Perl6中智能匹配运算符的细节，请参考[smartmatch文档](../doc/language/operators#index-entry-smartmatch_operator)。

## 智能匹配运算符

请参考[smartmatch文档](../doc/language/operators#index-entry-smartmatch_operator)对其工作原理做深入了解。

## 位与

`&`被`+&`取代。

## 位或和异或

按位或从Perl5中的`|`变成了`+|`，类似的，异或`^`被`+^`取代。

## C风格逻辑与

无变化

## C风格逻辑或

无变化

## 逻辑定义或

Perl6中还是//，若第一个操作数已经定义则将其作为返回值，否则返回第二个操作数。
当然，它还有一个低优先级的版本`orelse`。

=head2 范围运算符

在列表上下文，C<..>作为范围运算符没有变化，另外还增加了一些很有用的范围运算符。
它们是：

- infix C<..^>  不包括终点;
- infix ^.. 不包括起点;
- infix C<^..^> 不包括起始;
- prefix C<^> 从0开始,不包括终点.

下面的例子显示了上面各种操作符（注意括号只是用来允许方法调用）：

```
=begin code

(1..^5).list;  # (1 2 3 4)
(1^..5).list;  # (2 3 4 5)
(1^..^5).list; # (2 3 4)
(^5).list;     # (0 1 2 3 4)
=end code
```
在Perl 5标量上下文，C<..>和C<...>在Perl5中作为flip-flop运算符，但是鲜为人知和使用。
这些运算符在Perl6中被L<ff|/routine/ff>以及L<fff|/routine/fff>取带。
## 条件运算符

`?:`被了`?? !!`代替，例如Perl5中的代码`$x= $ok ? $y : $z;`在 Perl6中需要这样
表达： `$x = $ok ?? $y !! $z;`。

## 赋值运算符

虽然还没有完全文档化，S03指出数值以及逻辑赋值运算符表现都会符合预期。 一个明显的
变化是`.=`会调用等号左边（它也是一个类型对象）的变异的方法。下面技巧也可用：

```
class LongClassName {
    has $.frobnicate;
}
my LongClassName $bar .= new( frobnicate => 42 ); # 无需重复类名
```
这可以确保`$bar`将只包含一个`LongClassName`对象，也无需重复类名。

`~=`是字符连接赋值。和你预期地`.`和`~`变化想同。还有，按位赋值运算符
貌似不再区分数值以及字符串版本(`&=`, etc., vs. `&.=`, etc.)，
虽然这些特性在Perl5中依然是实验性的，而且这些还没有确切的文档。

## 逗号运算符

逗号运算符符合预期，但是技术上它用来创建[Lists](#type-list))或者分开函数调用的参数，
并且，函数调用也可以使用`:`变量将函数调用转换为对象方法调用，详见[this page](#language-operators-infix_-3a)。

运算符`=>` 和Perl5中的“胖箭头”类似，它允许左侧的标志符不加引用，但是在Perl6中
它用来构造Pair对象，不仅仅作为一个分隔符。如果是将Perl5的代码转换到Perl6，
它的行为不变。

## 列表运算符

如同一元命名运算符一样，请参考[5to6-perlfunc.pod](#language-5to6-perlfunc)。

## 逻辑非

运算符`!`优先级较低的版本，正如`!`一样，强制将它的参数转换为`Bool`。

## 逻辑与

运算符`&&`的优先级较低的版本，表现和Perl5中一致。

## 逻辑或以及异或

`or`是运算符`||`的低优先级版本。`xor`是运算符`^^`的低优先级版本
另外，还有运算符`//`低优先级版本`orelse`。

## 引用以及引用类运算符

关于引用底层结构细节，参见[quoting](#language-quoting)。

有些引用运算符允许绝对字符串：`Q`或者`｢…｣` ，可能由于你的键盘缘故，
这个字符可能很难找到。。。反斜杠转义在`Q`引用字符串中不起作用，例如：
`Q{This is still a closing curly brace → \}`结果是 
"This is This is still a closing curly brace → \\"。

`q`表现符合预期，允许反斜杠转义，例如：`q{This is
not a closing curly brace → \}, but this is → }` 将返回 
"This is not a closing curly brace → }, but this is →"。 在Perl5中，
单引号与它行为一致。

`qq`允许变量的内插，然而，默认情况下只有标量会被内插替换。对使用其它类型
的变量，需要在其后加上方括号的变量，需要在其后加上方括号（叫做[zen-slice](../doc/language/subscripts#index-entry-Zen_slices)）
才能内插。例如：

    `@a =<1 2 3>;say qq/@a[] example@example.com/;` 

结果是 "1 2 3 example@example.com"。

对于哈希，内插结果是意料之外的方式：
`%a = 1 => 2, 3 => 4;say "%a[]";`。 结果将会以空格分隔键值对，tab分隔
每个键值对的键和值（因为这是C<Pair>的标准的字符串，C<Pair>字串化为一个列表）。
 当然，你依然可以用花括号在字符串中内插Perl6代码。 

相关细节，请浏览[Interpolation](#language-quoting-interpolation-3a_qq)。

`qw`跟Perl5中一样，它还可以用`<...>`形式表示，例如`qw/a b c/`和
`<a b c>`相同。

还有一个支持内插的`qw`版本（qw本身不支持内插）`qqw`。例如：
`my $a = 42;say qqw/$a b c/;` 将会返回 "42 b c"。

shell引用现在用`qx`，不过你需要注意的是``` `` ```不再像Perl5那样用于shell引用，
还有Perl变量在`qx`字符串中也不做插值。如果你想在shell命令行字符串中使用内插，
你需要使用`qqx`。

`qr`被移除。

`tr///`和Perl5类似，需要注意的一点是指定范围的方式变化了，你现在得用 "a..z"，
而不是"a-z"。`tr///`对应的对象方法版本，有详细的文档的，那就是`.trans`，
`.trans`的对象是pairs列表：例如 `$x.trans(['a'..'c'] => ['A'..'C'], ['d'..'q'] =>
['D'..'Q'], ['r'..'z'] => ['R'..'Z']);`。 关于`.trans`详细信息，请参考
[https://design.perl6.org/S05.html#Transliteration](https://design.perl6.org/S05.html#Transliteration)。等价的`y///`已被删除。

Perl6中的heredoc有些差异，你必须用`:to`作为你的引用运算符，例如`q:to/END/;`
将会开始一段以"END"为结尾的heredoc。同样地，根据你使用的引用运算符`Q`，`q`和
`qq`，heredoc表现相对应的引用效果。

## I/O 操作符

关于 Perl 6 的输入/输出完整细节请浏览[io](#language-io)。

`<...>`作为Perl6中的quote-word构造器一样，`<>`不再用于按行读取文件，
你可以通过对`IO`对象或者打开的文件句柄上调用`.lines`来实现安行读文件。比如：
`my @a ="filename".IO.lines;`或`my $fh = open "filename", :r;my @a =$fh.lines;` 
（后者使用`:r`表明文件用只读模式）。要用迭代的方式，你可以使用`for`循环：

    for 'huge-csv'.IO.lines -> $line {
        # Do something with $line
    }

注意这里的`->`，这是结构块语法的一部分。 在Perl6中，`if`, `for`, `while`等
都需要一个结构块。

如果你想读取整个文件内容到标量中，你可以使用`.slurp`方法。例如：

    my $x = "filename".IO.slurp;
    # ... 或 ...
    my $fh = open "filename", :r;
    my $x = $fh.slurp;

在[Special Variables](/language/5to6-perlvar)有提到过，魔法输入文件句柄`ARGV`
已经被`$*ARGFILES`取代了，命令行参数数组也被`@ARGV`被`@*ARGS`取代。

## 空操作

`1 while foo();`和Perl 5中表现一样，但是会打印一个告警，在Perl 6中正确写法是：
`Nil while foo();`

## 按位字符串运算符

对前面提及的相关内容，总结一下：

前缀运算符 `+^`执行整数的按位取反，`?^`执行布尔类型的按位取反。

`+&`按位与。

整型的按位或是`+|`，按位异或是中缀运算符`+^`，布尔型的按位或是`?|`。

左移和右移是`+<`及`+>`。
