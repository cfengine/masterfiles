To use the acceptance tests:

* check out core from https://github.com/cfengine/core to directory `$CHECKOUT`
* go to top directory (`masterfiles`)
* run `make check CORE=$CHECKOUT`
* to see the test logs, run `make checklog CORE=$CHECKOUT`

To run the unsafe tests - i.e. tests that potentially alter the system in a way
that may render it unstable and that are contained in the unsafe subdirectory,
set the following environment variables:

UNSAFE_TESTS=1
GAINROOT=sudo

For example, from the top level masterfiles directory:
UNSAFE_TESTS=1 GAINROOT=sudo make check



