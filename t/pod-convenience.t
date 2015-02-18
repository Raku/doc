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

subtest {
    eval_dies_ok('use Pod::Convenience; pod-lower-headings();', "content argument required");

    # should probably die, currently throws an internal error
    #eval_dies_ok('use Pod::Convenience; pod-lower-headings(qw{foo bar});',
    #"plain content array not acceptable");

    my $lowered-pod = pod-lower-headings([pod-heading("A head 1 heading")]);
    isa_ok($lowered-pod, Array);
    is($lowered-pod[0].level, 1, "single POD heading lowered from 1 to 1");
    is($lowered-pod[0].contents[0].contents, "A head 1 heading", "lowered heading contents match input");

    # if first heading is equal to default level to be lowered to, then don't lower
    {
        my @pod;
        @pod.push(pod-heading("heading head1"));
        @pod.push(pod-block(qw{"pod block}));
        @pod.push(pod-heading("heading head2", level => 2));
        $lowered-pod = pod-lower-headings(@pod);
        is($lowered-pod[0].level, 1, "heading head1 stays at level 1");
        is($lowered-pod[2].level, 2, "heading head2 stays at level 2");
    }

    # if first heading is equal to level to be lowered to, then don't lower
    {
        my @pod;
        @pod.push(pod-heading("heading head2", level => 2));
        @pod.push(pod-block(qw{"pod block}));
        @pod.push(pod-heading("heading head3", level => 3));
        $lowered-pod = pod-lower-headings(@pod, to => 2);
        is($lowered-pod[0].level, 2, "heading head2 stays at level 2");
        is($lowered-pod[2].level, 3, "heading head3 stays at level 3");
    }

    # if first heading is "higher" than level to be lowered to, then lower to level
    {
        my @pod;
        @pod.push(pod-heading("heading head3", level => 3));
        @pod.push(pod-block(qw{"pod block}));
        @pod.push(pod-heading("heading head4", level => 4));
        $lowered-pod = pod-lower-headings(@pod, to => 2);
        is($lowered-pod[0].level, 2, "heading head3 lowered to level 2");
        is($lowered-pod[2].level, 3, "heading head4 lowered to level 3");
    }
    done;
}, "pod-lower-headings";

done;

# vim: expandtab shiftwidth=4 ft=perl6
