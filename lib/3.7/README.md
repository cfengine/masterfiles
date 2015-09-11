# 3.7 Library Directory

This file exists as a place holder for the 3.7 library. It is required because
3.7 clients have `$(sys.local_libdir)` set to `lib/3.7`. The policy has moved
up one level as it has been re-unified and this directory must exist in order
for 3.7 clients to be able to reference `$(sys.local_libdir)/../stdlib.cf`
