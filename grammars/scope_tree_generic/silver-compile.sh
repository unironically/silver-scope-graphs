#!/bin/sh

silver -I .. --onejar $@ scope_tree_generic:driver

rm build.xml > /dev/null 2>&1