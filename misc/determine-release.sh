# This script tries to figure out proper RELEASE number
# and saves its best guess to CFRELEASE file passed as 1st and the only argument.

# It checks $EXPLICIT_RELEASE, $RELEASE, and git tags.
# If nothing helps, it defaults to 1.

if [ "$#" -ne 1 ]
then
    echo "Usage: determine-release.sh path/to/CFRELEASE"
    exit 1
fi

if [ "$EXPLICIT_RELEASE" ]; then
	echo "EXPLICIT_RELEASE is set, using it"
	echo "$EXPLICIT_RELEASE" > "$1"
	exit 0
fi

if [ "$RELEASE" ]; then
	echo "RELEASE is set, using it"
	echo "$RELEASE" > "$1"
	exit 0
fi

all_tags="$(git tag --points-at HEAD)"

if [ -z "$all_tags" ]; then
	echo "No tags found, using default release number 1"
	echo 1 > "$1"
	exit 0
fi

echo "All tags pointing to current commit:"
echo "$all_tags"

full_version="$(echo "$all_tags" | sed 's/-build[0-9]*$//' | sort -u | tail -n1)"

echo "Latest version: $full_version"

if ! expr "$full_version" : "3.*-\([0-9]*\)$" >/dev/null; then
	echo "Could not parse it, using default release number 1"
	echo 1 > "$1"
	exit 0
fi

release="$(expr "$full_version" : "3.*-\([0-9]*\)$")"
echo "Using release number from version: $release"
echo "$release" > "$1"
exit 0
