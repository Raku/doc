#!/usr/bin/env perl6
use v6;

sub MAIN() {
	my $outfile = "index.ini";
	my %words;
	for dir('lib') -> $file {
		next if $file !~~ /\.pod$/;
		#say $file.Str;
		for open('lib/' ~ $file.Str).lines -> $row {
			#if $row ~~ /^\=(item|head\d) \s+ X\<(.*)\> \s*$/ {
			if $row ~~ /^\=(item|head\d) \s+ (.*?) \s*$/ {
				my $w = $1.Str;
				%words{$w}.push(substr($file.Str, 0 , $file.Str.chars -4));
				#say '    ', $1.Str;
			}
		}
	}
	my $out = open('index.data', :w);
	$out.print(%words.perl);
	$out.close;
}

