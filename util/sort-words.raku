#!/usr/bin/env raku

=begin overview

Sort words files as expected by xt/words.t

=end overview

my $word-io = $*PROGRAM.parent.parent.child('xt/pws/words.pws').IO;
my $code-io = $*PROGRAM.parent.parent.child('xt/pws/code.pws').IO;

my @word = $word-io.lines;
my @code = $code-io.lines;

my $header = @word.shift;

my $word-out = $word-io.open(:w);
$word-out.say: $header;
$word-out.say: @word.sort.unique.join("\n");

my $code-out = $code-io.open(:w);
$code-out.say: @code.sort.unique.join("\n");
