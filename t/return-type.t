use v6;
use Test;
use lib 'lib';

my @files;

# Every .pod6 file in the Type directory.
@files = qx<git ls-files>.lines.grep(* ~~ /'.pod6'/).grep(* ~~ /Type/);

plan +@files;

for @files -> $file {
    # If it is the any Signature-related exception
    # or Signature.pod, then presence of '-->' is valid.
    { pass "$file return types are valid" ; next } if $file ~~ /Signature/;
    my @lines;
    my Int $line-no = 1;
     for $file.IO.lines -> $line {
	 if so $line ~~ /(method|sub) .+? '-->'/
	 && $line !~~ /'--> True'/
	 && $line !~~ /'--> False'/ {
	     @lines.push($line-no);
	 }
	 $line-no++;
     }
     if @lines {
	 flunk "$file has bad return type: {@lines}";
     } else {
	 pass "$file return types are ok";
     }
}
