# Changelog
Notable changes to the framework should be documented here

3.12.0:
	- Avoid executing self upgrade policy unnecessarily (ENT-3592)
	- Add amazon_linux class to yum package module
	- Introduce ability to set policy update bundle via augments (CFE-2687)
	- Localize delete tidy in ha update policy (ENT-3659)
	- Improve context notifying user of missing policy update bundle
	  (ENT-3624)
	- Configure ignore_missing_inputs and ignore_missing_bundles via augments
	  (CFE-2773)
	- Change class identifying runagent initiated executions from cfruncommand to cf_runagent_initated
	- Support enablerepo and disablerepo options in yum package_module
	  (CFE-2806)
	- Fix cf-runagent during 3.7.x -> 3.10.x migration
	  (CFE-2776, CFE-2781, CFE-2782)
	- Makes it possible to tune policy master_location via augments in update policy
	  (ENT-3692)
	- Fix inventory for total memory on AIX (CFE-2797)
	- Do not manage redis since it's no longer used (ENT-2797)
	- Server control maxconnections can be configured via augments
	  (CFE-2660)
	- Allow configuration of allowlegacyconnects from augments (ENT-3375)
	- Fix ability for zypper package_module to downgrade packages
	- Splaytime in body executor control can now be configured via augments
	  (CFE-2699)
	- Add maintenance policy to refresh events table on enterprise hubs
	  (ENT-3537)
	- Add apache config for new LDAP API (ENT-3265)
	- update.cf bundlesequence can be configured via augments (CFE-2521)
	- Update policy inputs can be extended via augments (CFE-2702)
	- Add oracle linux support to standalone self upgrade
	- Add bundle to track component variables to restart when necessary
	  (CFE-2326)
	- Retention of files found in log directories can now be configured via augments
	  (CFE-2539)
	- Allow multiple sections in insert_ini_section (CFE-2721)
	- Add lines_present edit_lines bundle
	- Schedule in body executor control can now be configured via augments
	  (CFE-2508)
	- Include scheduled report assets in self maintenance (ENT-3558)
	- Remove unused body action aggregator and body file_select folder
	- Remove unused body process_count check_process
	- Prevent yum from locking in package_methods when possible
	  (CFE-2759)
	- Render variables tagged for inventory from agent host_info_report
	  (CFE-2750)
	- Make apt_get package module work with repositories containing spaces in the label
	  (ENT-3438)
	- Allow hubs to collect from themselves over loopback (ENT-3329)
	- Log file max size and rotation limits can now be configured via augments
	  (CFE-2538)
	- Change: Do not silence Enterprise hub maintenance
	- Ensure HA standby hubs have am_policy_hub state marker (ENT-3328)
	- Add support for 32bit rpms in standalone self upgrade (ENT-3377)
	- Add enterprise maintenance bundles to host info report (ENT-3537)
	- Removed unnecessary promises for OOTB package inventory
	- Add external watchdog support for stuck cf-execd (ENT-3251)
	- Be less noisy when a promised service is not found (CFE-2690)
	- Ignore empty options in apt_get module (CFE-2685)
	- Add postgres.log to enterprise log file rotation (ENT-3191)
	- Removed unnecessary support for including 3.6 controls
	- Fix systemctl path detection
	- Policy Release Id is now inventoried by default (CFE-2097)
	- Fix to frequent logging of enterprise license utilization (ENT-3390)
	- Maintain access to exported CSV reports in older versions (ENT-3572)
	- cf-execd service override template now only kills cf-execd on stop
	  (ENT-3395)
	- Fix self upgrade for hosts older than 3.7.4 (ENT-3368)
	- Avoid self upgrade from triggering during bootstrap (ENT-3394)
	- Add json templates for rendering serial and multiline data (CFE-2713)
	- Removed unused libraries and controls
	- Fixed an error in the file_make_mustache_*, incorrect variable name used
	  (CFE-2714)
	- Fix augments control state paths to work on windows (ENT-3839)
	- Remove templates for deprecated components (ENT-3781)
	- Replace unicode smartquotes with apostrophe (ENT-3823)
	- Configure Enterprise hub pull collection schedule via augments
	  (ENT-3834)

3.11.0:
	- Rename enable_client_initiated_reporting to client_initiated_reporting_enabled
	- Directories for ubuntu 16 and centos 7 should exist in master_software_updates
	  (ENT-3136)
	- Fix: Automatic client upgrades for deb hosts
	- Add AIX OOTB oslevel inventory (ENT-3117)
	- Disable package inventory via modules on redhat like systems with unsupported python versions
	  (CFE-2602)
	- Make stock policy update more resiliant (CFE-2587)
	- Configure networks allowed to initiate report collection (client initiated reporting) via augments (#910)
	  (CFE-2624)
	- apt_get package module: Fix bug which prevented updates
	  from being picked up if there was more than one source listed in the
	  'apt upgrade' output, without a comma in between (CFE-2605)
	- Enable specification of monitoring_include via augments (CFE-2505)
	- Configure call_collect_interval from augments (enable_client_initiated_reporting) (#905)
	  (CFE-2623)
	- Add templates shortcut (CFE-2582)
	- Behaviour change: when used with CFEngine 3.10.0 or greater,
	  bundles set_config_values() and set_line_based() are appending a
	  trailing space when inserting a configuration option with empty value
	  (CFE-2466)
	- Add default report collection exclusion based on promise handle
	  (ENT-3061)
	- Fix ability to select INI region with metachars (CFE-2519)
	- Change: Verify transfered files during policy update
	- Change select_region INI_section to match end of section or end of file
	  (CFE-2519)
	- Add class to enable post transfer verrification during policy updates
	- Add: prunetree bundle to stdlib
	  The prunetree bundle allws you to delete files and directories up to a
	  sepcified depth older than a specified number of days
	- Do not symlink agents to /usr/local/bin on coreos (ENT-3047)
	- Add: Ability to set default_repository via augments
	- Enable settig def.max_client_history_size via augments (CFE-2560)
	- Change self upgrade now uses standalone policy (ENT-3155)
	- Fix apt_get package module incorrectly using interactive mode
	- Add ability to append to bundlesequnece with def.json (CFE-2460)
	- Enable paths to POSIX tools by default instead of native tools
	- Remove bundle agent cfe_internal_bins (CFE-2636)
	- Include previous_state and untracked reports when client clear a buildup of unreported data
	  (ENT-3161)
	- Fix command to restart apache on config change (ENT-3134)
	- cf-serverd listens on ipv4 and ipv6 by default (CFE-528)
	- FixesMake apt_get module compatible with Ubuntu 16.04 (CFE-2445)
	- Fix rare bug that would sometimes prevent redis-server from launching
	- Add oslevel to well known paths (ENT-3121)
	- Add policy to track CFEngine Enterprise license utilization
	  (ENT-3186)
	- Ensure MP SSL Cert is readable (ENT-3050)

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
