#!/bin/sh

#silver -I ../grammars $@ old-stlc-wip

mkdir -p ../bin

silver -I ../grammars --onejar $@ lmlang

rm build.xml

mv *.jar ../bin
