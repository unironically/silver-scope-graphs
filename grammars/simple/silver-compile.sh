#!/bin/sh

silver -I .. --onejar --mwda $@ simple

rm build.xml > /dev/null 2>&1