#!/usr/bin/env perl6

use v6;

use NativeCall;

my $just-an-array = CArray[int32].new( 1, 2, 3, 4, 5 );

loop ( my size_t $i = 0; $i < $just-an-array.elems; $i++ ) {
    say $just-an-array[$i];
}
