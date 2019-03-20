s/SELECT pg_catalog.set_config('search_path', '', false);/SET search_path = public, pg_catalog;/;

# Prevent setval() entries from being replayed on the superhub
# e.g., SELECT pg_catalog.setval('__promiselog_id_seq', 44075, true);
/^SELECT pg_catalog.setval/d;
