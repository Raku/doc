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

done;

# vim: expandtab shiftwidth=4 ft=perl6
