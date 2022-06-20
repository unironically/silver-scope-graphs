#!/usr/bin/env bash

#set -eu
#silver() { "../../support/bin/silver" "$@"; }

SRC=../test
GRAMMAR=lmlangmaptest

silver -I $SRC --onejar $@ $GRAMMAR

rm build.xml > /dev/null 2>&1
rm Parser_lmlangmap_parse.html > /dev/null 2>&1

mv *.jar ../bin > /dev/null 2>&1

