use v6;
use Test;
use lib 'lib';
use Pod::Convenience;

subtest {
    plan 6;
    my $title = "Pod document title";
    my $pod = pod-title($title);

    isa_ok($pod, Pod::Block::Named);
    eval_dies_ok('use Pod::Convenience; pod-title()', "title argument required");

    $pod = pod-title('');
    ok($pod, "empty title is ok");

    $pod = pod-title($title);
    is($pod.name, "TITLE", "is a title element");

    isa_ok($pod.contents, Array);
    is($pod.contents[0].contents, $title, "title contents set correctly");
}, "pod-title";

subtest {
    plan 5;
    my $pod = pod-block('');
    isa_ok($pod, Pod::Block::Para);
    ok(pod-block(), "empty argument ok");

    $pod = pod-block("hello");
    is($pod.contents, "hello", "simple contents match input");

    $pod = pod-block("hello", "there");
    is($pod.contents, "hello there", "multi-argument input");

    $pod = pod-block(qw{hello there world});
    is($pod.contents, 'hello there world', "array argument input");
}, "pod-block";

subtest {
    plan 6;
    eval_dies_ok('use Pod::Conenience; pod-link()', "text argument required");
    eval_dies_ok('use Pod::Conenience; pod-link("text")', "link argument required");

    my $pod = pod-link("text", "link");
    isa_ok($pod, Pod::FormattingCode);

    is($pod.type, "L", "is a link type");
    is($pod.contents[0], "text", "text matches input");
    is($pod.meta[0], "link", "link matches input");
}, "pod-link";

subtest {
    plan 4;
    eval_dies_ok('use Pod::Convenience; pod-bold()', "text argument required");

    my $pod = pod-bold("text");
    isa_ok($pod, Pod::FormattingCode);

    is($pod.type, "B", "is a bold type");
    is($pod.contents[0], "text", "text matches input");
}, "pod-bold";

subtest {
    plan 6;
    ok(pod-item(), "empty argument ok");
    ok(pod-item(''), "empty string argument ok");

    my $pod = pod-item(qw{hello there});
    isa_ok($pod, Pod::Item);
    is($pod.level, 1, "default level correct");
    is($pod.contents, "hello there", "contents matches input");

    $pod = pod-item(qw{hello there}, level => 5);
    is($pod.level, 5, "level matches input");
}, "pod-item";

subtest {
    plan 6;
    eval_dies_ok('use Pod::Convenience; pod-heading()', "name argument required");

    my $pod = pod-heading("name");
    isa_ok($pod, Pod::Heading);
    is($pod.contents[0].contents, "name", "heading name matches input");
    is($pod.level, 1, "level matches default value");

    $pod = pod-heading("heading name", level => 3);
    is($pod.contents[0].contents, "heading name", "heading name matches input");
    is($pod.level, 3, "level matches input");
}, "pod-heading";

subtest {
    plan 4;
    eval_dies_ok('use Pod::Convenience; pod-table();', "contents argument required");
    eval_dies_ok('use Pod::Convenience; pod-table("");', "fails with empty string argument");

    my $pod = pod-table(qw{table data});
    isa_ok($pod, Pod::Block::Table);
    is($pod.contents, "table data", "table data matches input");
}, "pod-table";

done;

# vim: expandtab shiftwidth=4 ft=perl6
