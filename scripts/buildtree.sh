#!/bin/sh

#silver -I ../grammars $@ old-stlc-wip

mkdir -p ../bin

silver -I ../grammars --onejar $@ lmlangtree

rm build.xml > /dev/null 2>&1
rm Parser_lmlangtree_parse.copperdump.html > /dev/null 2>&1

mv *.jar ../bin > /dev/null 2>&1
