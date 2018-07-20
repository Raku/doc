# 从Ruby到Perl6初步: 以最熟悉的方式使用Perl6

本文档立足于列出Ruby和Perl6语法和语义上的差异。对Ruby中习惯用法，列举在Perl6
中对应的写法。（而对Perl6中的特性及习语不做论述）。

所以本文档不是为Perl6初学者指导书或者语法概述。预期的读者为具有Ruby语言基础
的开发者。用以指导其快速熟悉Perl6语法和迁移到Perl6开发。

# 基础语法

## 语句结束分号

Ruby中使用换行符号（有些例外情况），作为表达式的结束。通常在行结尾添加计算符
来使得表达式可以跨行。

    foo +     # Ruby语句结尾的计算符表示表达式跨行
      bar +
      baz

Perl6中表达式必须以`;`结尾，这种方式能有更好的交互以及对多行语句的兼容性也更好。
这种方式下有两种情况是不需要`;` 的：一种是用{}括起来的语句块的最后一条语句；还有
就是语句块后面仅有的一行语句。

    my $x;
    ...;
    if 5 < $x < 10 {
      say "Yep!";
      $x = 17         # 不需要; 语句块}之前的语句。
    }               
    say "Done!"      #  不需要；此处也可以省略，因为}后只有一行的结束语句

## 空格

在空格的使用上Ruby的兼容性很强，甚至开启了strict和warnings模式下

    # 有点不和常规，但是在Ruby是合法的
    puts"Hello "+
    (people [ i]
        . name
        ) . upcase+"!"if$greeted[i]<1

Perl6中也非常倡导程序员的自由和创造力，但是平衡了语法兼容和设计目标：一致性、确定性
可扩展语法，支持单向语义分析和有用的错误信息，一些集成的特性，比如自定义操作符清理
，避免开发者偶然误解他们的意图。同时，“code高尔夫”实践被强调；Perl6设计在概念而上更简洁而
不是少敲键盘。

作为结果，Ruby中很多的地方的空格是可选择，在perl6中要么强制必须空格或者禁止使用。
很多这些限制不太可能涉及到很多实际的Perl代码（例如，数组变量和方括号之间的空格是不允许的）。
但是不幸的是有几个地方和Ruby惯用法是冲突地。

- _ 参数列表空格之前不能有空格_

        foo (3, 4, 1); # Ruby和Perl6中都不对 (Perl6中这表示传递给foo一个类型列表的单个参数



        foo(3, 4, 1);  # 正确方法
        foo 3, 4, 1;   # Ruby和Perl 6 - 可选的无括号风格

- _关键词后**需要**紧跟一个空格_

        if(a < 0); ...; end         # Ruby中ok

        my $a; ...;
        if ($a < 0) { ... }         # Perl6
        if $a < 0 { ... }           # Perl6,更地道

        while(x > 5); ...; end      # Ruby

        while ($x > 5) { ... }      # Perl6
        while $x > 5 { ... }        # Perl6,更地道

- _前缀或者后缀操作符之前（包括数组/哈希下标）之前不能有空格_

        seen [ :fish ] = 1    # Ruby, 不地道但是合法
        %seen< fish > = 1;    # Perl6, 'seen'后不能有空格

- _如果和前缀/后缀操作符可能有冲突，中间操作符之前则必须有空格_

        n<1     # Ruby (Perl6中，这会和前缀操作符< >冲突)
        $n < 1; # Perl 6

## C«.» 方法调用, `.send`

和Ruby中一样方法调用使用．操作:

    person.name    # Ruby

    $person.name   # Perl6

对一个直到运行时才知道名字的对象，对其方法调用:

    object.send(methodname, args);  # Ruby

    $object."$methodname"(@args);   # Perl 6

如果漏掉引号，perl6期望 `$methodname`为一个`Method`对象，而不是简单地方法名字。

## 变量，标识符，范围以及通用类型

Ruby中，通过变量标识符来表示其作用范围，`$`表示全局变量，`@@` 表示类范围，
`@` 表示实例范围，如果不带标识符则表示局部变量（包括参数）。`&` 标识符用
来表示方法引用。符号前缀为`:`,由于它就不是变量，所以不是真正意义上的标识符。

