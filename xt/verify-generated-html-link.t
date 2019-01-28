#!/usr/bin/env perl6

use v6.*;
use Test;

my SetHash $tested .= new;

=begin pod

Two ways of dealing with a local target

=item search html file for id or name

=item call wget on a target with a 'live' server named in $root

=end pod

my $root = %*ENV<P6_DOC_TEST_SERVER> // '';
my $html = %*ENV<P6_DOC_HTML_PATH> // 'html';
my $threads = %*ENV<TEST_THREADS> // 16;
PROCESS::<$SCHEDULER> = ThreadPoolScheduler.new(initial_threads => 0, max_threads => $threads);

my @files = my sub recurse ($dir) {
    gather for dir($dir) {
        take .Str if  .extension ~~ 'html';
        take slip sort recurse $_ if .d;
    }
}( $html ); # is the first definition of $dir

my @threads;
my @link-params;
my $offset = $html.chars;
for @files  -> $fn {
    next if $fn.contains('perl6.html') ; # this file has too many errors
    my $io = $fn.IO;
    my $file = substr($fn,$offset); # make relative to html root
    my $line = 0;
    my $ln = '';
    for $io.lines {
        $ln = $_;
        $line++;
        while $ln ~~ / '<a' .+? 'href="'~ \" ( <-["]>+ ) / { # Assume that the whole of an anchor's href is on one line
            $ln = $/.postmatch;
            my $link = ~$0;
            # exclude trivial or links not testable with wget
            next if $link ~~ / ^ \s* '/'? \s* $ /; # ignore reference to root, or is blank
            next if $link ~~ / ^ \s* '#' / ; # an internal link to the same file. wget does not provide information about internal links.
            next if $link ~~ m/ ^ 'irc:' /; # ignore irc links

            next if $tested{ $link }++; # if link not in tested, will have value False and add link to tested
            @link-params.push: ( $link, $io, $file, $line );
            @threads.push( start
                sub ( @queue ) {
                    my @params = @queue.pop.list if @queue;
                    return unless +@params;
                    my $res = test-link( @params );
                    &?ROUTINE( @queue )
                }( @link-params )
            )  if +@threads < $threads - 2;
        }
    }
}
await @threads;
done-testing;

sub test-link( @args ) {
    my ( $link, $io, $file, $line ) = @args;
    my ( $content, $test );
    my $exterior = so $link ~~ m/ ^'http' 's'? ':' /; # exterior to document collection
    if $root or $exterior { # if live or an external link use wget
        my $p = run('wget', $exterior ?? $link !! $root ~ $link.&unescape, '--spider', '-nv', '-t 1','-T 10', '-o /dev/null', :out, :err, :merge);
        my $resp = $p.out.slurp;
        if $resp ~~ / '200' \s+ 'OK' \s* $/ {
            ok 1, "｢$link｣ 200 OK"
        }
        else {
            if $exterior {
                # wget  --spider uses HEAD, not all sites allow, so try GET when exterior link
                 $p = run('wget', $link, '-O', '/dev/null', '-t 1','-T 10', '-o /dev/null', :out, :err, :merge);
                 $resp = $p.out.slurp;
                 if $resp ~~ / 'response... 200 OK' / {
                     ok 1, "｢$link｣ 200 OK"
                 } else {
                     ok $1, "｢$link｣ may still be OK";
                 }
             }
             else {
                flunk "｢$link｣ in file ｢$file｣ at line $line failed with ｢$resp｣"
            }
        }
    }
    else { #interior to document collection without live server, so check html for target
        given $link {
            when m/ ^ $<fn>= ( '/' [ 'routine' | 'syntax' | 'type' | 'language' | 'program' ] '/' <-[#]>+ )  [ $ | '#'  $<intl>=(.+) $ ] /
                or m/ ^$<fn> = (  '/' <-[#]>+ )  [ $ | '#'  $<intl>=(.+) $ ] /
                {
                my $f = ~$<fn>;
                $f .= subst(/ '.html' $ /, ''); #remove extension if it exists; to normalise
                $test = so "$html$f.html".IO.f;
                if $test {
                    if $<intl>:exists { # there is an internal link to check
                        my $i = ~$<intl>;
                        $i .= subst("\x20","\\x20",:g);
                        $i .= subst(/ \W /, "\\" ~ * , :g); # escape all non-characters as $i will be in regex
                        $test = so "$html$f.html".IO.slurp ~~ / 'id="' ~ \" <$i> | 'name="' ~ \" <$i> /;
                        ok $test, "$link exists"
                    }
                    else { # no internal link, so we only need to verify the file exists
                        ok $test, "｢$link｣ exists"
                    }
                }
                else {
                    flunk "No target file ｢$link｣ in file ｢$file｣ at line $line";
                }
            }
            when m/ ^ \s* '#' $<intl>=(.+) $ / {
                # an internal link inside the file
                $content = $io.slurp unless $content; # get all contents once if necessary
                my $i = ~$<intl>;
                $i .= subst("\x20","\\x20",:g);
                $i .= subst(/ \W /, "\\" ~ * , :g); # escape all non-characters as $i will be in regex
                ok so $content ~~ / 'id="' ~ \" <$i> | 'name="' ~ \" <$i> /, "$link exists"
            }
            default {
                # unknown link type so treat as bad link
                flunk "Unknown link type ｢$link｣ in file ｢$file｣ at line $line"
            }
        }
    }
}

sub unescape( Str $link is copy ) {
        $link .= subst(/ '%20' /, ' ',:g);
        $link .= subst(/ '%24' /, '$',:g);
        $link .= subst(/ '%25' /, '%',:g);
        $link .= subst(/ '%28' /, '(',:g);
        $link .= subst(/ '%29' /, ')',:g);
        $link .= subst(/:i  '%2a' /, '*',:g);
        $link .= subst(/:i  '%3a' /, ':',:g);
        $link .= subst(/:i '%3d' /, '=',:g);
        $link .= subst(/:i  '%3e' /, '>',:g);
        $link .= subst(/ '%40' /, '@',:g);
        $link .= subst(/:i  '%5b' /, '[',:g);
        $link .= subst(/:i  '%5d' /, ']',:g);
        $link .= subst(/:i  '%7b' /, '{',:g);
        $link .= subst(/:i  '%7c' /, '|',:g);
        $link .= subst(/:i  '%7d' /, '}',:g);
        $link .= subst(/  '%80' /, '€',:g);
        $link .= subst(/:i  '&amp;' /, '&',:g);
        $link .= subst(/:i  '&lt;' /, '<',:g);
        $link .= subst(/:i  '&gt;' /, '>',:g);
}
