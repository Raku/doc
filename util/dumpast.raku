#!/usr/bin/env raku

# Generate the rakudoc AST for a given file

unit sub MAIN($file);

dd $file.IO.slurp.AST.rakudoc

