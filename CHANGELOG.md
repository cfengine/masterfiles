# Changelog
Notable changes to the framework should be documented here

3.10.3:
	- Add oracle linux support to standalone self upgrade
	- Fix systemctl path detection
	- Add support for 32bit rpms in standalone self upgrade (ENT-3377)
	- make apt_get package module work with repositories containing spaces in the label
	  (ENT-3438)
	- Be less noisy when a promised service is not found (CFE-2690)
	- Fix to frequent logging of enterprise license utilization (ENT-3390)
	- Include scheduled report assets in self maintenance (ENT-3558)
	- Allow hubs to collect from themselves over loopback (ENT-3329)
	- Allow multiple sections in insert_ini_section (CFE-2721)
	- Ensure HA standby hubs have am_policy_hub state marker (ENT-3328)
	- fixed an error in the file_make_mustache_*, incorrect variable name used
	  (CFE-2714)
	- Add json templates for rendering serial and multiline data (CFE-2713)
	- Allow configuration of allowlegacyconnects from augments (ENT-3375)
	- Fix self upgrade for hosts older than 3.7.4 (ENT-3368)
	- Ignore empty options in apt_get module (CFE-2685)
	- cf-execd service override template now only kills cf-execd on stop
	  (ENT-3395)
	- Policy Release Id is now inventoried by default (CFE-2097)
	- Avoid triggering self upgrade during bootstrap (ENT-3394)
	- Maintain access to exported CSV reports in older versions (ENT-3572)
	- prevent yum from locking in package_methods when possible (CFE-2759)

3.10.2:
	- Disable package inventory via modules on redhat like systems with unsupported python versions
	  (CFE-2602)
	- Pass --oldpackage to zypper to allow downgrading packages, but check first if the zypper version supports it.
	  (CFE-2643)
	- Rename enable_client_initiated_reporting to client_initiated_reporting_enabled
	- Add postgres.log to enterprise log file rotation (ENT-3191)
	- Add: prunetree bundle to stdlib
	  The prunetree bundle allws you to delete files and directories up to a
	  sepcified depth older than a specified number of days.
	- Add the path to mailx on Linux, Darwin, OpenBSD, NetBSD and FreeBSD
	- Add aix OOTB oslevel inventory (ENT-3117)
	- Configure networks allowed to initiate report collection (client initiated reporting) via augments (#910)
	  (CFE-2624)
	- Add templates shortcut (CFE-2582)
	- Fix: suppress error about unknown lvalue
	- Configure call_collect_interval from augments (enable_client_initiated_reporting) (#905)
	  (CFE-2623)
	- Allow specification of files_single_copy via augments (CFE-2458)
	- Add zypper package module (CFE-2533)
	- zendesk#3432: fix zypper package downgrade
	- Enable settig def.max_client_history_size via augments (CFE-2560)
	- Enable specification of monitoring_include via augments (CFE-2505)
	- Include previous_state and untracked reports when client clear a buildup of unreported data
	  (ENT-3161)
	- Configure exclude_hosts in body hub control via augments (CFE-2622)
	- Change self upgrade now uses standalone policy (ENT-3155)
	- Directories for ubuntu 16 and centos 7 should exist in master_software_updates
	  (ENT-3136)
	- Add oslevel to well known paths. (ENT-3121)
	- server control maxconnections can be configured via augments
	  (CFE-2660)
	- Fix command to restart apache on config change (ENT-3134)
	- Add policy to track CFEngine Enterprise license utilization
	  (ENT-3186)
	- apt_get package module: Fix bug which prevented updates
	  from being picked up if there was more than one source listed in the
	  'apt upgrade' output, without a comma in between. (CFE-2605)
	- Change: Do not silence Enterprise hub maintenance
	- Remove bundle agent cfe_internal_bins (CFE-2636)

3.10.1:
	- Ensure MP SSL Cert is readable (ENT-3050)
	- Change Opportunisticaly monitor file integrity (ENT-3040)
	- Fix systemd unit restart when not running (CFE-2541)
	- Make stock policy update more resiliant (CFE-2587)
	- FixesMake apt_get module compatible with Ubuntu 16.04 (CFE-2445)
	- Add default report collection exclusion based on promise handle
	  (ENT-3061)
	- Fix: Automatic client upgrades for deb hosts
	- Do not symlink agents to /usr/local/bin on coreos (ENT-3047)
	- Add: Ability to set default_repository via augments

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
	- Change select_region INI_section to match end of section or end of file
	  (CFE-2519)
	- Fix ability to manage INI sections with metachars for
	  manage_variable_values_ini and set_variable_values_ini (CFE-2519)
	- Fix apt_get package module incorrectly using interactive mode.
	- Add ability to append to bundlesequnece with def.json (CFE-2460)
	- Behaviour change: when used with CFEngine 3.10.0 or greater,
	  bundles set_config_values() and set_line_based() are appending a
	  trailing space when inserting a configuration option with empty value.
	  (CFE-2466)

3.7.0:
 - Support for user specified overring of framework defaults without modifying
   policy supplied by the framework itself (see example_def.json)
 - Support for def.json class augmentation in update policy
 - Run vacuum operation on postgresql every night as a part of maintenance.
 - Add measure_promise_time action body to lib (3.5, 3.6, 3.7, 3.8)
 - New negative class guard `cfengine_internal_disable_agent_email` so that
   agent email can be easily disabled by augmenting def.json
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
 - Remove Diff reporting on /etc/shadow (Enterprise)
 - Update policy from promise.cf inputs. There is no reason to include the
   update policy into promsies.cf, update.cf is the entry for the update policy
 - _not_repaired outcome from classes_generic and scoped_classes generic (Redmine: # 7022)
 - standard_services now restarts the service if it was not already running
   when using service_policy => restart with chkconfig (Redmine #7258)
 - Fix process_result logic to match the purpose of body process_select
   days_older_than (Redmine #3009)
