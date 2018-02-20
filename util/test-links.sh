#!/bin/sh

cut -d '#' -f 1 links.txt | sort | uniq > links.tmp
mv links.tmp links.txt
wget -O- -i links.txt -B https://docs.perl6.org --method=HEAD 2>&1 | perl -ne '$_ =~ s/(.+)\n$/$1 /; print $_' | grep -v '200 OK'
