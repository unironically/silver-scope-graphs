#!/bin/sh

silver -I .. $@ sg_cs:testing

rm build.xml > /dev/null 2>&1
