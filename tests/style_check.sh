#!/bin/sh

retval=0                                            # success by default
echo
echo


########## Trailing Whitespace Check ##########

git ls-files  \
    |  xargs grep --binary-files=without-match -n ' $'

if [ $? = 0 ]
then
    echo "FAIL: trailing whitespace was found"  1>&2
    retval=1
else
    echo "PASS: trailing whitespace check OK"  1>&2
fi


echo
exit $retval
