-- TODO guard against hub_1 schema already existing, bail if it does
-- in a single transaction
BEGIN;
CREATE TABLE __hubs (hub_id BIGSERIAL, hostname TEXT);
INSERT INTO __hubs (hostname) VALUES ('superhub');
CREATE SCHEMA hub_1; -- assume __hubs.hub_id = 1 for 'superhub'

DO $$DECLARE r record
BEGIN
  FOR r in SELECT table_name FROM information_schema.tables
           WHERE table_type = 'BASE TABLE' AND table_schema = 'public'

  LOOP
    RAISE NOTICE 'working on table %', r.table_name;
    EXECUTE 'ALTER TABLE ' || quote_ident(r.table_name) || ' ADD COLUMN IF NOT EXISTS hub_id BIGINT DEFAULT 1'
    EXECUTE 'ALTER TABLE ' || quote_ident(r.table_name) || ' SET SCHEMA "hub_1"'
    EXECUTE 'CREATE TABLE ' || quote_ident(r.table_name) || ' (like "hub_1".' || quote_ident(r.table_name) || ' INCLUDING DEFAULTS) PARTITION BY LIST (hub_id)'
    EXECUTE 'ALTER TABLE ' || quote_ident(r.table_name) || ' ATTACH PARTITION "hub_1".' || quote_ident(r.table_name) || ' FOR VALUES IN (1)'
    -- TODO deal with promiselog DROP INDEX and ADD CONSTRAINT pkey (id,hub_id)
  END LOOP;
END$$

-- TODO adjust primary keys? each schema will be fine but what about public?
