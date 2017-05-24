unit module Pod::Htmlify;

use URI::Escape;

#| Escape special characters in URLs if necessary
sub url-munge($url) is export {
    given $url {
        when m{^ <[a..z]>+ '://'}     { $_ }
        when m/^<[A..Z]>/             { "/type/{uri_escape $_}" }
        when m/^<[a..z]>|^<-alpha>*$/ { "/routine/{uri_escape $_}" }
        when m/ ^ '&'( \w <[[\w'-]>* ) $/ { "/routine/{uri_escape $0}" } # poor man's <identifier>
        default { $_ }
    }
}

my \badchars-ntfs = Qw[ / ? < > \ : * | " ¥ ];
my \badchars-unix = Qw[ / ];
my \badchars-url = Qw[ % ^ ];
my \badchars = $*DISTRO.is-win ?? badchars-ntfs !! badchars-unix;
my @badchars = (badchars, badchars-url).flat;
my \goodnames = @badchars.map: '$' ~ *.uniname.subst(' ', '_', :g);
my \length = @badchars.elems;

sub replace-badchars-with-goodnames($s is copy) is export {
#    return $s if $s ~~ m{^ <[a..z]>+ '://'}; # bail on external links

    loop (my int $i = 0; $i < length; $i++) {
        $s = $s.subst(@badchars[$i], goodnames[$i], :g)
    }

    $s
}

sub unescape-percent($s) {
    $s.subst(:g, / [ '%' (<.xdigit> ** 2 ) ]+ /, -> $/ { Buf.new($0.flatmap({ :16(~$_) })).decode('UTF-8') })
}

sub rewrite-url($s) is export {
    state %cache;
    return %cache{$s} if %cache{$s}:exists;
    my Str $r;
    given $s {
        when / ^ [ 'http' | 'https' | 'irc' ] '://' / {
            # external link, we bail
            return $s;
        }

        when / ^ '#' / {
            # on-page link, we bail
            return $s;
        }
        # Type
        when / ^ <[A..Z]> / {
            $r =  "/type/{replace-badchars-with-goodnames(unescape-percent($s))}";
            succeed;
        }
        # Routine
        when / ^ <[a..z]> | ^ <-alpha>* $ / {
            $r = "/routine/{replace-badchars-with-goodnames(unescape-percent($s))}";
            succeed;
        }

        # Special case the really nasty ones
        when / ^ '/routine//' $ /  { return '/routine/' ~ replace-badchars-with-goodnames('/'); succeed;  }
        when / ^ '/routine///' $ / { return '/routine/' ~ replace-badchars-with-goodnames('//'); succeed; }

        when / ^
            ([ '/routine/' | '/syntax/' | '/language/' | '/programs/' | '/type/' ]) (<-[#/]>+) [ ('#') (<-[#]>*) ]* $ / {
            $r =  $0 ~ replace-badchars-with-goodnames(unescape-percent($1)) ~ $2 ~ uri_escape($3);
            succeed;
        }

        default {
            my @parts = $s.split('#');
            $r = replace-badchars-with-goodnames(@parts[0]) ~ '#' ~ uri_escape(@parts[1]) if @parts[1];
            $r = replace-badchars-with-goodnames(@parts[0]) unless @parts[1];
        }
    }

    my $file-part = $r.split('#')[0] ~ '.html';
    die "$file-part not found" unless $file-part.IO:e:f:s;
    # URL's can't end with a period. So affix the suffix.
    # If it ends with percent encoded text then we need to add .html to the end too
    if !$r.contains('#') && ( $r.ends-with(<.>) || $r.match: / '%' <:AHex> ** 2 $ / ) {
        $r ~= '.html';
    }
    return %cache{$s} = $r;
}

#| Return the footer HTML for each page
sub footer-html($pod-path) is export {
    my $footer = slurp 'template/footer.html';
    $footer.subst-mutate(/DATETIME/, ~DateTime.now.utc.truncated-to('seconds'));
    my $pod-url;
    my $gh-link = q[<a href='https://github.com/perl6/doc'>perl6/doc on GitHub</a>];
    if $pod-path eq "unknown" {
        $pod-url = "the sources at $gh-link";
    }
    else {
        $pod-url = "<a href='https://github.com/perl6/doc/raw/master/doc/$pod-path'>$pod-path\</a\> from $gh-link";
    }
    $footer.subst-mutate(/SOURCEURL/, $pod-url);
    state $source-commit = qx/git rev-parse --short HEAD/.chomp;
    $footer.subst-mutate(:g, /SOURCECOMMIT/, $source-commit);

    return $footer;
}

#| Return the SVG for the given file, without its XML header
sub svg-for-file($file) is export {
    join "\n", grep { /^'<svg'/ ff False }, $file.IO.lines;
}

# vim: expandtab shiftwidth=4 ft=perl6
