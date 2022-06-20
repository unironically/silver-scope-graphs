#!/usr/bin/env bash

#set -eu
#silver() { "../../support/bin/silver" "$@"; }

SRC=../test
GRAMMAR=lmlangmaptest

silver -I $SRC $@ -o test.jar $GRAMMAR

