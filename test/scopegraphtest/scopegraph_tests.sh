#!/usr/bin/env bash

set -eu
silver() { "../../../../silver/support/bin/silver" "$@"; }

SRC=..
GRAMMAR=scopegraphtest

silver -I $SRC $@ -o test.jar $GRAMMAR