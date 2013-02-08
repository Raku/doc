#!/usr/bin/env perl6
use v6;

my $index_file = "index.data";
multi sub MAIN() {
    say "Usage: $*PROGRAM_NAME index     to index the docs";
    say "Usage: $*PROGRAM_NAME list      to list  the names";
}

multi sub MAIN('index') {
	my %words;
	for dir('lib') -> $file {
		my $pod = substr($file.Str, 0 , $file.Str.chars -4);
		next if $file !~~ /\.pod$/;
		my $section = '';
		for open('lib/' ~ $file.Str).lines -> $row {
			#if $row ~~ /^\=(item|head\d) \s+ X\<(.*)\> \s*$/ {
			if $row ~~ /^\=(item|head\d) \s+ (.*?) \s*$/ {
				$section = $1.Str;
				%words{$section}.push([$pod, $section]);
			}
			if $row ~~ /X\<(.*?)\>/ and $section {
				my $x = $0.Str;
				%words{$x}.push([$pod, $section]);
			}
		}
	}
	my $out = open($index_file, :w);
	$out.print(%words.perl);
	$out.close;
}
multi sub MAIN('list') {
    if $index_file.IO ~~ :e {
        my %data = eval slurp $index_file;
        for %data.keys.sort -> $name {
            say $name
        #    my $newdoc = %data{$docee}[0][0] ~ "." ~ %data{$docee}[0][1];
        #    return MAIN($newdoc, :f);
        }
    } else {
        say "First run   $*PROGRAM_NAME index    to create the index";
        exit;
    }
}

