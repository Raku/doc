# Perl 5到Perl 6指南-概述
# 我怎么能像Perl 5一样的开发?

这些文档不是给一个初学者教程，也不是Perl 6的宣传概述。而是给于有一定
Perl 5 基础的老司机学习Perl6的技术指南。

# Perl 6初步

[Perl 6初步](/language/5to6-nutshell)提供了Perl 6以下各方面的变化，
以供快速预览上手，包括语法、操作符、复合语句、正则、命令行参数以及其他值得提及的内容。

# 语法差异

[Syntax section](/language/5to6-perlsyn) 提供了两者在语法上的差异：
主要格式的顺承、扩展的用法以及Perl 6中独有的语法。

# Perl 6操作符

[操作符部分](/language/5to6-perlop)给我们列出了
L<Perl 5 perlop|https://metacpan.org/pod/distribution/perl/pod/perlop.pod>在Perl 6
中的对应用法。

# Perl 6 函数

[Functions section](/language/5to6-perlfunc) 描述了Perl 5中的所有函数及Perl 6对应用法和差异。
还提供了Perl 6 生态系统模块中Perl 5函数的对应函数，及各语法方面的差异（例如C<shift>），
以及Perl 6删掉的函数（比如 C<tie>）。

# Perl 6特殊变量

[Special Variables section](/language/5to6-perlvar)描述了Perl 6中队Perl 5特殊变量的支持。

# 项目贡献指南:

标题应该包含Perl 5用户可能会搜索的文本，因为这些标题都会展现在生成的内容表顶级目录中。
对于不希望出现在内容表目录中的内容请使用`POD =item`，不要用`=head3` 或 `=head4`。

本文档没有描述新添加的语法，也没有说明可能的改进细节。例如，虽然`0 + $string`也能显示，
但是我们应该使用`+$string`(Blue Tiger 将会提供Perl现代化指南，提供一步一步的翻译程序
以及新成语的详细介绍和更好用的方法）

请提供应该长期支持的示例代码和其他详细细节的链接。

最后，用户实际的P5-> P6还未提及的问题，请添加到相关文档。即便是现在还无法回答问题，
也是值得收集的信息。
