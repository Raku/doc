#!/usr/bin/env perl6
use v6;

sub MAIN() {
	my $outfile = "index.ini";
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
	my $out = open('index.data', :w);
	$out.print(%words.perl);
	$out.close;
}

