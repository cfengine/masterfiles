Files in this directory ending in `.mustache` are rendered to
`$(sys.workdir)/modules` (typically `/var/cfengine/modules`) using `datastate()`
from the `update.cf` policy entry. Templates in sub-directories are not
considered.

For example `hello.sh.mustache` will be rendered to
`$(sys.workdir)/modules/hello.sh` and `sub-dir/goodbye.sh.mustache` would not be
rendered to `$(sys.workdir)/modules/sub-dir/goodby.sh`.

## History
- Added in 3.23.0
