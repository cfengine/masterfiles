# Changelog
Notable changes to the framework should be documented here

## 3.8 (Unreleased)
### Added
 - External watchdog policy to ensure that cf-execd is running so that policy will be
   run on schedule.
   - This policy configures /etc/cron.d/cfengine_watchdog if /etc/cron.d is
     present to check for cf-execd once a minute and launch it if it is not
     running.
   - The policy can be enabled by defining the class
     cfe_internal_core_watchdog_enabled, or disabled by defining
     cfe_internal_core_watchdog_disabled. In the event both classes are defined
     at the same time enabled wins.

### Changed
 - Reunify version split stdlib (Redmine: #7559)

### Removed
 - Removed support for version 3.5 from masterfiles

## 3.7.2 (Unreleased)
## Added
   - svcprop to stdlib paths

## Changed
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
 - Relocate cfe_internal_postgresql_maintenance bundle to lib/VER/
 - Set postgresql_monitoring_maintenance only for versions 3.6.0 and 3.6.1
 - Move hub specific bundles from lib/VER/cfe_internal.cf into lib/VER/cfe_internal_hub.cf
   and load them only if policy_server policy if set.
 - Re-organize lib/VER/stdlib.cf from lists into classic array for use with getvalues
 - inform_mode classes changed to DEBUG|DEBUG_$(this.bundle):: (Redmine: #7191)
 - Enabled limit_robot_agents in order to work around multiple cf-execd
   processes after upgrade. (Redmine #7185)

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

