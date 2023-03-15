#!/bin/sh

silver -I .. --onejar --mwda $@ sg_cs

rm build.xml > /dev/null 2>&1
rm *.svg
