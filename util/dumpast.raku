#!/usr/bin/env raku

# Generate the rakudoc AST for a given file

unit sub MAIN($file);

.say for $file.IO.slurp.AST.rakudoc

