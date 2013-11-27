#!/bin/bash
# copy deb files given in $* into repo and sign repo
# this script can be in the repo or in a directory next to the repo
#
# Written by Schlomo Schapiro based upon work by Fridtjof Busse
# Licensed under the GNU General Public License, see http://www.gnu.org/licenses/gpl.html for full text
#

if [[ ! "$REPREPRO_BASE_DIR" ]] ; then
    ME_DIR="$(dirname "$(readlink -f "$0")")"
    for CHECK_DIR in "$ME_DIR" "$ME_DIR"/../repo "$ME_DIR"/repo ; do
        if [[ -r "$CHECK_DIR"/conf/distributions ]] ; then
            export REPREPRO_BASE_DIR="$(readlink -f "$CHECK_DIR")"
            break
        fi
    done
    if [[ ! "$REPREPRO_BASE_DIR" ]] ; then
        echo "Could not guess your reprepro path, please set REPREPRO_BASE_DIR"
        exit 1
    fi
elif [[ ! -r "$REPREPRO_BASE_DIR"/conf/distributions ]] ; then
    echo "$REPREPRO_BASE_DIR does not seem to be reprepro repo"
    exit 1
else
    : # REPREPRO_BASE_DIR is set and a dir and contains a conf/distributions, nothing to do
    
fi 

if [[ ! "$REPREPRO_CODENAMES" ]] ; then
    REPREPRO_CODENAMES=( $(sed -n -E -e '/^Suite:/s/^.* //p' "$REPREPRO_BASE_DIR"/conf/distributions) )
fi

echo "======================================================"
echo "Using repo path '$REPREPRO_BASE_DIR' and releases '${REPREPRO_CODENAMES[@]}'"
echo "======================================================"

WORK_DIR="$(mktemp -d)"
trap "rm -Rf $WORK_DIR" 0

# if you sign the repo to make apt happy and not for real security then you can put the GPG stuff into 
# the key subdir and we will use it.
if [[ -d "$REPREPRO_BASE_DIR"/key ]] ; then
    echo "Using '$REPREPRO_BASE_DIR/key' for GnuPG"
    cp -r "$REPREPRO_BASE_DIR"/key "$WORK_DIR"
    chmod g-rwx,o-rwx -R "$WORK_DIR"/key
    export GNUPGHOME="$WORK_DIR"/key
fi

if [[ "$1" ]] ; then
    for parm in "$@" ; do
        f="$(readlink -f "$parm")" # normalize file
        if [ ! -s "$f" ]; then
            echo "ERROR: Parameter '$parm' does not point to a readable file ($f)"
            exit 1
        fi

        echo "Adding '$f':"

        for CODENAME in ${REPREPRO_CODENAMES[@]}; do
            reprepro includedeb $CODENAME "$f"; 
        done
    done
else
    # if no arg was given and the repo is on DropBox then forcefully export everything and wait for DropBox sync
    reprepro export
    if type -p dropbox &>/dev/null && readlink -f "$REPREPRO_BASE_DIR" | grep -q Dropbox ; then
        echo -n "Waiting for DropBox sync: "
        while dropbox filestatus "$REPREPRO_BASE_DIR" | grep -vq "up to date" ; do
                sleep 5
                echo -n "."
        done
        echo " OK"
    fi
fi