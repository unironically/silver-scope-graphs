#!/bin/sh

#silver -I ../grammars $@ old-stlc-wip

mkdir -p ../bin

silver -I ../grammars --onejar $@ oldstlc

rm build.xml

mv *.jar ../bin