Perl6 标识符主要用来指示包含值的角色，指示值的类型（至少示接口）。无论变量
怎么使用，其标识符是不变的，你可以把他当成是变量名字的一部分。

变量的作用域通过定义是语句(`my`,`has`, `our`, 等等)来指定的。

### 变量的作用域

对局部变量，Ruby通过分配时隐式申明，其作用范围限制为当前块。Ruby中`if`和`while`
内建的不被当做块或者范围。

Perl6使用显示范围指定，从不隐式创建变量。所有你看到地`{ ... }`都被作为范围，
包括条件和循环结构的内部。最常用的范围定义如下：

    foo = 7        # Ruby变量，作用范围在第一赋值时候定义，其作用域到当前块的结束
    my  $foo = 7   # Perl6, 词法范围，限制为当前块
    our $foo = 7   # Perl6, 包范围
    has $!foo = 7  # Perl6, 实例范围 (属性)

### `$`标量

`$`标识符一直作用于标量变量（例如`$name`），这些变量都是单值容器。

这是最通常的变量类型，对他的内容没有任何限制。需要指出的是，也可以使用或者引用他
的内容，比如`$x[1]`，`$x{"foo"}`或者`$f("foo")`。

### `@`数组

`@`标识符，一直数组变量（例如`@months`，`@months[2]`, `@months[2, 4]`用做
数组切片）。变量使用`@`标识符，仅用来指明位置的角色，指示位置索引和切片的功能。

- _索引_

        puts months[2]; # Ruby
        say @months[2]; # Perl 6

- _值切片_

        puts months[8..11].join(',') # Ruby
        say @months[8..11].join(',') # Perl 6

### `%`哈希

`%`标识符，一直用于哈希变量（例如`%calories`，`%calories<apple`>, `%calories<pear plum`>）
变量使用`%`标识符，仅能包含关联的角色（关联数组）。

Ruby用方括号来对数组和哈希取值。Perl6则是使用大括号来取哈希值。尖括号的版本也可用
，用来对其内容自动插值（字符串不用引号）：

副词可以用来控制切片的类型。

- _索引_

        puts calories["apple"]  # Ruby
        say %calories{"apple"}; # Perl6

        puts calories["apple"]  # Ruby
        puts calories[:apple]   # Ruby, 符号作为键是普通的
        say %calories<apple>;   # Perl6 - 角括号代替单引号
        say %calories«"$key"»;  # Perl6 - 双角括号中双引号插值

- _值切片_

        puts calories.values_at('pear', 'plum').join(',') # Ruby
        puts calories.values_at(%w(pear plum)).join(',')  # Ruby, 更好的方法?
        say %calories{'pear', 'plum'}.join(',');          # Perl 6
        say %calories<pear plum>.join(',');               # Perl 6 (更好的方法)
        my $keys = 'pear plum';
        say %calories«$keys».join(','); # Perl6, 变量插值切片

- _键/值切片_

        say calories.slice('pear', 'plum').join(','); # Ruby,ActiveRecord
        say %calories{'pear', 'plum'}:kv.join(',');   # Perl 6 -使用 :kv副词
        say %calories<pear plum>:kv.join(',');        # Perl 6 (更好的方法)

### `&`函数

`&`标识符和Ruby的类似，用来引用函数对象，一个未调用的命名子函数或操作符
例如，将该名字当做名词，而不是动词。变量使用`&`标识符仅能包含可调用的角色。

    add = -> n, m { n + m } # Ruby lambda 定义加法函数
    add.(2, 3)              # => 5, Ruby调用lambda
    add.call(2, 3)          # => 5, Ruby调用lambda


    my &add = -> $n, $m { $n + $m } # Perl6加法函数
    &add(2, 3)                      # => 5, 可以用&标识符
    add(2, 3)                       # => 5, 也可以不带也能工作



    foo_method = &foo;     # Ruby

    sub foo { ... };
    my &foo_method = &foo; # Perl6


    some_func(&say) # Ruby传递一个函数引用

    sub some_func { ... };
    some_func(&say) # Perl6用同样的方式，传递一个函数引用

