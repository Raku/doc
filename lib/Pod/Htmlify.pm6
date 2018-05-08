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
    state %cache =
        '/routine//'  => '/routine/' ~ replace-badchars-with-goodnames('/'),
        '/routine///' => '/routine/' ~ replace-badchars-with-goodnames('//');
    return %cache{$s} if %cache{$s}:exists;

    my Str $r;
    given $s {
        # Avoiding Junctions as matchers due to:
        # https://github.com/rakudo/rakudo/issues/1385#issuecomment-377895230
        when { .starts-with: 'https://' or .starts-with: '#'
            or .starts-with: 'http://'  or .starts-with: 'irc://'
        } {
            return %cache{$s} = $s; # external link or on-page-link, we bail
        }
        # Type
        when 'A'.ord ≤ *.ord ≤ 'Z'.ord {
            $r =  "/type/{replace-badchars-with-goodnames(unescape-percent($s))}";
        }
        # Routine
        when / ^ <[a..z]> | ^ <-alpha>* $ / {
            $r = "/routine/{replace-badchars-with-goodnames(unescape-percent($s))}";
        }
        when / ^
            ([ '/routine/' | '/syntax/' | '/language/' | '/programs/' | '/type/' ]) (<-[#/]>+) [ ('#') (<-[#]>*) ]* $ / {
            $r =  $0 ~ replace-badchars-with-goodnames(unescape-percent($1)) ~ $2 ~ uri_escape($3);
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
    my $edit-url;
    my $gh-link = q[<a href='https://github.com/perl6/doc'>perl6/doc on GitHub</a>];
    if not defined $pod-path {
        $pod-url = "the sources at $gh-link";
        $edit-url = ".";
    }
    else {
        $pod-url = "<a href='https://github.com/perl6/doc/blob/master/doc/$pod-path'>$pod-path\</a\> at $gh-link";
        $edit-url = " or <a href='https://github.com/perl6/doc/edit/master/doc/$pod-path'>edit this page\</a\>.";
    }
    $footer.subst-mutate(/SOURCEURL/, $pod-url);
    $footer.subst-mutate(/EDITURL/, $edit-url);
    state $source-commit = qx/git rev-parse --short HEAD/.chomp;
    $footer.subst-mutate(:g, /SOURCECOMMIT/, $source-commit);

    return $footer;
}

#| Return the SVG for the given file, without its XML header
sub svg-for-file($file) is export {
    .substr: .index: '<svg' given $file.IO.slurp;
}

# vim: expandtab shiftwidth=4 ft=perl6
