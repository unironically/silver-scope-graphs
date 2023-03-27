#!/bin/sh

silver -I .. --onejar $@ sg_cs:driver

rm build.xml > /dev/null 2>&1