Ruby中最后一个参数通常传递一个块，主要用于DSLs。这个DSLs块可以为`yield`的隐式参数，
或者以`&`为前缀的显式的块。Perl6中可调用参数要明确列出，并且通过变量名调用（而不是
yield），有很多种方法可以调用这个函数。

    # Ruby,定义一个方法，调用隐式块参数
    def f
      yield 2
    end

    # Ruby, 调用f,快递给他一个参数的块
    f do |n|
      puts "Hi #{n}"
    end



    # Perl6, 显式的块参数定一个方法
    sub f(&g:($)) {
      g(2)
    }

    # Perl 6, 调用f,传递给她一个参数的块，有多种方法对其调用
    
    f(-> $n { say "Hi {$n}" }) # 显式参数
    f -> $n { say "Hi {$n}" }  # 显式参数, 没有空格

    # 同时, 如果'f'是一个对象的实例方法，你可以使用C<:>，而不是大括号
    my $obj; ...;
    obj.f(-> $n { say "Hi {$n}" })  # 显式参数
    obj.f: -> $n { say "Hi {$n}" }  # 显式参数, 没有空格
    obj.f: { say "Hi {$^n}" }       # 隐式参数

### `*` Slurpy参数/参数扩展

在Ruby中，你可以定义一个 `*`为前缀参数获取其他传递的参数到一个数组，
Perl 6中也类似。

    def foo(*args); puts "I got #{args.length} args!"; end # Ruby

    sub foo(*@args) { say "I got #{@args.elems} args!" }   # Perl 6

上面Per 6版本的在slurp参数给@args时有些许不同，如果存在多级嵌套会自动展开，
只保留最内一级：

```
sub foo(*@args) { say @args.perl }
foo([1, [2, 3], 4], 5, [6, 7]);   # [1, [2, 3], 4, 5, 6, 7]
```
```
sub foo(**@args) { say @args.perl }
foo([1, [2, 3], 4], 5, [6, 7]);  # [[1, [2, 3], 4], 5, [6, 7]]
```
你可能想扩展一个数组为一个参数集。Perl 6是通过[Slip](/type/Slip) C<|>。

    args = %w(a b c)         # Ruby
    foo(*args)

    my @args = <a b c>       # Perl 6
    foo(|@args);

