#!/bin/sh

silver -I .. --onejar $@ lmr:driver

rm build.xml > /dev/null 2>&1