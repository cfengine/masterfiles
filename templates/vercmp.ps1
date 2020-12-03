param([string]$version1,[string]$comparison,[string]$version2)
if ( "$comparison" -eq "lt" ) {
    if ([System.Version]"$version1" -lt [System.Version]"$version2") {
        "$version1 is less than $version2"
        exit 0
    } else {
        "$version1 is not less than $version2"
        exit 1
    }
}
if ( "$comparison" -eq "eq" ) {
    if ([System.Version]"$version1" -eq [System.Version]"$version2") {
        "$version1 is equal to $version2"
        exit 0
    } else {
        "$version1 is not equal to $version2"
        exit 1
    }
} else {
    "PROGRAMMING ERROR"
    exit 3
}
