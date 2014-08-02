#!/usr/bin/env perl6
use v6;
use File::Find;

my $index_file = "index.data";
multi sub MAIN() {
    say "Usage: $*PROGRAM_NAME index     to index the docs";
    say "Usage: $*PROGRAM_NAME list      to list  the names";
}

multi sub MAIN('index') {
	my %words;

  my @files :=  find(:dir('lib'),:type('file')); 

	for @files -> $f {
    my $file = $f.path;
		next if $file !~~ /\.pod$/;
		my $pod = substr($file.Str, 0 , $file.Str.chars -4);
		$pod.=subst(/lib\//,"");
		$pod.=subst(/\//,'::',:g);
		my $section = '';
		for open( $file.Str).lines -> $row {
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
        my %data = EVAL slurp $index_file;
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

multi sub MAIN('lookup', $key) {
    if $index_file.IO ~~ :e {
        my %data = EVAL slurp $index_file;
        die "not found" unless %data{$key};
        say %data{$key}.split(" ").[0];
    } else {
        say "First run   $*PROGRAM_NAME index    to create the index";
        exit;
    }
}

