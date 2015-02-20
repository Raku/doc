use v6;
use Test;
use lib 'lib';

plan 3;

use_ok('Pod::Htmlify');
use Pod::Htmlify;

subtest {
    plan 7;

    eval_dies_ok('use Pod::Htmlify; url-munge();', "requires an argument");
    is(url-munge("http://www.example.com"), "http://www.example.com",
        "plain url string with explicit protocol");
    is(url-munge("Class::Something"), "/type/Class%3A%3ASomething",
        "type name input");
    is(url-munge("funky-routine"), "/routine/funky-routine",
        "routine name input");
    is(url-munge('&stuff'), "/routine/stuff", "identifier (sub) input");
    is(url-munge("infix<+>"), "/routine/infix%3C%2B%3E", "operator input");
    is(url-munge('$*VAR'), '$*VAR', "sigil/twigil input");
}, "url-munge";

subtest {
    plan 1;
    isnt(footer-html(), "", "footer text isn't empty");
}, "footer-html";

# vim: expandtab shiftwidth=4 ft=perl6
