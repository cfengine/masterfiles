# Changelog
Notable changes to the framework should be documented here

## 3.7.7
 - Allow multiple sections in insert_ini_section (CFE-2721)
 - make apt_get package module work with repositories containing spaces in the label
   (ENT-3438)
 - Fix systemctl path detection
 - Include scheduled report assets in self maintenance (ENT-3558)
 - prevent yum from locking in package_methods when possible (CFE-2759)
 - Fix self upgrade for rpm packages with default names (ENT-3603)

## 3.7.6
 - apt_get package module: Fix bug which prevented updates
   from being picked up if there was more than one source listed in the
   'apt upgrade' output, without a comma in between. (CFE-2605)
 - Add aix OOTB oslevel inventory (ENT-3117)
 - Add the path to mailx on Linux, Darwin, OpenBSD, NetBSD and FreeBSD
 - Avoid permission flip flop in webapp (ENT-3101)
 - Add oslevel to well known paths. (ENT-3121)
 - Include previous_state and untracked reports when client clear a buildup of unreported data
   (ENT-3161)
 - Update stubbed example package module controls (CFE-2602)
 - Change: Do not silence Enterprise hub maintenance
 - Add: prunetree bundle to stdlib
   The prunetree bundle allws you to delete files and directories up to a
   sepcified depth older than a specified number of days.
 - Ensure postgresql.log is rotated (ENT-3191)

## 3.7.3 .. 3.7.5
Changes are included in Core's Changelog.

## 3.7.2 (unreleased)
### Changed
   - inform_mode classes changed to DEBUG|DEBUG_$(this.bundle):: (Redmine: #7191)

## 3.7.1
### Fixed
   - Augmenting inputs from the augments_file (Redmine #7420)

## 3.7.0
### Added
 - CHANGELOG.md
 - Support for user specified overring of framework defaults without modifying
   policy supplied by the framework itself (see example_def.json)
 - Support for def.json class augmentation in update policy
 - Run vacuum operation on postgresql every night as a part of maintenance.
 - Add measure_promise_time action body to lib (3.5, 3.6, 3.7, 3.8)
 - New negative class guard `cfengine_internal_disable_agent_email` so that
   agent email can be easily disabled by augmenting def.json

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
<<<<<<< HEAD
 - Relocate cfe_internal_postgresql_maintenance bundle to lib/VER/
 - Set postgresql_monitoring_maintenance only for versions 3.6.0 and 3.6.1
 - Move hub specific bundles from lib/VER/cfe_internal.cf into lib/VER/cfe_internal_hub.cf
   and load them only if policy_server policy if set.
 - Re-organize lib/VER/stdlib.cf from lists into classic array for use with getvalues
 - inform_mode classes changed to DEBUG|DEBUG_$(this.bundle):: (Redmine: #7191)
 - Enabled limit_robot_agents in order to work around multiple cf-execd
   processes after upgrade. (Redmine #7185)
=======
>>>>>>> 6f58db5... Change: Switch inform_mode reports to DEBUG|DEBUG_bundlename

### Deprecated

### Removed
 - Diff reporting on /etc/shadow (Enterprise)
 - Update policy from promise.cf inputs. There is no reason to include the
   update policy into promsies.cf, update.cf is the entry for the update policy
 - _not_repaired outcome from classes_generic and scoped_classes generic (Redmine: # 7022)

### Fixed
 - standard_services now restarts the service if it was not already running
   when using service_policy => restart with chkconfig (Redmine #7258)
 - Fix process_result logic to match the purpose of body process_select
   days_older_than (Redmine #3009)

### Security

