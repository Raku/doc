module Pod::Htmlify;

use URI::Escape;

sub url-munge($_) is export {
    return $_ if m{^ <[a..z]>+ '://'};
    return "/type/{uri_escape $_}" if m/^<[A..Z]>/;
    return "/routine/{uri_escape $_}" if m/^<[a..z]>|^<-alpha>*$/;
    # poor man's <identifier>
    if m/ ^ '&'( \w <[[\w'-]>* ) $/ {
        return "/routine/{uri_escape $0}";
    }
    return $_;
}

sub footer-html($pod-filename) is export {
    my $footer = slurp 'template/footer.html';
    $footer.subst-mutate(/DATETIME/, ~DateTime.now);
    $footer.subst-mutate(/SOURCEFILE/, $pod-filename, :g);

    return $footer;
}

# vim: expandtab shiftwidth=4 ft=perl6