Perl 6支持更先进的方式传递和处理参数。详细请浏览[Signatures](#language-functions-signatures)
和[Captures](#type-capture)。

## Twigils

除此之外，Perl 6 还支持"twigils"语法，它位于变量和标识符之间，对变量做更多修饰。例如：

    $foo     # Scalar ,无twigil
    $!foo    # 私有实例变量
    $.foo    # 实例变量操作符
    $*foo    # 动态范围变量
    $^foo    # 块中一个位置参数（占位）
    $:foo    # 代码快中一个命名参数 (占位符)参数
    $=foo    # POD（文档）变量
    $?FILE   # 当前源文件名。? twigil表示一个编译时值
    $~foo    # 子语言解析器r, 不常用

尽管上面的例子都用了`$`标识符，同样适用于`@`或者`%`

## `:` Symbols

Perl 6 通常使用字符串，而Ruby使用symbols。一个最基本的例子就是哈希键。

    address[:joe][:street] # 典型地Ruby嵌套哈希，其键为symbol

    my %address; ...;
    %address<joe><street>  # 典型地Perl 6嵌套哈希，键为字符串

Perl6 中有_colon-pair_语法，这在一定程度上和Ruby的symbol比较相似。

    :age            # Ruby symbol


    # Perl 6 中可以使用一下各种语法代替
    :age            # Perl 6 pair,使用隐式True值 
    :age(True)      # Perl 6 pair,使用显式True值 
    age => True     # Perl 6 pair，使用箭头语法
    "age" => True   # Perl 6 pair，使用箭头语法和显式分号 

你大概不想使用一个隐式值得colon-pair，而兼顾和Ruby symbol语法一致，因为这不是
很地道的Perl 6 语法。

# 操作符

很多操作符在Ruby和Perl 6中是类似的

- `,` 列表分隔符
=item `+` 数字加
=item `-` 数字减
=item `*` 数字乘
=item `/` 数字整除
=item `%` 数字求余
=item `**` 数字求幂
=item `! && ||` 逻辑运算符，高优先级
=item `not and or` 逻辑运算符，低优先级

    你可能会使用 `$x++`而不是`x += 1`作为变量自增的快捷方式。这可以作为一个
    预增操作符`++$x`（递增，返回一个新值）或者后增`$x++`操作（递增，返回旧值）。

    你可能会使用 `$x--`而不是`x -= 1`作为变量自增的快捷方式。这可以作为一个
    预增操作符`--$x`（递增，返回一个新值）或者后增`$x--`操作（递增，返回旧值）。

## C«== != < > <= >=» 比较

为了避免犯错，Perl 6 中数字和字符的比较是分开的：

- C«== != < > <= >=» 比较
=item `eq ne lt gt le ge` 字符串比较

    例如，使用`==`时候会把变量值转化为数字， `eq`则会把值转为字符串。

## C«<=>» 三目比较

Ruby中，C«<=>»操作符返回-1, 0或者1。

Perl 6中，返回 `Order::Less`, `Order::Same`或者`Order::More`。

C«<=>» 强制数字上下云做比较

C«leg» ("Less, Equal, or Greater?") 强制字符上下文比较

C«cmp»兼容 C«<=>»或 `leg`, 具体取决于实际的比较对象的类型
arguments.

## `~~` 智能匹配符

这是一个很普通的匹配操作符，但是Ruby中不支持。下面是一些例子：

    my $foo; ...;
    say "match!" if $foo ~~ /bar/;      # 模式匹配
    say "match!" if $foo ~~ "bar";      # 字符匹配
    say "match!" if $foo ~~ :(Int, Str) # 签名匹配（解构）

更多细节，请浏览[S03/Smart matching](https://design.perl6.org/S03.html#Smart_matching)

## `& | ^` 字符位操作符
=head2 `& | ^` 布尔操作符

Perl 6中，这些单字符操作符都被去除，用双字符操作符取代，是的他们
的参数更符合所需的上下文。

    # 中缀操作符 (两个参数;一边一个)
    +&  +|  +^  与 或 异或: 数字
    ~&  ~|  ~^  与 或 异或: 字符
    ?&  ?|  ?^  与 或 异或: 布尔型

    # 前缀操作符 (一个参数，在操作符后)
    +^  非: 数字
    ~^  非: 字符
    ?^  非: 布尔型 (和!一样)

## `&.` 有条件的连结操作符

Ruby 使用`&.`操作符连结操作，当任何一个返回错误时候不会触发错误。Perl 6中使用
`.?`实现同样的功能。

## C«<< >>» 数字左移,右移操作符,shovel操作符

Perl6中用C«+<»和C«+>»代替。

       puts 42 << 3  # Ruby
    
       say  42 +< 3; # Perl 6

需要注意的是，Ruby中常用的C«<<»做为和 `.push`类似的装填（shovel）操作符，Perl 6
中并不支持。

## C«=>»和`:`健值分割符

Ruby中C«=>»使用在哈希健值对定义和参数传递时候。`:` 用在标记随后的变量为symbol。

Perl6 中，C«=>» 是Pair操作符，使用了完全不一样的原理，但是大多数情况下工作是一样的。

如果C«=>»用于哈希定义，用法非常相似

    hash = { "AAA" => 1, "BBB" => 2 }  # Ruby, 尽管symbol的键更常用

    my %hash = ( AAA => 1, BBB => 2 ); # Perl 6, 使用了()，尽管通常用{}

## `? :` 三元运算符

Perl 6中，使用了两个问号，而不是一个问号，对应地分号也是使用两个。这常见的三元运算
符不同，可能会导致误用情况比较突出。

    result     = (  score > 60 )  ? 'Pass'  : 'Fail'; # Ruby

    my $score; ...;
    my $result = ( $score > 60 ) ?? 'Pass' !! 'Fail'; # Perl 6

## `+` 字符连结符

Perl6中用波浪线取代。象形记忆下，把连个字符串用针和线穿了起来。

    $food = 'grape' + 'fruit'  # Ruby

    $food = 'grape' ~ 'fruit'; # Perl 6

## 字符串插值

Ruby中，`"#{foo}s"`消除嵌入在双引号字符串中的块。Perl6中去除了`#`前缀,用`"{$foo}s"`。
和Ruby中一样，你可以把代码嵌入块中，它会在在字符形式呈现。 

变量可以简单地在双引号子串中直接内插，而不需要使用块语法。

    # Ruby
    name = "Bob"
    puts "Hello! My name is #{name}!"



    # Perl 6
    my $name = "Bob"
    say "Hello! My name is $name!"

Ruby中使用的`.to_s`用来返回字符上下文结果。Perl 6 中使用`.Str`或者`.gist`得到同样
结果。

# 复合语句

## 条件语句

### `if` `elsif` `else` `unless`

Ruby和Perl6中用法类似，但是Perl6使用`{ }`清晰地标识执行块。

    # Ruby
    if x > 5
        puts "Bigger!"
    elsif x == 5
        puts "The same!"
    else
        puts "Smaller!"
    end



    # Perl 6
    if x > 5 {
        say "Bigger!"
    } elsif x == 5 {
        say "The same!"
    } else {
        say "Smaller!"
    }

将一个条件表达式绑定到变量语法有少许不同：

       if x = dostuff(); ...; end   # Ruby
    
       sub dostuff() {...};
       if dostuff() -> $x {...}     # Perl 6, 块赋值要用箭头

`unless`条件语句Perl6中仅允许在单块模式下执行；不能用`elsif`和`else`语句。

### `case`-`when`

Perl6中`given`-`when`结构和Ruby中`if`-`elsif`-`else`语句链结构相似。
最大的不同是Ruby用`==`比较分支条件，而Perl6使用了更普遍的智能匹配符`~~`。
其一般结构是：

&#x3d; :lang&lt;pseudo>
    given EXPR {
        when EXPR { ... }
        when EXPR { ... }
        default { ... }
    }

其最精简的模式，结构如下：

    my $value; ...;
    given $value {
        when "a match" {
        #    do-something();
        }
        when "another match" {
        #    do-something-else();
        }
        default {
        #    do-default-thing();
        }
    }

这是标量值匹配`when`最简单的语句，更通常情况下，实际的匹配是智能匹配输入值。
在更复杂的情况下可能正则表达式，而不单单是标量值。

## 循环语句

### `while` `until`

绝大多数语法没变；条件语句中的括号是可选的，但是如果使用了括号的话，则后面不能紧跟
着关键词，否则会被当做函数调用。将条件语句绑定到变量的语法也有些不同：

    :lang<ruby
       while x = dostuff(); ...; end    # Ruby

       sub dostuff {...}; ...;
       while dostuff() -> $x {...}      # Perl 6

### `for` `.each`

`for`循环在Ruby中很少用，一般都是用枚举的`.each`操作。在Perl6中对`.each`和`.map`
最直接替代方法可能是用`.map`。但是通常都是直接用`for`的。

    # Ruby循环
    for n in 0..5
        puts "n: #{n}"
    end

    # Ruby, 更通常是用.each
    (0..5).each do |n|
        puts "n: #{n}"
    end



    # Perl 6
    for 0..5 -> $n {
        say "n: $n";
    }

    # Perl 6,用的很少的 .map
    (0..5).map: -> $n {
        say "n: $n";
    }

Ruby中`.each`迭代变量是一个列表元素的复制，修改操作不会影响原始的列表。要注意的
是，他复制的是引用的，所以你仍然可能修改其指向的值。

Perl6中，该别名是只读的（为了安全性），因此其表现和Ruby一样，除非你使用C«<->»。

    cars.each { |car| ... }    # Ruby; 只读引用

    for @cars  -> $car   {...} # Perl 6; 只读
    for @cars <-> $car   {...} # Perl 6; 读写

## 流程跳转

和Ruby中一样:

- `next`
=item `redo`

    该语句在Perl6中是`last`。

# 正则表达式( Regex / Regexp )

Perl6的正则表达有着极大的不同，比Ruby要强大的多。例如，默认空格是忽略的，其他
所有字符必须要转义。通过正则表达式可以很容易地通过用组合和定义的方法创建更有效
的语法。

Perl6正则表达有很多强大的特性，特别在用相同语句定义整个语法方面。更多请浏览
[Regexes](#language-regexes) 和 [Grammars](#language-grammars).

## `.match`方法和`=~`操作符

在Ruby中，正则匹配可通过对变量做`=~`正则匹配运算，可以用`.match`方法。Perl6
中用`~~`智能操作符和`.match`方法。

    next if line   =~ /static/   # Ruby
    next if line  !~  /dynamic/ ; # Ruby
    next if line.match(/static/)    # Ruby

    next if $line  ~~ /static/;  # Perl 6
    next if $line !~~ /dynamic/ ; # Perl 6
    next if $line.match(/static/);  # Perl 6

相应的`.match`和`.subst`方法也可以使用。注意到`.subst`是不可变的。详细细节
[S05/Substitution](https://design.perl6.org/S05.html#Substitution).

## `.sub`和`.sub!`

在Perl6中，你通常使用 `s///`操作符进行正则替换。

    fixed = line.sub(/foo/, 'bar')        # Ruby, 不可变

    my $line; ...;
    my $fixed = $line.subst(/foo/, 'bar') # Perl 6,不可变


    line.sub!(/foo/, 'bar')   # Ruby,可变

    my $line; ...;
    $line ~~ s/foo/bar/;      # Perl 6,可变

## 正则选项

很多正则选项从正则表达式后面被移到表达式前面了。这可能要你增加可选的
`m`在诸如C«/abc/»匹配语句之前。

    next if $line =~    /static/i # Ruby

    my $line; ...;
    next if $line ~~ m:i/static/; # Perl 6

## 空格是被忽略，大多数字符需要转义

为了增加语句的可读性和可重用性，Perl中空格是被忽略的

    /this is a test/ # Ruby, 随便一个字符串
    /this.*/         # Ruby, 可能有意义的字串

    / this " " is " " a " " test / # Perl 6,每个空格被转义
    / "this is a test" / # Perl 6, 转义整个字符串
    / this .* /          # Perl 6, 可能感兴趣的字符串

## 特殊匹配语法都通常都用<>语法

这儿是Perl6正则语法支持的特殊匹配语法。这些不是全部的列表，通常断言是用C«<>»
而不是 `()`。

对字符类，这意味着：

- `[abc]` 变成 C«<\[abc\]>»
- `[^abc]` 变成 C«<-\[abc\]>»
- `[a-zA-Z]` 变成 C«<\[a..zA..Z\]>»
- `[[:upper:]]` 变成 C«<:upper>»
- `[abc[:upper:]]` 变成 C«<\[abc\]+:Upper>»

    对环视断言（零宽断言）:

- `(?=[abc])` 变成 C«&lt;?\[abc\]>»
- `(?=ar?bitrary* pattern)` 变成 C«&lt;before ar?bitrary\* pattern>»
- `(?!=[abc])` 变成 C«&lt;!\[abc\]>»
- `(?!=ar?bitrary* pattern)` 变成 C«&lt;!before ar?bitrary\* pattern>»
- C«(?<=ar?bitrary\* pattern)» 变成 C«&lt;after ar?bitrary\* pattern>»
- C«(?&lt;!ar?bitrary\* pattern)» 变成 C«&lt;!after ar?bitrary\* pattern>»

    (和<>语法没有关联, 环视`/foo\Kbar/`变成C«/foo <( bar )> /»

- `(?(?{condition))yes-pattern|no-pattern)` 变成 C«\[ &lt;?{condition}>
      yes-pattern | no-pattern \]»

## 最长token匹配(LTM)取代唯一匹配

Perl6正则，引入`|` 了最长token匹配(LTM)，匹配结果取决于对一组规则模糊的匹配
最优选择。而不是最前面的一个正则表达式。

为了和这个新语法冲突，需要将Ruby中的`|`正则表达式都替换为`||`。

# 文件相关操作符

## 读取文本文件的行到数组

Ruby和Perl6都可以很方便的把一个文件的所有行读入单个变量，而且两者读取时候都会
忽略换行符。

    lines = File.readlines("file")   # Ruby

    my @lines = "file".IO.lines;     # Perl 6, 从字符串创建一个IO对象

## 文件各行之间的迭代

把文件中所有行都读入内存做法不被推荐的。Perl6 `.lines`方法返回一个惰性序列，但是
但是赋值到一个数组是强制读文件的。最好对结果进行迭代

    # Ruby
    File.foreach("file") do |line|
        puts line
    end



    # Perl 6
    for "file".IO.lines -> $line {
        say $line
    }

# 面向对象

## 基础类，方法，属性

Perl6和Ruby的类定义是相似地，都是用`class`关键字。Ruby中方法用`def`，Perl6
中用`method`。

    # Ruby
    class Foo
        def greet(name)
            puts "Hi #{name}!"
        end
    end



    # Perl 6
    class Foo {
        method greet($name) {
            say "Hi $name!"
        }
    }

在Ruby你可以使用一个之前未定义的属性，你可以使用`@`标志表明它是一个属性。
你可以使用`attr_accessor`以及变体定义操作符范围。Perl6中使用 `has`语句
定义，附加一个标记。你可以用`!`标记一个私有属性，或者`.`创建一个访问器。

    # Ruby
    class Person
        attr_accessor :age    # 定义.age作为@age的访问器方法
        def initialize
            @name = 'default' # 给给私有实例变量赋默认值
        end
    end



    # Perl 6
    class Person {
        has $.age;              # 定义$!age和访问器方法
        has $!name = 'default'; # 给私有实例变量赋默认值
    }

创建一个新的类对象使用`.new`方法。Ruby中通过`initialize`方法你必须手动赋值
给各实例变量。Perl6中你有一个默认的构造器，接收访问器属性的健值对，你还可以通
过`BUILD`方法，做更多的初始化工作。和Ruby中一样，你可以重构`new`，使其更具
功能性，但是一般很少有人这样做。

    # Ruby
    class Person
        attr_accessor :name, :age
        def initialize(attrs)
            @name = attrs[:name] || 'Jill'
            @age  = attrs[:age] || 42
            @birth_year = Time.now.year - @age
        end
    end
    p = Person.new( name: 'Jack', age: 23 )



    # Perl 6
    class Person {
        has $.name = 'Jill';
        has $.age  = 42;
        has $!birth_year;
        method BUILD {
            $!birth_year = now.Date.year - $.age;
        }
    }
    my $p = Person.new( name => 'Jack', age => 23 )

## 私有方法

Perl6中私有方法通过方法名加`!`前缀来定义，并且通过`!`调用，而非`.`操作符。

    # Ruby
    class Foo
        def visible
            puts "I can be seen!"
            hidden
        end

        private
        def hidden
            puts "I cannot easily be called!"
        end
    end

    # Perl 6
    class Foo {
        method visible {
            say "I can be seen!";
            self!hidden;
        }

        method !hidden {
            say "I cannot easily be called!";
        }
    }

需要特别指出的是，Ruby的子对象可以访问其父类的私有方法（这表现和其他语言的 
"protected"方法相同）。Perl6中，子对象对父对象的私有方法不可读。

## 使用元编程

这儿有一些元编程的例子。注意Perl6中通过克拉（<>）将元方法和正则方法分开了。

    # Ruby
    person = Person.new
    person.class
    person.methods
    person.instance_variables


    # Perl 6
    class Person {};
    ...
    my $person = Person.new;
    $person.^name;             # Perl 6, 返回Person (类)
    $person.^methods;          # Perl 6, 使用.^ 语法操作元方法
    $person.^attributes;

和Ruby一样，Perl6中，也遵从一切皆对象的原则，但是并不是所有操作符都对应到
Ruby的`.send`。有很多操作符是全局函数，使用了类型多路调度（类型是函数签名）
来决定启用具体哪一个。

    5.send(:+, 3)    # => 8, Ruby

    &[+](5, 3)       # => 8, Perl 6, 指向中间加法操作符

    &[+].^candidates # Perl 6, 列出+操作符的所有签名

更多细节，请浏览 [Meta-Object Protocol](#language-mop)。

# 环境变量

## Perl模块类库目录

Ruby中，用一个环境变量`RUBYLIB`来指出额外的模块搜索路径。

    $ RUBYLIB="/some/module/lib" ruby program.rb

Perl6中也类似，甚至你可能猜的到，这个变量名变成了`PERL6LIB`：

    $ PERL6LIB="/some/module/lib" perl6 program.p6

不需要直接赋值给`PERL6LIB`和`RUBYLIB`，你只需要用`use lib`语句指出
类库的路径。

    # Ruby and Perl 6
    use lib '/some/module/lib';

# 杂项

## 从模块中引入特殊的函数

Ruby中没有内建的方法去有选择性的从模块中import/export方法。

Perl6中，可以使用`is export`角色在相关的函数上就可以export这些特定的函数。使用_all_
的角色函数都会export。例如，下面例子中模块`Bar`中export `foo`和`bar`函数，但是不export
`baz`：

    unit module Bar; # 该文件的其他部分都在模块Bar{ ... }中

    sub foo($a) is export { say "foo $a" }
    sub bar($b) is export { say "bar $b" }
    sub baz($z) { say "baz $z" }

使用这个模块的时候，简单地用`use Bar`,函数 `foo`，`bar`是可用的。

    use Bar;
    foo(1);    #=> "foo 1"
    bar(2);    #=> "bar 2"

如果你尝试去使用`baz`，会触发一个"Undeclared routine" 的编译时错误。

一些允许有选择性的引入函数的模块，其结构看起来会像：

    use Bar <foo>; # Import only foo
    foo(1);        #=> "foo 1"
    bar(2);        # Error!

## `可选语法`,命令行标记语法

Perl6中命令行参数开关解析是通过`MAIN`子例程的参数列表。

    # Ruby
    require 'optparse'
    options = {}
    OptionParser.new do |opts|
        opts.banner = 'Usage: example.rb --length=abc'
        opts.on("--length", "Set the file") do |length|
            raise "Length must be > 0" unless length.to_i > 0
            options[:length] = length
        end
        opts.on("--filename", "Set the file") do |filename|
            options[:file] = filename
        end
        opts.on("--verbose", "Increase verbosity") do |verbose|
            options[:verbose] = true
        end
    end.parse!

    puts options[:length]
    puts options[:filename]
    puts 'Verbosity ', (options[:verbose] ? 'on' : 'off')


    ruby example.rb --filename=foo --length=42 --verbose
        42
        foo
        Verbosity on

    ruby example.rb --length=abc
        Length must be > 0


    # Perl 6
    sub MAIN ( Int :$length where * > 0, :$filename = 'file.dat', Bool :$verbose ) {
        say $length;
        say $filename;
        say 'Verbosity ', ($verbose ?? 'on' !! 'off');
    }


    perl6 example.p6 --file=foo --length=42 --verbose
        42
        foo
        Verbosity on
    perl6 example.p6 --length=abc
        Usage:
          example.p6 [--length=<Int>] [--file=<Any>] [--verbose]

注意到Perl6在命令行解析错误时候自动生成了一个完整的使用提示信息。

# RubyGems,扩展类库

请浏览[https://modules.perl6.org/](https://modules.perl6.org/)，这儿有持续增长的Perl6类库以及
相应的可用的管理工具。

如果你使用模块还没升级Perl6版本，或者本文档中没有列出的内容，可能是
在Perl6中还没有完善。

以实验性质你可以用 [Inline::Ruby](https://github.com/awwaiid/Inline-Ruby/)
在Perl6程序中调用现存的Ruby代码。它使用一个内嵌的`ruby`解释器实例运行Ruby
代码。注意，这是实验性质的类库。你还可以用同样的方法调用其他语言的类库，利用
Inline::Perl5,Inline::Python 以及更多。

