# Changelog
Notable changes to the framework should be documented here

3.10.0:
	- Add: Classes body tailored for use with diff
	- Change: Session Cookies use HTTPOnly and secure attribtues (ENT-2781)
	- Change: Verify transfered files during policy update
	- Add: Inventory for system product name (model) (ENT-2780)
	- Add: Ensure appropriate permissions for SSL files (ENT-760)
	- Fix rare bug that would sometimes prevent redis-server from launching.
	- Change: Enable strict transport security
	- Add: Definition of from_cfexecd for cf-execd initiated runs
	  (CFE-2386)
	- Add testing jUnit and TAP bundles and include them in stdlib.cf
	- Change: Rename duplicate bodies in ha_update.cf (ENT-2753)
	- Change: Disable RC4 Cipher for ssl in Mission Portal
	- Pass package promise options to underlying apt-get call (#802)
	  (CFE-2468)
	- Change: Enable agent component management policy on systemd hosts
	  (CFE-2429)
	- Add: Enterprise appliaction log dir to rotation
	- Change: re-enable hub process maintainance
	- Add: edit_line contains_literal_string to stdlib
	- Fix: Services starting or stopping unnecessarily (CFE-2421)
	- Allow specifying agent maxconnections via def.json (CFE-2461)
	- Change: Disable http TRACE method
	- Change: Reduce Enteprise webserver info
	- Change: cronjob bundle tolerates different spacing
	- Fix: CFEngine choking on standard services (CFE-2806)


## [Unreleased][unreleased]
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

