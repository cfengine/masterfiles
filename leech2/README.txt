leech2 reporting drop-in directory
==================================

Files in this directory extend the leech2 configuration.

leech2's base config (/var/cfengine/.leech2/config.json) includes every
*.json file found here, deep-merging each one into the configuration
(last writer wins). Use this to add or override reporting tables without
editing the shipped config.json, which package upgrades overwrite.

To deploy a fragment to your hosts, place a *.json file under leech2/ in
your masterfiles; the policy update distributes it to inputs/leech2/ on
every host. Only *.json files are loaded; this README is ignored.
