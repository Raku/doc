#!/usr/bin/env raku

use Test;
use Telemetry; # so we can check it

use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin pod
By default, we test all files in 'doc/Type'.  You can specify different files to
test by passing them as arguments to the test.
=end pod

my @doc-files = Test-Files.pods.grep(*.starts-with('doc/Type'));

grammar TypeDocumentation {...}

=begin SYNOPSIS
Check the signatures of documented methods against the Rakudo source code.

For each method documented in a .pod6 file in doc/doc/Type/, this test compares
the documented signature against the signature in the Rakudo source code.
Because we are documenting I<Raku> and not I<Rakudo>, detecting a difference in
the signature does not automatically cause the test to fail: some differences in
signature (such as different names for positional parameters) represent
different implementation choices rather than an error in the docs.

NOTE: when you specify a rakudo source directory using the RAKUDO_SRC environment
variable, this script will attempt to test a specific version by using git checkout
to switch that checkout to a specific version during the test, and run
"git checkout -" at the end to reset the state.

To ensure that implementation details don't cause failing tests, we check only
for certain discrepancies that are guaranteed to indicate a
substantive/non-implementation detail mismatch between Rakudo and the docs.

Currently, we only test for one category of discrepancies:

=item Methods that are defined with a specific invocant in Rakudo but not in the
docs (this helpfully also catches the situation where a documentation signature
was I<intended> to have an invocant, but where someone forgot to end the
invocant with a C<:>)

In the future, this test could be expanded to also check for:

=item arity mismatches
=item different names for named parameters
=item times when the Rakudo code specifies a return constraint but the docs do
not (the inverse situation -- where we specify a return constraint that Rakudo
does not -- would not necessarily represent an error in the docs so long as
the function always does return that type)

=end SYNOPSIS

my $error = "To run check-signatures, please specify the path to the Rakudo git checkout with the RAKUDO_SRC environment variable";
my $rakudo-src-dir = %*ENV<RAKUDO_SRC> // plan(:skip-all( $error ));
when !$rakudo-src-dir.IO.d { plan(:skip-all( $error )) }
when ?(run <git --version>, :out, :err).exitcode { plan(:skip-all( "check-signatures requires git"))}
given $*RAKU.compiler.verbose-config<Raku><version>.split('-') {
    chdir $rakudo-src-dir;
    when .elems == 1 { run (|<git checkout>, |("tags/{.[0]}")), :out, :err}
    when .elems == 3 { run «git checkout {.[2].substr(1..*)}», :out, :err }
}

my token signature { '('[ <-[()]>* <~~> <-[()]>* ]* ')' | '(' <-[()]>* ')' }

plan +@doc-files;
for @doc-files -> $file {
    when $file !~~ /'doc/Type/'[(\w+)'/'?]+'.pod6'/ { skip "'{$file.basename}' doesn't document a type" }
    my $type-name = S/'doc/Type/'[(\w+)'/'?]+'.pod6'/$0.join('::')/ with $file;
    my $type = ::($type-name);
    CATCH { default { skip "$type-name lacks required introspection" } }
    TypeDocumentation.parse($file.IO.slurp);

    subtest "check $type-name methods", {
        plan +$<method>;
        for $<method> { given .<signature-line> -> $line {
            use MONKEY-SEE-NO-EVAL;
            my $method-name = "$type-name\.{$line<name>}";
            CATCH {
                when X::AdHoc && .payload ~~ /'::?'/ { skip "$method-name defined with compile-time variable"; }
                default { skip "cannot check $method-name"; }}

            my $test-msg := "$type-name\.{$line<name>} invocant matches source";
            my @params = EVAL(":{$line<signature>}").params;

            my $method = do given $line<multi> {
                when !$type.^lookup($line<name>) { skip "$method-name not found on $type-name";
                                                   next }
                when .not { $type.^lookup($line<name>) };
                given $type.^lookup($line<name>).candidates.grep({.package.^name eq $type-name}) {
                    when .elems == 1 { .[0] }
                    default          { skip "cannot determine source for multi method $method-name";
                                       next }
            }};
            my $src-line := slurp( $*PROGRAM.parent(3).add("rakudo/" ~ $method.file.split('::')[1])
                                 ).lines[ $method.line - 1];

            given $src-line ~~ /<signature>/ {
                my $src-sig =  do {
                    when Nil && $src-line ~~ /method/ { '()' }
                    when Nil  { Nil }
                    default   { $_ }
                };
                when $src-sig ~~ Nil {
                    when @params[0] eqv Any { flunk($test-msg);
                                              report-accessor-error($line<signature>, :$src-line)}
                    unless ok(@params[0].invocant, $test-msg) { report-accessor-error($line<signature> :$src-line) }
                }
                when $src-sig ~~ /^'()'/ | /'(-->'/ { pass($test-msg)}
                when EVAL(":$_").params[0].invocant {
                    my $is-invocant = @params[0] ?? @params[0].invocant !! False;
                    unless ok($is-invocant, $test-msg) {
                        diag("documented method: {$line<signature>}");
                        diag("    source method: $_");}
                }
                default { pass $test-msg }
            };
    }}
}}

sub report-accessor-error($sig, Str :$src-line) {
    diag("auto-generated accessors must have definite invocants");
    diag($src-line);
    diag("documented method: $sig")
}

run <git checkout ->, :out, :err;

grammar TypeDocumentation {
    token TOP { [<method> || <other-line>]+ }

    token method { ^^ '=head2 method' \N* \n
                   \n
                   <def>?
                   <signature-line>
                 }
    token def   { 'Defined as:' \n \n }
    token other-line { ^^ \N* \n }

    token signature-line { <.ws><multi>? <declarator> <.ws> <name> <signature> \n}
    token multi      {'multi' <.ws>}
    token name       { <[-'\w]>+}
    token declarator { ['method' | 'sub'] }
}
