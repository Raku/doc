unit module Pod::Htmlify;

use URI::Escape;

#| Escape special characters in URLs if necessary
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

#| Return the footer HTML for each page
sub footer-html($pod-path) is export {
    my $footer = slurp 'template/footer.html';
    $footer.subst-mutate(/DATETIME/, ~DateTime.now);
    my $pod-url;
    my $gh-link = q[<a href='https://github.com/perl6/doc'>perl6/doc on GitHub</a>];
    if $pod-path eq "unknown" {
        $pod-url = "the sources at $gh-link";
    }
    else {
        $pod-url = "<a href='https://github.com/perl6/doc/raw/master/lib/$pod-path'>$pod-path\</a\> from $gh-link";
    }
    $footer.subst-mutate(/SOURCEURL/, $pod-url);

    return $footer;
}

#| Return the SVG for the given file, without its XML header
sub svg-for-file($file) is export {
    join "\n", grep { /^'<svg'/ ff False }, $file.IO.lines;
}

# vim: expandtab shiftwidth=4 ft=perl6
