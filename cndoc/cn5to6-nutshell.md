
# 5to6-nutshell

# Perl5到Perl6初步: 我怎么做我习惯做的?

本文档尝试去索引从 Perl 5到 Perl 6的语法以及语义上的变化。 
那些在 Perl 5中正常工作的，在 Perl 6中却要换一种写法的语法
应该被列出在这里（而许多 Perl 6的_新_特性以及风格就不会）。

因此，次文档并不是针对 Perl 6初学者的手册或者进阶文章，它是为
有Perl5知识背景的 Perl6 学习者以及移植 Perl5 代码到 Perl6的人员
准备的技术文档（虽然 ["#Automated Translation"](#automated-translation)可能会更方便一些）。

注意，当文档中我们说“现在”时，更多的意思是“你现在正在尝试 Perl 6”，
并没有暗示说 Perl 5突然过 时了，恰恰相反，大多数的我们都深爱 Perl 5，
我们希望 Perl 5能再继续使用好多年，事实上，我们的 重要目标之一就是让
Perl5和 Perl6之间顺利交互。 不过，我们也喜欢 Perl 6的设计目标，相比 
Perl5中的设计目标，更新颖，更好。 所以，我们中的大多数人都希望在
下一个十年或者两个十年，Perl 6能成为更流行的语言，如果你想把“现在”
当作未来，那也是很好的，但我们对导致争论的非此即彼的思想不感兴趣。

# CPAN

请浏览 [https://modules.perl6.org/](https://modules.perl6.org/) .

如果你使用的模块还没有被移植到 Perl 6，而且在列表中没有替代品，
可能在 Perl 6中的使用问题还没有解决。有很多目标是为了在 Perl6
中 `use` Perl5模块的工程：

v5模块意在让Rakudo自身解析Perl5的代码，然后编译成和Perl6同样的字节码。
[Inline::Perl5](https://github.com/niner/Inline-Perl5/)工程使用一个
内嵌的 `perl` 解释器运行 Perl 6脚本中调用到的Perl 5代码。

其中，Inline::Perl5更完善，更有前途。

# 语法

## 标识符

对于标识符，Perl 6允许你使用横杠(`-`)，下划线(`_`)，撇号(`'`)，以及字母数字：

    sub test-doesn't-hang { ... }
    my $ความสงบ = 42;
    my \Δ = 72; say 72 - Δ;

## C«->» 方法调用

如果你有读过 Perl 6的代码，一个最明显的地方就是方法调用语法现在使用点替代了箭头：

    $person->name  # Perl 5
    $person.name   # Perl 6

点符号即容易书写又更加符合行业标准，不过我们也想赋予箭头别的使命（字符串连接现在使用`~`运算符）。
对于直到运行时期才知道名字的方法调用：

    $object->$methodname(@args);  # Perl 5
    $object."$methodname"(@args); # Perl 6

如果你省略了双引号，那么 Perl 6会认为  `$methodname` 包含一个 `Method` 对象，而不是简单的方法名字字符串。

## 空白

Perl 5在允许空白的使用上有着惊人的灵活性，即使处于严格模式（strict mode）并且打开警告（warnings)时：

    # 不符合习惯，但是在 Perl 5是可以的
    say"Hello ".ucfirst  ($people
        [$ i]
        ->
        name)."!"if$greeted[$i]<1;

Perl 6也支持程序员书写自由和代码的创造性，但是权衡语法灵活性和其一致性、确定性、可扩展的grammar，
支持一次解析以及有用的错误信息，集成如自定义运算符的特性，并且不会导致程序员误用的设计目标，
并且， “code golf”的做法也很重要，Perl 6的设计在概念上更简洁而不是击键上。

因此，在 Perl 5的语法的许多地方空白都是可选的，但在 Perl 6里可能是强制的或者禁止的，
这些限制中 的许多不太可能关系到现实生活中的 Perl 代码（举例来说，sigil 和变量名字之间的空格被禁止了），
但是有一些可能不太幸运的和一些 Perl hacker的编程习惯风格相冲突:

- _参数列表的开括号之前不允许包含空白_

        substr ($s, 4, 1); # Perl 5 (这在 Perl 6 意味着传递了一个列表参数)
        substr($s, 4, 1);  # Perl 6
        substr $s, 4, 1;   # Perl 6 - 替代括号的风格

- _关键字后面要紧跟空白_

        my($alpha, $beta);          # Perl5 这在 Perl6里面将尝试调用例程my()
        my ($alpha, $beta);         # Perl 6

        if($a < 0) { ... }          # Perl 5, perl6中抛出异常
        if ($a < 0) { ... }         # Perl 6
        if $a < 0 { ... }           # Perl 6, 更符合习惯

        while($x-- > 5) { ... }     # Perl 5, perl6中抛出异常
        while ($x-- > 5) { ... }    # Perl 6
        while $x-- > 5 { ... }      # Perl 6, 更符合习惯

- _前缀运算符后面或者后缀运算符、后缀环绕运算符（包含数组、哈希下标运算符）的前面不允许包含空白。_

        $seen {$_} ++; # Perl 5
        %seen{$_}++;   # Perl 6

- _方法调用运算符周围不允许出现空白：_

        $customer -> name; # Perl 5
        $customer.name;    # Perl 6

- _中缀运算符在可能和存在的后缀运算符或者后缀环绕运算符冲突时前面要包含空白：_

        $n<1;   # Perl 5 (在 Perl 6里面可能和后缀环绕运算符 < > 冲突)
        $n < 1; # Perl 6

    不过，你可以使用[unspace](https://design.perl6.org/S02.html#Unspaces)在Perl6
    的不允许使用空白的代码处增加空白：

        # Perl 5
        my @books = $xml->parse_file($file)          # 注释
                        ->findnodes("/library/book");

        # Perl 6
        my @books = $xml.parse-file($file)\          # 注释
                        .findnodes("/library/book");

    参考Perl6相关设计文档 [S03#Minimal whitespace
    DWIMmery](https://design.perl6.org/S03.html#Minimal_whitespace_DWIMmery) 和
    [S04#Statement parsing](https://design.perl6.org/S04.html#Statement_parsing).

## Sigils

在 Perl 5中，数组和哈希使用的 sigils 取决于怎样访问它们。 在 Perl 6里面，
不论变量怎样被使用，sigils 是不变的 - 你可以把他们作为变量名字的一部分
（参考[#Dereferencing](https://metacpan.org/pod/#Dereferencing)）。

### `$` 标量

`$`标识符现在总是和“标量”变量一起使用（比如`$name`），不再用于 
[array indexing](https://metacpan.org/pod/#[]_Array_indexing#slicing)以及[Hash
indexing](https://metacpan.org/pod/#{}_Hash_indexing#slicing)。 这就是说，你仍然可以使用`$x[1]`和 `$x{"foo"}`，
但是它们是作用在$x上，并不会对相似名字的@x和%x有影响，它们现在可以通过@x\[1\]和%x{"foo"}
来访问。

### `@` 数组

`@`标识符现在总是和“数组”变量一起使用（比如 @month，@month\[2\]，@month\[2,4\]）， 
不再用于 [value-slicing
hashes](https://metacpan.org/pod/#{}_Hash_indexing#slicing)切片。

### `%` 哈希

`%`标识符现在总是和“哈希”变量一起使用（比如`%calories`,
`%calories<apple`>, `%calories<pear plum`>），
不再用于[key/value-slicing arrays](https://metacpan.org/pod/#[]_Array_indexing#slicing)切片。

### `&` 例程

`&`标识符现在始终（并且不再需要反斜杠了）引用一个命名子例程/运算符的函数对象并不会执行
它们， 换句话说，把函数名字当作“名词”而不是“动词”：

    my $sub = \&foo; # Perl 5
    my $sub = &foo;  # Perl 6

    callback => sub { say @_ }  # Perl 5 - 不能直接传递内建过程
    callback => &say            # Perl 6 -  & 给出任何过程的“名词”形式

因为 Perl 6一旦完成编译就不允许在作用域内添加/删除符号，所以 Perl 6并没有与 Perl 5中`undef &foo;`;
 等效的语句，并且最接近Perl5的`undef &foo;`是`defined &::("foo")`（这使用了“动态符
号查找(dynamic symbol lookup)”语法）。 然而，你可以使用 my &amp;foo; 声明一个可修改名字的子例程，
然后在运行过程中向`&foo`赋值改变它。

在 Perl 5中，`&`标识符还可以用来以特定的方式调用子例程，这和普通的过程调用有些许不同，
在 Perl 6中 这些特殊的格式不再可用：

- `&foo(...)` _规避函数原型_

    在 Perl 6中不再有原型了，对你来说，这和传递一个代码块或者一个持有代码对象的变量作为参数
    没有什么不同：

        # Perl 5:
        first_index { $_ > 5 } @values;
        &first_index($coderef, @values); # (禁止原型并且传递一个代码块作为第一个参数)
        # Perl 6:
        first { $_ > 5 }, @values, :k;   # :k 副词使第一个参数返回下标
        first $coderef, @values, :k;

- `&foo;`_和_`goto &foo;`_用来重用调用者的参数列表或者替换调用栈的调用者_

        sub foo { say "before"; &bar;     say "after" } # Perl 5
        sub foo { say "before"; bar(|@_); say "after" } # Perl 6 -需要显式传递

        # TODO: 建议使用Rakudo中的 .callsame

        sub foo { say "before"; goto &bar } # Perl 5

        # TODO: 建议使用Rakudo中的 .nextsame 或者 .nextwith

### `*` Glob

TODO: 对perl5 typeglobs中那些用例目前确切是需要地，并且对这部分反射机制
列出（翻译）需要更进一步的研究。

在 Perl 5中，`*`标识符 指向一个GLOB结构，继而Perl可以使用它存储非词法变量，
文件句柄， 过程，还有格式（？formats）。 （不要和 Perl 5的用来读取目录中的
文件名的内建函数`glob()`混淆了）。

你最可能在不支持词法文件句柄，但需要传递文件句柄到过程时的早期 Perl 版本代码中与 GLOB 邂逅：

    # Perl 5 - 老方法
    sub read_2 {
        local (*H) = @_;
        return scalar(<H>), scalar(<H>);
    }
    open FILE, '<', $path or die;
    my ($line1, $line2) = read_2(*FILE);

在翻译到适合Perl6的代码前，你可能需要重构你的 Perl5代码以移除对 GLOB的依赖：

    # Perl 5 - 词法文件句柄的更现代的用法
    sub read_2 {
        my ($fh) = @_;
        return scalar(<$fh>), scalar(<$fh>);
    }
    open my $in_file, '<', $path or die;
    my ($line1, $line2) = read_2($in_file);

然后这是可能的一个 Perl6翻译代码：

    # Perl 6
    sub read-n($fh, $n) {
        return $fh.get xx $n;
    }
    my $in-file = open $path or die;
    my ($line1, $line2) = read-n($in-file, 2);

## \[\] 数组索引/切片

现在，数组的索引和切片不再改变变量的[sigil](https://metacpan.org/pod/#@_Array)， 并且在还可以使用副词
控制切片的类型：

- _Indexing_

        say $months[2]; # Perl 5
        say @months[2]; # Perl 6 - 用@而非$

- _Value-slicing_

        say join ',', @months[6, 8..11]; # Perl5和Perl6

- _Key/value-slicing_

        say join ',', %months[6, 8..11];    # Perl 5
        say join ',', @months[6, 8..11]:kv; # Perl 6 - @而非%; 用:kv副词

    还有注意下标括号现在并不是一个特殊的语法形式，而是一个普通的后缀环绕运算符，
    因此检测元素是否存在和删除元素使用副词完成。

## {} 哈希索引/切片

现在，哈希的索引和切片不再改变变量的[sigil](https://metacpan.org/pod/#%_Hash)， 并且在还可以使用副词
控制切片的类型。 还有，花括号中的单词下标不再自动引用（即自动在两边加上双引号），
作为替代，总是自动引用其内容的新 的尖括号版本是可用的（使用和`qw//`引用构造
相同的规则）

- _Indexing_

        say $calories{"apple"}; # Perl 5
        say %calories{"apple"}; # Perl 6 - %而非$

        say $calories{apple};   # Perl 5
        say %calories<apple>;   # Perl 6 - 尖括号，% 替代 $
        say %calories«"$key"»;  # Perl 6 - 双尖括号内插作为一个Str列表

- _Value-slicing_

        say join ',', @calories{'pear', 'plum'}; # Perl 5
        say join ',', %calories{'pear', 'plum'}; # Perl 6 - %而非@
        say join ',', %calories<pear plum>;      # Perl 6 （更好的版本）
        my $keys = 'pear plum';
        say join ',', %calories«$keys»;          # Perl 6 - 在内插之后完成切分

- _Key/value-slicing_

        say join ',', %calories{'pear', 'plum'};    # Perl 5
        say join ',', %calories{'pear', 'plum'}:kv; # Perl 6 - 使用 :kv 副词
        say join ',', %calories<pear plum>:kv;      # Perl 6 (更好的版本)

    还有注意下标花括号现在不再是一个特殊的语法形式，而是一个普通的后缀环绕运算符，
    因此检测键是否存在和键移除使用副词完成。

## 引用的创建

在 Perl 5中，引用一个匿名数组和哈希以及过程的在它们创建的时候返回，引用一个
存在的命名变量和过程使用 `\`运算符完成。

在 Perl 6中，匿名数组和哈希以及过程依然在它们创建的时候返回，引用一个命名的
过程需在它们的名字前面加一个`&`标识符， 引用一个存在的命名变量使用`item`上下文：

    my $aref = [ 1, 2, 9 ];          # 使用于perl5&6
    my $href = { A => 98, Q => 99 }; # 使用于perl5&6 [*See Note*]

    my $aref =     \@aaa  ; # Perl 5
    my $aref = item(@aaa) ; # Perl 6

    my $href =     \%hhh  ; # Perl 5
    my $href = item(%hhh) ; # Perl 6

    my $sref =     \&foo  ; # Perl 5
    my $sref =      &foo  ; # Perl 6

**NOTE:**如果一个或者多个值引用了主题变量`$_`，等号右侧的值将被视为[Block](#type-block)，
 而不是哈希：

    my @people = [
        %( id => "1A", firstName => "Andy", lastName => "Adams" ),
        %(id => "2B", firstName => "Beth", lastName => "Burke" ),
        # ...
    ];

    sub lookup-user (Hash $h) { #`(Do something...) $h }

    my @names = map {
        my $query = { name => "$_<firstName> $_<lastName>" };
        say $query.WHAT;       # (Block)
        say $query<name>;      # ERROR: Type Block does not support associative indexing

        lookup-user($query);   # Type check failed in binding $h; expected Hash but got Block
    }, @people;

作为替代，你应该：

- 1) 使用`%()`构造器:

        my $query = %( name => "$_<firstName> $_<lastName>" );

- 2) 直接赋值给哈希类型:

        my %query = name => "$_<firstName> $_<lastName>";   # No braces required

- 或者 3) 给主题变量显式指定一个名字完全避免这个问题:

        my @names = @people.map: -> $person {
            lookup-user( %( name => "$person<firstName> $person<lastName>" ) );
        };

    更多信息请参考[Hash assignment](#type-hash-hash_assignment)。

## 解引用

在Perl5中，对一整个引用解引用的语法是使用类型标识符 和花括号，引用放在花括号里面。
在Perl6中，由花括号变为了圆括号：

    # Perl 5
        say      ${$scalar_ref};
        say      @{$arrayref  };
        say keys %{$hashref   };
        say      &{$subref    };

    # Perl 6
        say      $($scalar_ref);
        say      @($arrayref  );
        say keys %($hashref   );
        say      &($subref    );

注意到在Perl5和Perl6中，围绕的花括号或者括弧都经常被省略，虽然省略降低了易读性。
在 Perl 5中，箭头运算符C«->»，用来单次访问复合引用或者通过引用调用一个过程， 
在 Perl 6中，我们使用点运算符`.`完成这一任务：

    # Perl 5
        say $arrayref->[7];
        say $hashref->{'fire bad'};
        say $subref->($foo, $bar);

    # Perl 6
        say $arrayref.[7];
        say $hashref.{'fire bad'};
        say $subref.($foo, $bar);

在最近的 Perl 5版本（5.20或者以后），一个新的特性允许使用箭头运算符解引用， 参见
[http://search.cpan.org/~shay/perl-5.20.1/pod/perl5200delta.pod#实验性的后缀解引用](http://search.cpan.org/~shay/perl-5.20.1/pod/perl5200delta.pod#实验性的后缀解引用)，
这个新特性和 Perl 6中的`.list`以及`.hash`方法对应：

    # Perl 5.20
        use experimental qw< postderef >;
        my @a = $arrayref->@*;
        my %h = $hashref->%*;
        my @slice = $arrayref->@[3..7];

    # Perl 6
        my @a = $arrayref.list;         # 或 @($arrayref)
        my %h = $hashref.hash;          # 或 %($hashref)
        my @slice = $arrayref[3..7];

“Zen”切片可以有同样的效果：

    # Perl 6
        my @a = $arrayref[];
        my %h = $hashref{};

参考[S32/Containers](https://design.perl6.org/S32/Containers.html)

# 操作符

更多运算符细节请参见[S03/Operators](https://design.perl6.org/S03.html#Overview)

为变化的操作符:

=item `+` 数值加法
=item `-` 数值减法
=item `*` 数值乘法
=item `/` 数值除法
=item `%` 求余
=item `**` 幂，开方
=item `++` 自增
=item `--` 自减
=item `! && || ^` 逻辑运算符,高优先级
=item `not and or xor`   逻辑运算符,低优先级
=item C«== != < > <= >=»   数值比较
=item `eq ne lt gt le ge` 字符比较

## C<,> 列表分割符

  未变化，但是要注意为了把一个数组变量展开为一个列表（为了对其前后添加更多元素）
应该使用 C<|>操作符。例如:

     my @numbers = (100, 200, 300);
     my @more_numbers = (500, 600, 700);
     my @all_numbers = [|@numbers, 400, |@more_numbers];

这样就可以可以合并数组，方便实现需求。

## C«<=> cmp» 三目运算符

在 Perl 5，这些运算符返回 -1，0 或者 1，而在 Perl 6，它们返回值对应的是 
`Order::Less`, `Order::Same`和`Order::More`。

C«cmp»现在用C«leg»替换;它只适用于字符串上下文比较.

C«<=>» 仍然强制用于数值上下文.

C«cmp» 在 Perl 6中同时具备C«<=>»和`leg`功能,具体取决于类型和参数.

## `~~` 智能匹配

运算符本身没有改变，实际匹配的内容规则依赖于参数的类型，不过 Perl6中的这些
规则跟Perl5有很大不同。请参考:L<~~|/routine/~~>和
[S03/Smart matching](https://design.perl6.org/S03.html#Smart_matching)

### 注释

和Perl5一样正则注释，比如.

    / word #`(match lexical "word") /

## `& | ^` 字符串位运算符
=head2 `& | ^` 数值位运算符
=head2 `& | ^` 逻辑运算符

在 Perl 5中， `& | ^`的行为依赖于参数的内容，比如，\`31|33 的返回值和`"31" |
"33"`是不同的。

在 Perl 6中，这些单字符运算符都被移除了，替代它们的是可以强制把参数转换到
需要的内容的双字符运算符。

    # 中缀运算符 （两个参数，左右各一个）
    +&  +|  +^  按位和按位或按位异或：数值
    ~&  ~|  ~^  按位和按位或按位异或：字符串
    ?&  ?|  ?^  按位和按位或按位异或：逻辑

    # 前缀运算符 （一个参数，在运算符后）
    +^  非: 数值
    ~^  非: 字符串
    ?^  非: 布尔型（作用和!运算符一样)

## C«<< >>»  数值左|右移位运算符

    被+<和 +>取代。

       say 42 << 3; # Perl 5
       say 42 +< 3; # Perl 6

## C«=>» 胖逗号

在Perl5中，C«=>»的行为就像一个逗号，但是会自动引用（即加上双引号）左边的参数。

在Perl6中，C«=>»是Pair运算符，这是最主要的不同，但是在许多情况下行为都和 
Perl5中相同。

在哈希初始化时，或者向一个期望哈希引用的方法传递一个参数时，C«=>»的用法就是相同的：

    # 同时适用于Perl5&6
    my %hash = ( AAA => 1, BBB => 2 );
    get_the_loot( 'diamonds', { quiet_level => 'very', quantity => 9 }); # 注意花括号

在为了不再引用（两边加上双引号）列表的一部分而使用C«=>»作为一种便利的方式时，
或者向一个期望键， 值，键，值这样的平坦列表的方法传递参数时，继续使用C«=>»
可能会破坏你的代码，最简单的解决方法就 是将胖逗号改为普通的逗号，然后在引用
左边的参数。 

或者，你可以将方法的接口改为L<slurp a hash|/type/Signature#Slurpy_(A.K.A._Variadic)_Parameters>.
一个比较好的解决方法是方法的接口改为期望 L<Pair|/type/Pair>；
但是，这需要你立即改动所有的方法调用代码。

    # Perl 5
    sub get_the_loot {
        my $loot = shift;
        my %options = @_;
        # ...
    }
    # 注意 这个方法调用中没有使用花括号
    get_the_loot( 'diamonds', quiet_level => 'very', quantity => 9 );
    # Perl 6, 接口改为指定有效的选项
    sub get_the_loot( $loot, *%options ) # *意味着接受任何东西
        ...
    }
    get_the_loot( 'diamonds', quiet_level => 'very', quantity => 9 ); # 注意 这个方法调用中没有使用花括号
    
    # Perl 6中，接口改为指定有效的选项
    # sigil 前面的冒号代表期望一个 Pair
    # 参数的键名字和变量相同
    
    sub get_the_loot( $loot, :$quiet_level?, :$quantity = 1 ) {
        # This version will check for unexpected arguments!
        ...
    }
    get_the_loot( 'diamonds', quietlevel => 'very' ); # 参数名字拼写错误，将会抛出一个错误

## `? :` 条件运算符

条件运算符 C<? :>被C<?? !!>取代。

    my $result = ( $score > 60 )  ? 'Pass'  : 'Fail'; # Perl 5
    my $result = ( $score > 60 ) ?? 'Pass' !! 'Fail'; # Perl 6

## `.` 连接运算符

被波浪线替代。

小贴士：想象一下使用针和线“缝合”两个字符串。

    $food = 'grape' . 'fruit'; # Perl 5
    $food = 'grape' ~ 'fruit'; # Perl 6

## `x` 列表或者字符串重复运算符

在 Perl 5，C<x>是重复运算符,在标量和列表两种上下文中表现不同。

- 在标量上下文,C<x>将会重复一个字符串。在 Perl 6里，C<x>会在任何上下文重复字符串。
- 在列表上下文，C<x>当且仅当将列表括入圆括号中时重复当前列表.

在Perl 6，用两种不同运算符表示以上两种行为:

- C<x>重复一个字符串(任何上下文)。
- C<xx> 在任何上下文重复列表。

小贴士：xx相对于x是比较长的，所以xx适用于列表。

    # Perl 5
        print '-' x 80;             # 打印出一行横杠
        @ones = (1) x 80;           # 一个含有80个1的列表
        @ones = (5) x @ones;        # 把所有元素设为5
    # Perl 6
        print '-' x 80;             # 无变化
        @ones = 1 xx 80;            # 不再需要圆括号
        @ones = 5 xx @ones;         # 不再需要圆括号

## `..` `...` 双点、三点、范围以及翻转运算符

在 Perl 5,`..`依赖于上下文是两个完全不同的运算符。

在列表上下文,`..` 是熟悉的范围运算符，范围运算在 Perl 6有许多新的改变，
不过 Perl 5的范围运算代码不需要翻译。

在标量上下文，`..`和`...`是鲜为人知的翻转运算符，在 Perl 6中它们被
`ff`和 `fff`取代了。

## 字符串内插

在 Perl 5，`"${foo}s"`将变量名从普通的文本中分离出来，
在 Perl 6中，简单的将花括号扩展到sigil外即可： `"{$foo}s"`。

# 复合语句

## 条件语句

### `if` `elsif` `else` `unless`

除了条件语句两边的括号现在是可选的，这些关键字几乎没有变化，但是如果要使用括号，
一定不要紧跟着关键字， 否则这会被当作普通的函数调用，绑定条件表达式到一个变量
也稍微有点变化：

    if (my $x = dostuff()) {...}  # Perl 5
    if dostuff() -> $x {...}      # Perl 6

（在Perl6中你可以继续使用`my`格式，但是它的作用域不再位于语句块的内部，而是外部。）

在Perl6中`unless`条件语句只允许单个语句块，不允许 `elsif`或者`else`子语句。

### `given`-`when`

`given`-`when`结构类似于if-elsif-else语句或者C里面的`switch`-`case`结构。 它的普通
样式是：

    given EXPR {
        when EXPR { ... }
        when EXPR { ... }
        default { ... }
    }

根据这个最简单的样式，有如下代码：

    given $value {
        when "a match" {
            do-something();
        }
        when "another match" {
            do-something-else();
        }
        default {
            do-default-thing();
        }
    }

这是在`when`语句中简单的使用标量匹配的场景，更普遍的实际情况都是利用如正则表达式一般的
复杂的实体等替代标量数据对输入数据进行智能匹配。

同时参阅文章上面的智能匹配操作。

## 循环

### `while` `until`

除了循环条件两边的括号现在是可选的，这些关键字几乎没有变化，但是如果要使用括号，一定不要
紧跟着关键字， 否则这会被当作普通的函数调用，绑定条件表达式到一个变量也稍微有点变化：

    while (my $x = dostuff()) {...}  # Perl 5
    while dostuff() -> $x {...}      # Perl 6

（在Perl6中你可以继续使用`my`格式，但是它的作用域不再位于语句块的内部，而是外部。）

注意对文件句柄按行读取发生了变化。

在Perl5，这可以利用钻石运算符在`while`循环里面完成，如果使用`for`替代`while`则会有一个
常见的bug，因为`for`导致文件被一次性读入，使程序的内存使用变的很糟糕。

在 Perl 6，`for`语句是惰性的（lazy），所以我们可以在`for`循环里面使用`.lines`方法逐行读取文件：

    while (<IN_FH>)  { } # Perl 5
    for $IN_FH.lines { } # Perl 6

### `do` `while`/`until`

    do {
        ...
    } while $x < 10;

    do {
        ...
    } until $x >= 10;

这种结构存在，只不过为了更好的体现这种结构的意义,`do`现在替换成了`repeat`：

    repeat {
        ...
    } while $x < 10;

    repeat {
        ...
    } until $x >= 10;

### `for` `foreach`

首先注意这有一个常见的对`for`和`foreach`关键字的误解，许多程序员认为它们是把
三段表达式的C-风格和列表迭代方式区分开来，然而并不是！ 实际上，它们是可互换的，
Perl5的编译器通过查找后面的分号来决定解析成哪一种循环。

Perl6 C-风格的for循环用`loop`关键字，其它都没有变化，两边的括号是必须的：

    for  ( my $i = 1; $i <= 10; $i++ ) { ... } # Perl 5
    loop ( my $i = 1; $i <= 10; $i++ ) { ... } # Perl 6

循环结构C<for>或C<foreach>在Perl 6中统一为C<for>，C<foreach>不再是一个关键字，C<for>规则如下：

- 括号是可选的。
- 迭代变量，如果有的话，已经从列表的前部移动到列表的后面，变量之前还有加上箭头运算符。
- 迭代变量，现在是词法变量，C<my>不载需要，且不允许使用。
- 迭代变量是当前列表元素的别名，是只读的（Perl5中别名可读写），除非你将 C«->»改为C«<->»。
做老代码迁移的时候，检查循环变量，决定是否需要可读写。

    for my $car (@cars)  {...} # Perl 5; 读写
    for @cars  -> $car   {...} # Perl 6; 只读
    for @cars <-> $car   {...} # Perl 6; 读写

如果使用默认的变量 C<$_>，但是又需要可读写，那么需要使用C«<->»并显示指定变量为 C«$_»。

    for (@cars)      {...} # Perl 5; $_可读写
    for @cars        {...} # Perl 6; $_ 只读
    for @cars <-> $_ {...} # Perl 6; $_ 可读写

我们也能在每次循环中取多个元素，只需在箭头后面添加多个变量即可。

```
my @array = 1..10;
for @array -> $first, $second {
    say "First is $first, second is $second";
}
```
#### `each`

这是Perl6中和Perl5 `while…each(%hash)`或者`while…each(@array)`（遍历数据结构的键或者索引和值）
等同的用法：

    while (my ($i, $v) = each(@array)) { ... } # Perl 5
    for @array.kv -> $i, $v { ... } # Perl 6

    while (my ($k, $v) = each(%hash)) { ... } # Perl 5
    for %hash.kv -> $k, $v { ... } # Perl 6

## 流程控制

未变化的:

- `next`
=item `last`
=item `redo`

### `continue`

`continue`语句块已经被去掉了，做为替代，在循环体中使用`NEXT`语句块：

    # Perl 5
        my $str = '';
        for (1..5) {
            next if $_ % 2 == 1;
            $str .= $_;
        }
        continue {
            $str .= ':'
        }
    # Perl 6
        my $str = '';
        for 1..5 {
            next if $_ % 2 == 1;
            $str ~= $_;
            NEXT {
                $str ~= ':'
            }
        }

# 函数

## 内建函数与纯代码块

内建函数之前接受一个纯的代码块，不用在其他参数之前添加逗号，现在需要在块和参数
之间插入一个逗号，比如 `map`, `grep`等等。

    my @results = grep { $_ eq "bars" } @foo; # Perl 5
    my @results = grep { $_ eq "bars" }, @foo; # Perl 6

## `delete`

被转换为[`{}`哈希下标运算符](https://metacpan.org/pod/{}_Hash_indexing#slicing)以及[`[]`数组下标运算符](https://metacpan.org/pod/#[]_Array_indexing#slicing)
的副词。

    my $deleted_value = delete $hash{$key};  # Perl 5
    my $deleted_value = %hash{$key}:delete;  # Perl 6 - use :delete副词

    my $deleted_value = delete $array[$i];  # Perl 5
    my $deleted_value = @array[$i]:delete;  # Perl 6 - use :delete副词

## `exists`

被转换为[`{}`哈希下标运算符](https://metacpan.org/pod/#{}_Hash_indexing#slicing) 以及[`[]`数组下标运算符](https://metacpan.org/pod/#[]_Array_indexing#slicing)
的副词。

    say "element exists" if exists $hash{$key};  # Perl 5
    say "element exists" if %hash{$key}:exists;  # Perl 6 - use :exists副词

    say "element exists" if exists $array[$i];  # Perl 5
    say "element exists" if @array[$i]:exists;  # Perl 6 - use :exists副词

# 正则表达式

## `=~`和`!~`替换为`~~`和`!~~` .

在 Perl5对变量的匹配和替换是使用`=~`正则绑定运算符完成的。
在 Perl6中使用智能匹配运算符`~~`替代。

    next if $line  =~ /static/  ; # Perl 5
    next if $line  ~~ /static/  ; # Perl 6

    next if $line  !~ /dynamic/ ; # Perl 5
    next if $line !~~ /dynamic/ ; # Perl 6

    $line =~ s/abc/123/;          # Perl 5
    $line ~~ s/abc/123/;          # Perl 6

同样的，新的`.match`方法以及`.subst`方法可以被使用。 注意`.subst`是不可变操作，参见
[S05/Substitution](https://design.perl6.org/S05.html#Substitution).

## 捕捉变量以0开始, 而不是1

    /(.+)/ and print $1; # Perl 5
    /(.+)/ and print $0; # Perl 6

## 移动修饰符

将所有的修饰符的位置从尾部移动到了开始，这可能需要你为普通的匹配比如C«/abc/»添加可选的`m`。

    next if $line =~    /static/i ; # Perl 5
    next if $line ~~ m:i/static/  ; # Perl 6

## 增加:P5 或者 :Perl5副词

如果实际的正则表达式比较复杂，你可能不想做修改直接使用，那么就加上`P5`副词吧。

    next if $line =~    m/[aeiou]/   ; # Perl 5
    next if $line ~~ m:P5/[aeiou]/   ; # Perl 6, 使用:P5副词
    next if $line ~~ m/  <[aeiou]> / ; # Perl 6, 新的风格

## 特殊的匹配语法通常属于<>的语法

Perl 5的正则语法支持很多特殊的匹配语法，它们不会全部列在这里，但是一般在断言中作为`()`的替代的是C«<>»。

对于字符类，这意味着：

- `[abc]` 变成 C«<\[abc\]>»
- `[^abc]` 变成 C«<-\[abc\]>»
- `[a-zA-Z]` 变成 C«<\[a..zA..Z\]>»
- `[[:upper:]]` 变成 C«<:Upper>»
- `[abc[:upper:]]` 变成 C«<\[abc\]+:Upper>»

    对于环视（look-around）断言:

- `(?=[abc])` 变成 C«&lt;?\[abc\]>»
- `(?=ar?bitrary* pattern)` 变成 C«&lt;before ar?bitrary\* pattern>»
- `(?!=[abc])` 变成 C«&lt;!\[abc\]>»
- `(?!=ar?bitrary* pattern)` 变成 C«&lt;!before ar?bitrary\* pattern>»
- C«(?<=ar?bitrary\* pattern)» 变成 C«&lt;after ar?bitrary\* pattern>»
- C«(?&lt;!ar?bitrary\* pattern)» 变成 C«&lt;!after ar?bitrary\* pattern>»

    （跟<>语法无关，环视语法`/foo\Kbar/`变成了C«/foo <( bar )> /»）

- `(?(?{condition))yes-pattern|no-pattern)` 变成 C«\[ &lt;?{condition}>
      yes-pattern | no-pattern \]»

## 令牌最长匹配（LTM）取代多选一

在 Perl6的正则中,`|`用于LTM，也就是根据一组基于模糊匹配规则从结果中选择
一个最优的结果，而不是位置优先。

对于 Perl 5代码最简单解决方案就是使用`||`替代`|`。

但是，如果基于设计上或者由于疏忽等的原因导致你的C<||>正则是继承于或者是由
C<|>片段的正则组成的，结果不可预期。所以对一些复杂地匹配，你必须对两种语法
都熟悉，特别是了解LTM的工作策略的时候。另外C<|> 语法重用可能是个更好的选择。

更多规则. 请使用来自模块[`translate_regex.pl` from Blue
Tiger](https://github.com/Util/Blue_Tiger/)。

# 编译指示（Pragmas）

### `strict`

默认启用规则。

### `warnings`

默认启用规则。

`no warnings`目前还是[NYI](#language-glossary-nyi)状态， 但是把语句放到{}块之内就可以避免警告。

### `autodie`

这个功能可以让程序在发生错误抛出异常，现在Perl6默认抛出异常，除非你显式的测试返回值。

    # Perl 5
    open my $i_fh, '<', $input_path;  # 错误时保持沉默
    use autodie;
    open my $o_fh, '>', $output_path; # 错误时抛出异常

    # Perl 6
    my $i_fh = open $input_path,  :r; # 错误时抛出异常
    my $o_fh = open $output_path, :w; # 错误时抛出异常

### `base`
=head3 `parent`

现在`use base`和`use parent`已经被 Perl 6中的 `is`关键字取代，用在类的声明中。

    # Perl 5
    package Cat;
    use base qw(Animal);

    # Perl 6
    class Cat is Animal;

### `bigint` `bignum` `bigrat`

不再有相应的类型了。

`Int`现在是无限精度的，是 `Rat`类型的分子（分母最大可以是`2**64`，出于性能考虑之后会
自动转换为`Num`类型）。 如果你想使用无限精度分母的`Rat`那么`FatRat`显然是最适合的。

### 

`constant`在Perl6用来变量声明，这类似与`my`，不过变量会锁定保持第一次初始化的值不变
（在编译时期求值）。

那么，将C«=>»改为`=`，并加上一个sigil。

    use constant DEBUG => 0; # Perl 5
    constant DEBUG = 0;      # Perl 6

    use constant pi => 4 * atan2(1, 1); # Perl 5
    # pi, e, i都是 Perl 6的内建变量

### `encoding`

允许使用非ASCII或者非UTF8编码编写代码。

### `integer`

Perl的编译指示，使用整数运算替代浮点。

### `lib`

在编译时期操作 @INC。

### `mro`

不再有意义。

在Perl6中，方法调用现在使用 C3 方法调用顺序。

### `utf8`

不再有意义。

在Perl6中，源代码将使用utf8编码。

### `vars`

在Perl5中不再建议使用，参见[http://perldoc.perl.org/vars.html](http://perldoc.perl.org/vars.html).

在翻译到Perl6代码之前，你可能需要重构你的代码移除对`use vars`的使用

# 命令行标记

查看
[S19/commandline](https://design.perl6.org/S19.html#Command_Line_Elements)

为变化的:

\-c -e -h -I -n -p -S -T -v -V

### `-a`

在Spec中没有变化，但是在Rakudo中还没有实现。

现在你需要手动调用`.split`。

### `-F`

在Spec中没有变化，但是在Rakudo中同样还没有实现。

现在你需要手动调用`.split`。

### `-l`

现在默认选项，不需要显示指定。

### `-M` `-m`

只有`-M`还存在，还有，大家可以不再使用“no Module”语法了，`-M`的“no”模块操作不再可用。

### `-E`

因为所有的特性都已经开启，请使用小写的`-e`。

### `-d`, `-dt`, `-d:foo`, `-D`,等等.

被 ++BUG 元语法替代。

### -s

开关选项解析现在被 `MAIN`子例程的参数列表替代。

    # Perl 5
        #!/usr/bin/perl -s
        if ($xyz) { print "$xyz\n" }
    ./example.pl -xyz=5
    5

    # Perl 6
        sub MAIN( Int :$xyz ) {
            say $xyz if $xyz.defined;
        }
    perl6 example.p6 --xyz=5
    5
    perl6 example.p6 -xyz=5
    5

- `-t`

    现在还没有指定。

- `-P` `-u` `-U` `-W` `-X`

    已移出，详情请看[S19#Removed Syntactic
    Features](https://design.perl6.org/S19.html#Removed_Syntactic_Features).

- `-w`

    现在默认开启。

# 文件相关操作符

## 按行读取文本文件到数组

在Perl5，读取文本文件的行通常是这样子：

    open my $fh, "<", "file" or die "$!";
    my @lines = <$fh>;
    close $fh;

在Perl6，这简化成了这样：

    my @lines = "file".IO.lines;

不要尝试一次读入一个文件，然后使用换行符分割，因为这会导致数组尾部含有一个空行，
比你想象的多了一行（它实际更复杂一些）。比如：

    # 初始化要读的文件
    spurt "test-file", q:to/END/;
    first line
    second line
    third line
    END
    # 读文件
    my @lines = "test-file".IO.slurp.split(/\n/);
    say @lines.elems;    #-> 4

## 捕获可执行文件的标准输出

鉴于在Perl5你可能这么做：

    my $arg = 'Hello';
    my $captured = `echo \Q$arg\E`;
    my $captured = qx(echo \Q$arg\E);

或者使用String::ShellQuote（因为 `\Q…\E`不是完全正确的）：

    my $arg = shell_quote 'Hello';
    my $captured = `echo $arg`;
    my $captured = qx(echo $arg);

在 Perl 6中你可能想不通过shell 运行命令：

    my $arg = 'Hello';
    my $captured = run('echo', $arg, :out).out.slurp-rest;
    my $captured = run(«echo "$arg"», :out).out.slurp-rest;

如果你真的想用 shell 也可以：

    my $arg = 'Hello';
    my $captured = shell("echo $arg", :out).out.slurp-rest;
    my $captured = qqx{echo $arg};

但是当心，这种情况下 **完全没有了保护**!， `run`不使用`shell`执行命令，
所以不需要对参数进行转义（直接进行传递）。 如果你使用`shell`执或者`qqx` ，
那么所有东西都会作为一个长长的字符串传给 shell，除非你小心的 验证你的参数，
否则很有可能因为这样的代码引入 shell 注入漏洞。

# 环境变量

## Perl 模块路径

在Perl5中可以指定 Perl 模块的额外的搜索路径的一个环境变量是`PERL5LIB`：

    $ PERL5LIB="/some/module/lib" perl program.pl

在Perl6中也类似，仅仅需要改变一个数字，正如你想的那样，你只需使用：

    $ PERL6LIB="/some/module/lib" perl6 program.p6

在 Perl5中使用冒号‘:’作为`PERL5LIB`目录的分隔符，但是在Perl6中使用逗号 ‘,’。 比如：

不是

    $ export PERL5LIB=/module/dir1:/module/dir2;

而是

    $ export PERL6LIB=/module/dir1,/module/dir2;

（Perl6不识别`PERL5LIB`或者更老的Perl环境变量`PERLLIB`。）

就Perl6来说，如果你不指定`PERL6LIB`，你需要使用`use lib`编译指示来指定库的路径：

    use lib '/some/module/lib'

注意`PERL6LIB`在Perl6中更多的是给开发者提供便利（与Perl5中的`PERL5LIB`相对应）， 
模块的用户不要使用因为未来它可能被删除，这是因为Perl6的模块加载没有直接兼容操作系统的路径。

# 杂项

## `'0'` 是True

不像Perl5，一个只包含('0')的字符串是True，作为Perl6的核心类型，它有着更多的意义， 
这意味着常见的模式：

    ... if defined $x and length $x; # 或者现代Perl的写法length($x)

在Perl6里面变的更为简化：

    ... if $x;

## `dump`

被移除。
Perl 6的设计允许自动的保存加载编译的字节码。
目前这个功能在 Rakudo 中只支持模块。

## `AUTOLOAD`

[`FALLBACK`方法](/language/typesystem#index-entry-FALLBACK_(method))
提供了类似的功能。

## 导入模块的函数


在Perl5你可以像这样有选择性的导入一个给定模块的函数：

    use ModuleName qw{foo bar baz};

在Perl6，一个想要被导出的函数需要对相关的方法使用`is export`，所有使用`is export`，
的方法都会被导出，因此,下面的模块`Bar`导出了方法`foo`和`bar`，没有导出`baz`：

    unit module Bar;

    sub foo($a) is export { say "foo $a" }
    sub bar($b) is export { say "bar $b" }
    sub baz($z) { say "baz $z" }

使用模块时，简单的`use Bar`即可，现在函数`foo`和`bar`都是可用的：

    use Bar;
    foo(1);    #=> "foo 1"
    bar(2);    #=> "bar 2"

如果你尝试调用`baz`函数，会在编译时报出“未定义的例程”错误。

所以，如何像Perl5那样可选择性的导入一个模块的函数呢？支持这个你需要在模块中
定义`EXPORT`方法来指定导出和删除`module Bar`的声明（注意在Synopsis 11中并没有
`module`语句，然而它可以工作） 。

模块`Bar`现在仅仅是一个叫做 Bar.pm 的文件并含有以下内容：

    use v6.c;

    sub EXPORT(*@import-list) {
        my %exportable-subs =
            '&foo' => &foo,
            '&bar' => &bar,
            ;
        my %subs-to-export;
        for @import-list -> $import {
            if grep $sub-name, %exportable-subs.keys {
                %subs-to-export{$sub-name} = %exportable-subs{$sub-name};
            }
        }
        return %subs-to-export;
    }

    sub foo($a, $b, $c) { say "foo, $a, $b, $c" }
    sub bar($a) { say "bar, $a" }
    sub baz($z) { say "baz, $z" }

注意现在方法已不再使用`is export`显式的导出，我们定义了一个`EXPORT`方法，它指定了
模块可以被导出的方法，并且生成一个包含实际被导出的方法的哈希，`@import-list`是调用
代码中使用`use`语句设置的， 这允许我们可选择性的导出模块中可导出的方法。

所以，为了只导出`foo`例程，我们可以这么使用：

    use Bar <foo>;
    foo(1);       #=> "foo 1"

现在我们发现即使`bar`是可导出的，如果我们没有显式的导出它，它就不会可用，因此下面的代码在 
编译时会引起“未定义的例程”错误：

    use Bar <foo>;
    foo(1);
    bar(5);       # 报错 "Undeclared routine: bar used at line 3"

然而，我们可以这样：

    use Bar <foo bar>;
    foo(1);       #=> "foo 1"
    bar(5);       #=> "bar 5"

注意，`baz`依然是不可导出的即使使用`use`指定：

    use Bar <foo bar baz>;
    baz(3);       # 报错 "Undeclared routine: baz used at line 2"

为了使这个能正常工作，显然需要跨越许多的障碍，在使用标准use的情况下，通过使用`is export`
指定某一个函数是导出的， Perl 6会自动以正确的方式创建 EXPORT 方法，所以你应该仔细的考虑
创建一个自己的 `EXPORT`方法是否值得。

# 核心模块

### `Data::Dumper`

在Perl5，[Data::Dumper](https://metacpan.org/pod/Data::Dumper)模块被用来序列化， 还有程序员
调试的时候用来查看程序数据结构的内容。

在Perl6中，这个任务完全被存在于每一个对象的`.perl`方法替代。

    # 给定:
        my @array_of_hashes = (
            { NAME => 'apple',   type => 'fruit' },
            { NAME => 'cabbage', type => 'no, please no' },
        );
    # Perl 5
        use Data::Dumper;
        $Data::Dumper::Useqq = 1;
        print Dumper \@array_of_hashes; # 注意反斜杠
    # Perl 6
        say @array_of_hashes.perl; # .perl会作用在数组而不是引用上面

在Perl5，Data::Dumper有着更复杂的可选的调用约定， 它支持对变量命名。

在Perl6，将一个冒号放在变量的sigil前面转换它为Pair，Pair的键是变量的名字，值是变量的值。

    # 给定:
        my ( $foo, $bar ) = ( 42, 44 );
        my @baz = ( 16, 32, 64, 'Hike!' );
    # Perl 5
        use Data::Dumper;
        print Data::Dumper->Dump(
            [     $foo, $bar, \@baz   ],
            [ qw(  foo   bar   *baz ) ],
        );
    # 结果
        $foo = 42;
        $bar = 44;
        @baz = (
                 16,
                 32,
                 64,
                 'Hike!'
               );
    # Perl 6
        say [ :$foo, :$bar, :@baz ].perl;
    # 结果
        ["foo" => 42, "bar" => 44, "baz" => [16, 32, 64, "Hike!"]]

### `Getopt::Long`

开关选项解析现在被 MAIN 子方法的参数列表替代。

    # Perl 5
        use 5.010;
        use Getopt::Long;
        GetOptions(
            'length=i' => \( my $length = 24       ), # numeric
            'file=s'   => \( my $data = 'file.dat' ), # string
            'verbose'  => \( my $verbose           ), # flag
        ) or die;
        say $length;
        say $data;
        say 'Verbosity ', ($verbose ? 'on' : 'off') if defined $verbose;
    perl example.pl
        24
        file.dat
    perl example.pl --file=foo --length=42 --verbose
        42
        foo
        Verbosity on

    perl example.pl --length=abc
        Value "abc" invalid for option length (number expected)
        Died at c.pl line 3.

    # Perl 6
        sub MAIN( Int :$length = 24, :file($data) = 'file.dat', Bool :$verbose ) {
            say $length if $length.defined;
            say $data   if $data.defined;
            say 'Verbosity ', ($verbose ?? 'on' !! 'off');
        }
    perl6 example.p6
        24
        file.dat
        Verbosity off
    perl6 example.p6 --file=foo --length=42 --verbose
        42
        foo
        Verbosity on
    perl6 example.p6 --length=abc
        Usage:
          c.p6 [--length=<Int>] [--file=<Any>] [--verbose]

注意到Perl6会在命令行解析出错时自动生成一个完整的用法信息。

# 自动翻译

一个快速的将Perl5代码翻译为Perl6代码的途径就是通过自动化翻译。

**注意:** 这些翻译器都还没有完成.

## Blue Tige

本项目的目致力于自动现代化Perl代码，它没有一个web前端，所以必须
本地安装使用，它还含有一个单独的程序用来将Perl5的正则转换为Perl6的版本。

[https://github.com/Util/Blue\_Tiger/](https://github.com/Util/Blue_Tiger/)

## Perlito

在线翻译器。

本项目是一套Perl跨平台编译器，包含Perl5到Perl6的翻译，它有一个web前端，
所以可以在不 安装的前提下使用，它目前只支持 Perl5语法的一个子集。

[http://fglock.github.io/Perlito/perlito/perlito5.html](http://fglock.github.io/Perlito/perlito/perlito5.html)

## MAD

Larry Wall 自己用来翻译Perl5到Perl6的代码已经太老了，在目前的 Perl5版本
中已经不可用了。

MAD（Misc Attribute Definition）是一个通过源码构建Perl的时候可用的配置选项，
'perl’执行程序分析并翻译你的Perl代码到op-tree，通过遍历op-tree执行你的程序。
通常，这些分析的细节会在处理的时候丢掉，当MAD开启的时候，'perl' 执行程序会
把这些细节保存成XML文件， 然后MAX解析器便可以读取它并进一步处理成 Perl6的代码。

为了进行你的 MAD 实验，请前去 #perl6 频道咨询最适合的Perl5版本。

## Perl-ToPerl6

Jeff Goff的围绕Perl::Critic框架的用于Perl5的模块 Perl::ToPerl6 ，目标是在
最小的修改前提下 将Perl5的代码转换成可编译的 Perl 6代码，代码的转换器是可配置
和插件化的，你可以通过它创建自己 的转换器，根据你的需求自定义存在的转换器。
你可以从CPAN上面获取最新的版本，或者follow发布在GitHub 的工程，在线转换器
可能在某一天会可用。

# 翻译知识的其他来源

- [https://perlgeek.de/en/article/5-to-6](https://perlgeek.de/en/article/5-to-6)
- [https://github.com/Util/Blue\_Tiger/](https://github.com/Util/Blue_Tiger/)
- [https://perl6advent.wordpress.com/2011/12/23/day-23-idiomatic-perl-6/](https://perl6advent.wordpress.com/2011/12/23/day-23-idiomatic-perl-6/)
- [http://www.perlfoundation.org/perl6/index.cgi?perl\_6\_delta\_tablet](http://www.perlfoundation.org/perl6/index.cgi?perl_6_delta_tablet)


