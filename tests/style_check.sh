#!/bin/sh


git ls-files  \
    |  xargs grep --binary-files=without-match -n ' $'

if [ $? = 0 ]
then
    echo "\n\nFAIL: trailing whitespace found\n"  1>&2
    exit 1
else
    echo "\n\nPASS: trailing whitespace check OK\n"  1>&2
    exit 0
fi
