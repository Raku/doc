#!/bin/bash
#
# This script compiles site's SASS into CSS
# It requires either the presence of `sass` command (which will be tried first)
# or the CSS::Sass Perl 5 module: https://metacpan.org/pod/CSS::Sass
#
if command -v sassc >/dev/null 2>&1 && sassc --version 2>&1 /dev/null; then
    sassc -t compressed assets/sass/style.scss html/css/style.css &&
    echo "Successfully compiled SASS using 'sassc' command" ||
    { echo "Failed to compile SASS with 'sassc' command"; exit 1; }
elif command -v sass >/dev/null 2>&1 && sass --version 2>&1 /dev/null; then
    sass -t compressed assets/sass/style.scss:html/css/style.css &&
    echo "Successfully compiled SASS using 'sass' command" ||
    { echo "Failed to compile SASS with 'sass' command"; exit 1; }
elif perl -MCSS::Sass -e '' >/dev/null 2>&1 ; then
    perl -MData::Dumper -MCSS::Sass -wlE '
        my ($css, $err, $stats) = CSS::Sass::sass_compile_file(
            "assets/sass/style.scss",
            output_style => SASS_STYLE_COMPRESSED
        );
        if (defined $err) {
            print Dumper $stats;
            say "Failed to compile sass (see diagnostics above)";
            exit 1
        };
        my $f = "html/css/style.css";
        open my $fh, ">", $f or
            die "Failed to open $f to write CSS into: $!";
        print $fh $css;
    ' && echo "Successfully compiled SASS using CSS::Sass module" ||
        { echo "Failed to compile SASS with CSS::Sass module"; exit 1; }
else
    echo "Need either 'sass' command or CSS::Sass Perl 5 module"
    exit 1;
fi
