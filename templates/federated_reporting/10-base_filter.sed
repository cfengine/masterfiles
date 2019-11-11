# remove the search_path settings because we want to stay in the newly created feeder schema
/SELECT pg_catalog.set_config('search_path', '', false);/d;

# Prevent setval() entries from being replayed on the superhub
# e.g., SELECT pg_catalog.setval('__promiselog_id_seq', 44075, true);
#/^SELECT pg_catalog.setval/d;
# NOTE: don't need this anymore since we will be calling setval on the local schema copy of things

# Remove public. schema prefix so that import can go into the current schema (feeder schema)
s/public\.//g;

# Remove CREATE TYPE blocks
/CREATE TYPE.*/,/^);$/d

# don't reset the promiselog sequence value
/SELECT pg_catalog.setval('__promiselog_id_seq.*$/d

# enable more debug messages
s/client_min_messages = warning/client_min_messages = notice/

# Munge rows from __promiselog child tables (like __promiselog_KEPT_2017-01-01)
# to write them to parent table on import (and the database will take care
# of placing them in the appropriate child table)
/^INSERT INTO "__promiselog_/ {
    s/^INSERT INTO "__promiselog_.[^"]*"/INSERT INTO __promiselog/;
    s/VALUES [^,]*,/VALUES \(DEFAULT,/;
};
