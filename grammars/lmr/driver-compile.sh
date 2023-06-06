#!/bin/sh

silver -I .. --mwda --onejar $@ lmr:driver

rm build.xml > /dev/null 2>&1