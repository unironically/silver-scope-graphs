#!/bin/sh

#silver -I ../grammars $@ old-stlc-wip

mkdir -p ../bin

silver -I ../grammars --onejar $@ lmlang_basic_scopegraph

rm build.xml > /dev/null 2>&1
rm Parser_lmlang_basic_scopegraph_parse.copperdump.html > /dev/null 2>&1

mv *.jar ../bin > /dev/null 2>&1
