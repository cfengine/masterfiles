#!/usr/bin/env sh
script_dir=$(dirname $0)
${script_dir}/cf-locate.sh -f "$1 $2" | sed "s/$1\s*/& u_/"
