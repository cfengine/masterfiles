# Changelog
Notable changes to the framework should be documented here

3.14.0:
	- Fixed isvariable syntax error in update_def.cf (CFE-2953)
	- Added path support for setfacl, timedatectl and journalctl (CFE-3013)
	- Added trailing slash to access promises expecting directories
	  (CFE-3024)
	- Added scripts and templates for Federated Reporting (ENT-4473)
	- rpm python module is no longer required to check zypper version
	- Changed cleanup consumer status SQL query (ENT-4365)
	- Conditioned use of curl for ec2 metadata cache on curl binary being executable
	  (CFE-3049)
	- Added augments variables to control cf-hub (ENT-4269)
	- Prevented DB maintenance tasks on a passive High Availability hub (ENT-4706)
	- Repair outcome for starting cf-monitord or cf-execd is no longer suppressed
	  (CFE-2964)
	- Restrictive permissions on hub install log are now enforced (ENT-4506)
	- Ensured that asynchronous query API semaphores are writable (ENT-4551)
	- Fixed standalone_self_upgrade not triggering because of stale data
	  (ENT-4317)
	- Fixed maintenance policy for promise log cleanup to respect history_length_days
	  (ENT-4588)
	- Improved efficiency and error handling of user specified policy update bundle
	- Log version of Enterprise agent outside of state (ENT-4352)
	- Added package module for managing windows packages using msiexec (ENT-3719)
	- Prevented inventorying un-expanded memory values from cf-monitord (ENT-4522)
	- Prevented performance overhead on hubs that don't enable license utilization logging
	  (ENT-4333)
	- Collection status records in the future are now purged (ENT-4362)
	- Reduced cost of knowing when setopt is available in yum (CFE-2993)
	- runalerts is now restarted if modified (ENT-4273)
	- Separated kill signals from restart class to avoid warning (CFE-2974)
	- Separated termination and observation promises for cf-monitord
	  (CFE-2963)
	- Set default access promises for directories to only share if directory exists
	  (CFE-3060)
	- Set default value for purge_scheduled_reports_older_than_days
	  (ENT-4404)
	- Added more accurate and descriptive daemon classes
	- collect_window in body server control can now be set from augments
	  (ENT-4283)
	- Guarded vars promises in cfe_internal_enterprise_mission_portal_apache
	  Constrain vars promises in cfe_internal_enterprise_mission_portal_apache
	  to policy_server.enterprise_edition::, otherwise "cf-promises --show-vars"
	  includes a dump of the entire datastate from the "data" variable in
	  cfe_internal_enterprise_mission_portal_apache (line over 100K long).
	  (CFE-3011)
	- redhat_pure is no longer defined on Fedora hosts (CFE-3022)

3.13.0:
	- Add debian 9 to the self upgrade package map (ENT-4255)
	- Add 'system-uuid' to default dmidecode inventory (CFE-2925)
	- Add inventory of AWS EC2 linux instances (CFE-2924)
	- Add ubuntu 18 to package map for self upgrade (ENT-4118)
	- Allow dmidefs inventory to be overridden via augments (CFE-2927)
	- Analyze yum return code before parsing its output (CFE-2868)
	- Fixed issue when promise to edit file that does not exist caused "promise
	  not kept" condition (ENT-3965)
	- Avoid trying to read /proc/meminfo when it doesn't exist (CFE-2922)
	- Avoid use of $(version) for package_version in legacy implementation
	  (ENT-3963)
	- Cleanup old report data relative to the most recent changetimestamp
	  (ENT-4807)
	- Clear `__lastseenhostslogs` every 5 minutes. (ENT-3550)
	- Configure Enterprise hub pull collection schedule via augments
	  (ENT-3834)
	- Configure agent_expireafter from augments (ENT-4308)
	- Create desired version tracking data when necessary (ENT-3937)
	- Cron based watchdog for cf-execd on AIX (ENT-3963)
	- Detect systemd service enablement for non native services (CFE-2932)
	- Document how def.acl is used and how to configure it (CFE-2861)
	- Fix augments control state paths to work on windows (ENT-3839)
	- Fix package_latest detecting larger version in some cases (CFE-1743)
	- Fix standalone self upgrade when path contains spaces (ENT-4117)
	- Fix unattended self upgrade on AIX (ENT-3972)
	- Fix services starting on windows (ENT-3883)
	- Improve performance of enterprise license utilization logging
	- Inventory Memory on HPUX (ENT-4188)
	- Inventory Physical Memory MB when dmidecode is found (CFE-2896)
	- Inventory Setuid Files (ENT-4158)
	- Inventory memory on Windows (ENT-4187)
	- Make recommendations about postgresql.conf (ENT-3958)
	- Only consider files that exist for rotation (ENT-3946)
	- Prevent noise when a service that should be disabled is missing.
	  (CFE-2690)
	- Prevent standalone self upgrade from triggering un-necessarily
	  (ENT-4092)
	- Remove Design Center related policies
	  Design center never left beta and has been deprecated. Supporting policies have
	  been removed. If you wish to continue using design center sketches you must
	  incorporate them into inputs and the bundlesequence manually.
	  (ENT-4050)
	- Remove unicode characters (ENT-3823)
	- Remove templates for deprecated components (ENT-3781)
	- Remove un-necessary agent run during self upgrade (ENT-4116)
	- Slackware package module support (CFE-2827)
	- Specify scope => "namespace" when using persistent classes (CFE-2860)
	- Store the epoch of packages in cache db with zypper
	- Sync cf-runalerts override unit template with package (ENT-3923)
	- Update policy can now skip local copy optimization on policy servers
	  (CFE-2932)
	- Updated yum package module to take arbitrary options (ENT-4177)
	- Use default for package arch on aix (ENT-3963)
	- Use rpmvercmp for version comparison on AIX (ENT-3963)
	- Users allowed to request execution via cf-runagent can be configured
	  (ENT-4054)
	- apt_get package module includes held packages when listing updates
	  (CFE-2855)

3.12.0b1:
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
