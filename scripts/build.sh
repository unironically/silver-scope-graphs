#!/bin/sh

#silver -I ../grammars $@ old-stlc-wip

mkdir -p ../bin

silver -I ../grammars --onejar $@ lmlang

rm build.xml > /dev/null 2>&1
rm Parser_lmlang_parse.copperdump.html > /dev/null 2>&1

mv *.jar ../bin
