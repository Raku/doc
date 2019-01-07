use v6.c;
use Test;

my $text = 'html/generic-pod.html'.IO.slurp;
$text .= comb( / <?before '<div class="pod-body"'> .+ <?before '<footer'> /);

diag 'plain text';

is $text.subst( / '<' ~ '>' .+? /, '' , :g).comb(/\S+/), 'plain.txt'.IO.slurp, 'plain text as expected';

diag 'format codes';
# C Not all Formating codes get rendered, if for example, they are embedded.
is $text.comb( / '<code>' ~ '</code>' .+? /).elems, 80, 'formatcode-c';
# B
is $text.comb(/ '<strong>' ~ '</strong>' .+? /).elems, 37, 'formatcode-b';


=begin pod
Pod blocks called when processing ｢language/pod｣ are:
	Pod::Block::Para	189
	Pod::FormattingCode｢C｣	82
	Pod::Block::Code	46
	Pod::Heading	39
	Pod::FormattingCode｢B｣	33
	Pod::FormattingCode｢L｣	14
	Pod::Item	12
	Pod::FormattingCode｢Z｣	6
	Pod::Block::Named	6
	Pod::FormattingCode｢I｣	5
	Pod::FormattingCode｢R｣	2
	Pod::FormattingCode｢X｣	2
	Pod::Defn	2
	Pod::FormattingCode｢N｣	2
	Pod::FormattingCode｢E｣	2
	Pod::Block::Table	1
=end pod
