# Changelog
Notable changes to the framework should be documented here

## [Unreleased][unreleased]
### Added
 - CHANGELOG.md
 - Support for user specified overring of framework defaults without modifying
   policy supplied by the framework itself (see example_def.json)
 - Support for def.json class augmentation in update policy

### Changed
 - Relocate def.cf to controls/VER/
 - Relocate update_def to controls/VER
 - Relocate all controls to controls/VER
 - Only load cf_hub and reports.cf on CFEngine Enterprise installs
 - Relocate acls related to report collection from bundle server access_rules
   to controls/VER/reports.cf into bundle server report_access_rules
 - Re-organize cfe_internal splitting core from enterprise specific policies
   and loading the appropriate inputs only when necessary
 - Moved update directory into cfe_internal as it is not generally intended to
   be modified
 - services/autorun.cf moved to lib/VER/ as it is not generally intended to be
   modified
 - To improve predictibility autorun bundles are activated in lexicographical
   order
 - Relocate services/file_change.cf to cfe_internal/enterprise. This policy is
   most useful for a good OOTB experience with CFEngine Enterprise Mission
   Portal.
 - Relocate service_catalogue from promsies.cf to services/main.cf. It is
   intended to be a user entry. This name change correlates with the main
   bundle being activated by default if there is no bundlesequence specified.
 - Reduce benchmarks sample history to 1 day.
 - Update policy no longer generates a keypair if one is not found. (Redmine: #7167)
 - inform_mode classes changed to DEBUG|DEBUG_$(this.bundle):: (Redmine: #7191)

### Deprecated

### Removed
 - Diff reporting on /etc/shadow (Enterprise)
 - Update policy from promise.cf inputs. There is no reason to include the
   update policy into promsies.cf, update.cf is the entry for the update policy
 - _not_repaired outcome from classes_generic and scoped_classes generic (Redmine: # 7022)

### Fixed
 - standard_services now restarts the service if it was not already running
   when using service_policy => restart with chkconfig (Redmine #7258)

### Security

