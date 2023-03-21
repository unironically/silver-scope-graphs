#!/bin/sh

silver -I .. --doc --onejar $@ scope_tree:ast

rm build.xml > /dev/null 2>&1
