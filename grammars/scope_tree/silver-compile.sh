#!/bin/sh

silver -I .. --onejar --mwda $@ scope_tree:ast

rm build.xml > /dev/null 2>&1