#!/bin/sh

silver -I .. --onejar $@ sg_cs

rm build.xml > /dev/null 2>&1
