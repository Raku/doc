#!/bin/sh

wget -O- -i html/links.txt -B https://docs.perl6.org --method=HEAD 2>&1 | perl -ne '$_ =~ s/(.+)\n$/$1 /; print $_' | grep -v '200 OK'
