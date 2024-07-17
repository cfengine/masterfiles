3.24.0:
	- AIX watchdog now handles stale pids (CFE-4335)
	- Added ability to configure Mission Portal Apache SSLCACertificateFile via Augments
	  (ENT-11421)
	- Added ability to configure SSLCipherSuite via Augments (ENT-11393)
	- Added ability to influence default package manager and inventory via Augments
	  (CFE-3612)
	- Added freebsd package_module and package_inventory since we have pkg packages module available
	  (CFE-4345)
	- Added no_backup_cp_compare copy_from body to stdlib
	  Like the existing no_backup_cp this copy_from body is used to copy files locally
	  without making backups but with the additional ability to specify the comparison
	  used. (ENT-10962)
	- Added recommendation for installing gnu parallel on federated reporting superhubs
	  (ENT-8785)
	- Added set_escaped_user_field complementing set_user_field (CFE-4377)
	- Added setup-feeder option to distributed cleanup script (ENT-11844)
	- Aligned ownership and permission expectations between Mission Portal and MPF
	  (ENT-11941)
	- Changed mission-portal apache restart to graceful to minimize service interruptions
	  (ENT-11526)
	- Federated reporting policy now properly fixes SELinux context of the
	  ~cftransport/.ssh directory and its contents in a single agent
	  run. (ENT-11136)
	- Fixed comparison that caused control_executor_mailfilter_*_configured to never be set
	  (CFE-4374)
	- Fixed distributed_cleanup policy for feeders and rhel-8 superhubs
	  (ENT-10960)
	- Fixed restoration of Mission Portal application to packaged content when modified
	  (ENT-10962)
	- Freebsd service management now uses one prefixed service commands
	  (CFE-4323)
	- Improved federation policy handling of cftransport selinux configuration
	  (ENT-10959)
	- Improved instructions and added report to instruct users how to disable recommendations
	  (ENT-11523)
	- Inventory view is now refreshed in cf-reactor instead of through policy
	  (ENT-11763)
	- Made enterprise federated reporting dump interval configurable via Augments
	  (ENT-10900)
	- Policy now manages Mission Portals httpd.conf ownership and permissions
	  (ENT-11096)
	- Refactored AWS IMDS retrieval to support both IMDSv1 and IMDSv2
	  (ENT-10988)
	- Refactored extraction of home directory from parsing getent output to getuserinfo()
	  (CFE-4375)
	- Removed hour delay between CFEngine Enterprise PostgreSQL recommendation checks
	  (ENT-11480)
	- Squashed common error logged by Apache related to IPv6 (ENT-10646)
	- When failing to detect platform, inventory attribute "OS" now
	  defaults to PRETTY_NAME from os-release as a fallback (CFE-4342)

3.23.0:
	- Added ability to disable plain http for CFEngine Enterprise Mission Portal
	  (ENT-10411)
	- Added ability to enable backup archives during policy update
	  (ENT-10481)
	- Added ability to extend without overriding filename patterns to copy during policy update
	  (ENT-10480)
	- Added bundle to facilitate migration of ignore_interfaces.rx from inputdir to workdir
	  (ENT-9402)
	- Added self upgrade support for Amazon Linux 2 (ENT-10820)
	- Added ss to paths for linux (ENT-10413)
	- Aligned systemd service templates with core
	  WantedBy=cfengine3.service was removed from systemd service templates
	  for individual components. It was un-necessary as cfengine3.service already
	  wants the individual services.
	  https://github.com/cfengine/core/pull/5362
	  Ticket: (CFE-3982)
	- Avoided deleting python symlink when sys.bindir is not /var/cfengine/bin
	  (CFE-4146)
	- Changed default self upgrade target version to be that of Hubs binary version
	  (ENT-10664)
	- Fixed OS inventory for Amazon Linux 2 (ENT-10817)
	- Fixed apache listening on port 80 by default (ENT-10672)
	- Fixed cfe_autorun_inventory_aws_ec2_metadata_cache file creation
	  Ticket: (CFE-4221)
	- Removed jq dependency and fixed lib/testing.cf tap output (CFE-4245, CFE-4246, CFE-4223)
	- Fixed self-upgrade for Debian and Ubuntu aarch64 clients (ENT-10816)
	- Guard against /sys/hypervisor/uuid not being readable (ENT-9931)
	- Made Mission Portal Apache SSLProtocol configurable via augments
	  (ENT-10412)
	- Made allowconnects and allowallconnects configurable via Augments
	  (ENT-10212)
	- Made lastseenexpireafter in body common control configurable via Augments
	  (ENT-10414)
	- Removed considerations for old versions from bundle agent cfe_autorun_inventory_aws_ec2_metadata_cache
	  (CFE-4222)
	- Stopped filtering $(sys.bindir) from dynamically determined python path
	  (CFE-4223)
	- Fixed recommendation policy execution (ENT-10915)
	- Fixed postgresql.conf recommendations (ENT-10916)
	- Added rendering of custom mustache templates to $(sys.workdir)/modules (ENT-10793)
	- Fixed support for automatically installing semanage on el9 for federated reporting (ENT-10918)
	- Improved failure logging during federated reporting schema import (ENT-10789)
	- Added default:cfengine_mp_fr_debug_import class for federated reporting import debugging (ENT-10896)
	- Made $(sys.policy_hub) always be included in default:def.acl, allowconnects, and allowallconnects unless explicitly disabled
	  (ENT-10951)

3.22.0:
	- Added inventory for policy version (ENT-9806)
	- Added condition to runalerts service to require stamp directory
	  (ENT-9711)
	- Added guards against using regline() in cases where a file may not exist
	  (ENT-9933)
	- Added self upgrade support for Ubuntu 22.04, Debian 11, and EL9
	  (ENT-10290)
	- Added ssl_request_log to list of hub log files (ENT-10192)
	- Added support for Rocky Linux in self upgrade policy (ENT-10335)
	- Adjusted dump.sh for multiple runs in between superhub imports
	  (ENT-10274)
	- Aligned module build result with release artifact (ENT-10345)
	- Fixed body perms system_owned to account for Windows (ENT-9778)
	- Fixed SUSE package_inventory defaults (ENT-10248)
	- Improved federated reporting dump concurrency with database
	  (ENT-10214)
	- Made TLS settings for components other than cf-serverd configurable via augments
	  (ENT-10198)
	- Made agentfacility in body agent control configurable via Augments
	  (ENT-10209)
	- Made allowciphers in body server control configurable via Augments
	  (ENT-10182)
	- Made allowtlsversion in body server control configurable via Augments
	  (ENT-10182)
	- Made body maxmaillines in body executor control configurable via Augments
	  (ENT-9614)
	- Made mailsubject, mailfilter_include, and mailfilter_exclude configurable via Augments
	  (ENT-10210)
	- Made package cache refresh for common_knowledge.list_update_ifelapsed configurable
	  This change makes the number of minutes to wait between package cache updates
	  for some package_method bodies configurable via augments.
	  The package_method bodies affected by this include:
	  - body package_method pip(flags)
	  - body package_method npm(dir)
	  - body package_method npm_g
	  - body package_method brew(user)
	  - body package_method apt
	  - body package_method apt_get
	  - body package_method apt_get_permissive
	  - body package_method apt_get_release(release)
	  - body package_method dpkg_version(repo)
	  - body package_method rpm_version(repo)
	  - body package_method yum
	  - body package_method yum_rpm
	  - body package_method yum_rpm_permissive
	  - body package_method yum_rpm_enable_repo(repoid)
	  - body package_method yum_group
	  - body package_method rpm_filebased(path)
	  - body package_method ips
	  - body package_method smartos
	  - body package_method opencsw
	  - body package_method emerge
	  - body package_method pacman
	  - body package_method zypper
	  - body package_method generic
	  Additionally note that the package related bundles use the package_method bodies
	  mentioned above and are similarly influenced.
	  - bundle agent package_present(package)
	  - bundle agent package_latest(package)
	  - bundle agent package_specific_present(packageorfile, package_version, package_arch)
	  - bundle agent package_specific_absent(packageorfile, package_version, package_arch)
	  - bundle agent package_specific_latest(packageorfile, package_version, package_arch),
	  - bundle agent package_specific(package_name, desired, package_version, package_arch)
	  (CFE-4178)
	- Prevented management of runagent socket users when no users are listed
	  (ENT-9535)
	- Removed specific old CFEngine version package module handling for windows
	  (ENT-9948)
	- Started inventorying currently mounted file system types and mount points
	  (ENT-8338)

3.21.0:
	- Added inventory for Raspberry Pi and DeviceTree devices (ENT-8628)
	- Added policy to enforce proper permissions on Mission Portal ldap directory (ENT-9693)
	- Added check to make sure cf-execd is running after attempting self upgrade on Windows
	- Added exception for ldap directory perms for settings.ldap.php (ENT-9697)
	  (ENT-9573)
	- Added date to known paths for linux (CFE-4069)
	- Added fallback to top-level feeder dump directory (ENT-8936)
	- Added self upgrade knowledge for Suse 12, 15 and opensuse leap 15
	  (ENT-9209)
	- Added self upgrade knowledge for debian 11 (ENT-9210)
	- Added ssh in paths.cf so that policy writers can use $(paths.ssh)
	  (CFE-4037)
	- Added support for multiple superhubs per feeder (ENT-8936)
	- Amazon Linux now uses --setopt-exit_on_lock=True in redhat_no_locking_knowledge
	  (ENT-9057)
	- Avoided error stopping apache when no pid file exists (ENT-9108)
	- Disabled explicit setting for SSLCompression for Mission Portal Apache.
	  OpenSSL3 does not provide compression capability, when enabled
	  Apache will not start.
	  (ENT-8933)
	- Fixed deleting multiple hosts with distributed cleanup utility
	  (ENT-8979)
	- Fixed directory in which windows agents source packages for upgrade
	  (ENT-9010)
	- Fixed services_autorun_inputs working independently from services_autorun
	  (CFE-4017)
	- Fixed set_line_based() for case when edit_defaults.empty_before_use is true
	  (ENT-5866)
	- Made proc inventory configurable via Augments (CFE-4056)
	- Make device-tree inventory quieter in containers (ENT-9063)
	- Stopped applying locks to masterfiles-stage (ENT-9625)
	- Stopped loading several Apache modules on Enterprise Hubs by default:
	  mod_auth_basic, mod_authz_host, mod_authz_owner, mod_dbd,
	  mod_authn_file, mod_authz_dbm (ENT-8607, ENT-8602, ENT-8706,
	  ENT-8609, ENT-9072, ENT-8605)
	- Updated filename conventions for AIX and Solaris packages (ENT-9095)
	- Fixed detection of location for httpd.pid (ENT-9603)
	- Added policy to manage permissions for php/runalerts-stamp (ENT-9703)
	- Ensured manual edits to httpd.conf are reverted (ENT-9686)

3.20.0:
	- Renamed bundle agent main to bundle agent mpf_main (CFE-3947)
	- Added prelink to paths.cf
	- Added Enterprise Hub postgresql.conf to files monitored for diffs by default
	  (ENT-8618)
	- Added PostgreSQL tunables for Federated Reporting (ENT-8617)
	- Added lib/templates to packaged assets (ENT-8533)
	- Added policy to patch apachectl for more robust stopping on Enterprise Hubs
	  (ENT-8823)
	- Added policy update exclusion for directories named .no-distrib
	  (ENT-8079)
	- Added support for 'option' option in pkg module (CFE-3568)
	- Added support for Amazon Linux in standalone self upgrade (ENT-8274)
	- Added support for downloading windows packages as part of self upgrade
	  (ENT-8283)
	- Adjusted MPF to handle rxdirs default from true to false (CFE-951)
	- 755 perms on hub htdocs dir are now enforced (ENT-8212)
	- Proper owner and perms on docroot are now enforced(ENT-8280)
	- Prevented def.dir_masterfiles/.no-distrib from being copied
	  (ENT-8079)
	- Cleaned up policy related to versions prior to 3.12 (CFE-3920)
	- Removed policy deprecated by sys.os_release (CFE-3933)
	- Updated bundle names and wording to reflect current tooling
	  (CFE-3921)
	- Enabled setting environment attribute in body agent control via augments
	  (CFE-3925)
	- Fixed inclusion of distributed cleanup python files during install
	  (ENT-8393)
	- Fixed inventory for OS on Rocky Linux (ENT-8292)
	- Fixed promise status from package upgrade when architecture specified in promise
	  (CFE-3568)
	- Made body classes u_kept_successful_command_results inherit_from u_results
	  (CFE-3917)
	- Made CMDB update ignore locks (ENT-8847)
	- Updating host-specific CMDB data files now happens asynchronously
	  (ENT-7357)
	- Fixed issue with apt_get package module on Ubuntu 22 (CFE-3976)
	- Fixed parsing of options attribute and added repo alias for repository option in pkg module
	  (CFE-3568)
	- Fixed pkg module parsing input when values include equals (=)
	  (CFE-3568)
	- Warn about missing dependencies for Distributed Cleanup utility
	  (ENT-8832)
	- Fixed AIX watchdog default threshold for number of cf-execd processes
	  (CFE-3915)
	- Stopped lowercasing software inventory on Windows (ENT-8424)
	- Fixed windows unattended self upgrade on Windows 2008 (ENT-8066)
	- Invalid feeder dump files are now skipped during import (ENT-8229)
	- Fixed FR clean bundle when off state (ENT-7969)
	- Fixed psql not found while FR import (ENT-8353)
	- Now clean_when_off FR bundle is only run when needed (ENT-8294)

3.19.0:
	- Added interpreter attribute to standalone self upgrade package_module bodies
	  (CFE-3703, ENT-5752)
	- Added almalinux as a know derivative of rhel (ENT-7644)
	- Added class to prevent hub from seeding binary packages for use in self upgrade
	  (ENT-7544)
	- Added cleanup of database and status semaphore when federation target_state is off
	  (ENT-7233)
	- Added custom promise python library
	- Added distributed_cleanup utility for Federated Reporting (ENT-7215)
	- Added fallback logic for determining installed software version on Windows
	  (ENT-7501)
	- Added lsmod to well known paths (CFE-3790)
	- Added script to cleanup artifacts after cfbs build (CFE-3781)
	- Added self upgrade support for SUSE (ENT-7446)
	- Added separate classes for controlling autorun inputs and bundles
	  The class services_autorun continues to enable both automatic inclusion of .cf
	  files in services/autorun and the running of bundles tagged with autorun.
	  This change adds the classes services_autorun_inputs and
	  services_autorun_bundles for independently enabling addition of .cf files in
	  services/autorun and automatic execution of bundles tagged with autorun
	  respectively.  (CFE-3715)
	- Added support for downloading community packages on hub in preparation for binary upgrades
	- Added variable for excluding files from Policy Analyzer (ENT-7684)
	- Adjusted badges for 3.18.0 release (ENT-6713)
	- Adjusted permissions for Mission Portal public tmp files (ENT-7261)
	- Autorun bundles now run regardless of locks
	  Previously, when the autorun feature was enabled to automatically run bundles
	  tagged with autorun the bundle actuation was affected by promise locking. The
	  effect of this is that agent runs that happen close together would skip running
	  bundles run within the last minute. Now autorun bundles no longer wait for a
	  lock to expire, they will be actuated each agent execution. Note, promises
	  within those bundles have their own locks which still apply.  (CFE-3795)
	- Dropped un-necessary local variable
	  The use of this local variable triggers a bug that prevents datastate() from
	  printing. Since the variable is un-necessary, it's been removed and the
	  parameter is used directly.  (CFE-3776)
	- Enforced permissions for Postgres log (ENT-7961)
	- Fixed package module augments settings usage for pre 3.15.3 binaries
	  (ENT-7356, ENT-7358)
	- Fixed path in permissions and ownership promise for application log dir
	  (ENT-7731)
	- Fixed services_autorun_bundles only case (CFE-3799)
	- Fixup zypper package module script to work properly with interpreter attribute
	  (ENT-7442)
	- Gave cfapache group full access to docroot (ENT-8065)
	- Insured exported reports from Mission Portal are in the correct location
	  (ENT-7465)
	- Made apache restart more robust (ENT-8045)
	- Moved httpd.pid to root of httpd workdir (ENT-7966)
	- Physical Memory (MB) inventory now handles dmidecode MB or GB units
	  (ENT-7714)
	- Promised permissions for Mission Portal application and Apache log files
	  This change ensures that both Mission Portal and Apache log files have
	  restrictive permissions. Previously this was un-managed.  (ENT-7730)
	- Reduced scope of report informing of missing systemd service
	  (CFE-290, ENT-7360)
	- Removed build dir from install/dist targets (ENT-7359)
	- Removed stale CMDB inventory policy (CFE-3712)
	- Set apache umask to 0177 (ENT-7948)
	- State changes of systemd services during agent run are now properly registered
	  (CFE-3753)
	- Stopped enforcing permissions of modules in inputs
	  This change removes explicit enforcement of permissions for modules in inputs.
	  Instead of explicitly enforcing permissions in inputs, we rely on the default
	  permissions (600). The previous explicit permissions (755) are un-necessary as
	  modules are not executed from within the inputs directory and have resulted in
	  permission flip-flopping in some environments. Permissions on modules in the
	  modules dir (sys.workdir)/modules are still enforced.  (ENT-7733)
	- Switched from using package_method generic to default package_module
	  for windows software inventory (ENT-2589)
	- Improved the reliability when detecting a Red Hat system.
	  Now if the ID field in /etc/os-release is set to rhel, the redhat_pure class
	  will be defined.
	  If the variable sys.os_release does not exist, redhat_pure is defined if we have already
	  defined redhat and we do not find classes for well known derivatives
	- rocky, a class defined on Rocky Linux was added to the list of well known derivatives
	  (ENT-7628)
	- Added advisory lock for Federated Reporting operations (ENT-7474)
	- controls/cf_serverd.cf no longer specifies explicit
	  default for bindtointerface and relies on the default
	  binding to both :: and 0.0.0.0 on IPV6-enabled hosts
	  (ENT-7362)
	- setup-status.json is no longer being repaired over and over on FR feeder hubs
	  (ENT-7967)

3.18.0:
	- Added .ps1 to list of file patterns considered during policy update
	  (ENT-4094)
	- Added ability to specify additional directories to add autorun policy from
	  (CFE-3524)
	- Added default cf_version_release of 1 when sys var missing (ENT-6219)
	- Added description of psql_lock_wait_before_acquisition measurement
	  (ENT-6841)
	- Added inventory of Setgid files and Setgid files that are root owned
	  (ENT-6793)
	- Added inventory of users and hosts allowed to use cf-runagent
	  (ENT-6666)
	- Added measurement of entropy available on linux systems (ENT-6495)
	- Added missing packages modules scripts in makefile (ENT-6814)
	- Added new interface for controlling users allowed to initiate cf-agent via cf-runagent
	  (CFE-3544)
	- Added policy for permissions on cf-execd sockets on Enterprise Hubs
	  (ENT-6777)
	- Added redirect to remove index.php from Mission Portal's URL
	  (ENT-6464)
	- Added standalone self upgrade capability for Windows agents
	  (ENT-6219, ENT-6823)
	- Added tail & tail_n to standard library (CFE-3558)
	- Added vars.mpf_admit_cf_runagent_shell to control admission for cf-runagent requests
	  (ENT-6673)
	- Added verbose logfile for msiexec package module file installs
	  (ENT-6220, ENT-6824)
	- Changed default behavior of policy update to keep inputs in sync with masterfiles
	  Prior to this change, the default behavior of the MPF was to only ensure that
	  files in masterfiles were up to date with the files in inputs. Files in inputs
	  that did not exist in masterfiles were left undisturbed. To enable sync
	  behavior (a common user expectation) you had to explicitly define
	  'cfengine_internal_purge_policies'. Now, if you wish to return to the previous
	  default behavior, define the class 'cfengine_internal_purge_policies_disabled'.
	  Ticket: (CFE-3662)
	- Changed msiexec package module install logs to be unique for each msi file
	  (ENT-6824)
	- Disabled TLSv1 by default for Mission Portal's web server (ENT-6783)
	- Do not apply redirect from index.php to internal APIs (ENT-6464)
	- Enabled packages promises using package_module without bundle def
	  (CFE-3504)
	- Fixed ability to define users authorized for using cf-runagent on policy servers
	  (CFE-3546)
	- Fixed alpine apk packages module to parse names properly (CFE-3585)
	- Fixed cfengine_mp_fr_handle_duplicate_hostkeys class usage in policy
	  (ENT-7094)
	- Fixed docs describing xdev behavior in depth_search bodies (CFE-3541)
	- Fixed loading of platform specific inventory on AIX (CFE-3614)
	- Made Enterprise CMDB data update after policy update (ENT-6788)
	- Prevent setgid files from causing continual repair related to setuid file inventory
	  (ENT-6782)
	- Removed stale unused copy of u_kept_successful_command body. If you
	  receive an error about undefined body, alter your policy to use
	  kept_successful_command instead (CFE-3617)
	- Removed unused plugins directory (CFE-3618)
	- Renamed python symlink to cfengine-selected-python (CFE-3512)
	- Shortened Inventory OS attribute to be more readable (ENT-6536)
	- Suppressed inform output from Enterprise Hub database maintenance operations
	  (ENT-6563)
	- Suppressed output from watchdog on AIX to prevent the mail spool from filling up
	  (CFE-3630)
	- Added ability to specify a list of bundles to run before autorun (for classification) (ENT-6603)
	- Update policy now moves obstructions (CFE-2984)
	- Use VBScript to enumerate installed packages (ENT-4669)
	- add /usr/bin/yum to paths.cf for aix (CFE-3615)
	- service status on FreeBSD now uses onestatus (CFE-3515)
	- Guard again enforcing root ownership for CFEngine files on Windows (ENT-4628)

3.17.0:
	- Added .csv to the list of file extensions considered by default during
	  policy update (CFE-3425)
	- Added ability to extend known paths without modifying vendored policy
	  (CFE-3426)
	- Added apk package module support for alpinelinux (CFE-3451)
	- Added bundle edit_line converge_prepend with same behavior as bundle
	  edit_line converge, but inserting at start of content. (CFE-3483)
	- Added inventory for Timezone and GMT Offset (ENT-6161)
	- Added inventory for policy servers (ENT-6212)
	- Added maintenance policy to update health diagnostics failures table on
	  enterprise hubs (ENT-6228)
	- Added optional handle duplicates step in federated reporting import
	  (ENT-6035)
	- Added replace_uncommented_substrings (ENT-6117)
	- Added service states "active" and "inactive" for systemd (ENT-6074)
	- Added watchdog for Windows (ENT-5538)
	- Adjusted package_module and paths for termux platform (CFE-3288)
	- Aligned systemd services behavior for service_policy => "enable|enabled|disable|disabled"
	  (ENT-6073)
	- Changed bundle server access_rules to mpf_default_access_rules
	  (CFE-3427)
	- Cleaned up Mission Portal OS variable (inventory_os.description) on RHEL 5 & 6
	  (ENT-6124)
	- De-duplicated license headers (ENT-6040)
	- Fixed converge edit_line bundle not deleting lines containing marker
	  (CFE-3482)
	- Fixed interpretation of cf-hub --show-license from REPAIRED to KEPT
	  (ENT-6473)
	- Inventory OS variable (inventory_os.description in policy) is now based on os-release
	- Made git_stash only stash untracked files when capable (CFE-3383)
	- Moved systemd service management to own bundle (CFE-3381)
	- Removed delay in refreshing software installed inventory (ENT-6154)
	- Removed unnecessary packages promise on SuSE (ENT-5480, ENT-6375)
	- Replaced @ignore with useful doc strings (CFE-3378)

3.16.0:
	- /var/cfengine/bin/python symlink creation on SLES was fixed
	- Added 'data' shortcut to cf-serverd, defaults to sys.workdir/data
	- Added inventory for CFEngine Enterprise License information
	  (ENT-5089, ENT-5279)
	- Added inventory of NFS servers in use (from /proc/mounts, on linux)
	  (CFE-3259)
	- Added inventory of license owner on enterprise hubs (ENT-5337)
	- Added paths support for opensuse (CFE-3283)
	- Added use of services promise for FR PostgreSQL reconfig in case of
	  systemd (ENT-5420)
	- Added zypper as default package manager for opensuse (CFE-3284)
	- Admitted ::1 as a query source on Enterprise hubs (ENT-5531)
	- Aligned unattended self upgrade package map with current state
	  (ENT-6010)
	- Always copy modules from masterfiles (CFE-3237)
	- Changed DocumentRoot of Mission Portal in httpd.conf to
	  `/path/to/cfengine/httpd/htdocs/public` (ENT-5372)
	- Changed group for state dir files promise to match defaults per OS
	  (CFE-3362)
	- Changed m_inventory dumping behavior to exclude when values is null
	  (ENT-5562)
	- Corrected application/logs path to outside of docroot (ENT-5255)
	- Deleted deprecated __PromiseExecutionsLog from process that cleans
	  log tables (ENT-5170)
	- Fixed dmi inventory to prefer sysfs to dmidecode for most variables
	  for improved performance and to handle CoreOS hosts that don't
	  have dmidecode.  (CFE-3249)
	- Fixed permission flipping when policy analyzer is enabled (ENT-5235)
	- Fixed runalerts processes promise on non-systemd systems (ENT-5432)
	- Fixed selection of standard_services when used from non-default
	  namespace (ENT-5406)
	- Fixed system UUID inventory for certain VMWare VMs where dmidecode
	  gives UUID bytes in wrong order.  (CFE-3249)
	- Fixed typo preventing recommendation bundles from running (CFE-3305)
	- HA setups no longer have flipping permissions on
	  /opt/cfengine/notification_scripts
	- Improved resilience of cron watchdog for linux (CFE-3258)
	- Inventory refresh is no longer part of agent run on the hub
	  (ENT-4864)
	- Made python symlink fall back to platform-python (CFE-3291)
	- Made set_variable_values_ini prefer whitespace around = (CFE-3221)
	- Modified cftransport cleanup to avoid errors (ENT-5555)
	- Moved 'selinux_enabled' class to config bundle and namespace scope it
	- Prevented inventory of unresolved variables for diskfree and loadavg
	  (ENT-5190)
	- Release number was added to MPF tarballs (ENT-5429)
	- Standard services now considers systemd services in
	  ActiveState=activating active (CFE-3238)
	- Stopped continual repair of ha_enabled semaphore (ENT-4715)
	- Stopped disabling disabled systemd unit each run when disabled state
	  requested (CFE-3367)
	- Stopped trying to edit fields in manage_variable_values_ini
	  (CFE-3372)
	- Suppressed useless inform output from /bin/true in ec2 inventory
	  (ENT-5233)
	- Switched from hardcoded path to /bin/true to use paths from stdlib
	  (ENT-5278)
	- The zypper module is now fully compatible with Python 3 (CFE-3364)
	- Whitespace is now allowed at the beginning of ini key-values
	  (CFE-3244)
	- apt_get package module now checks package state (CFE-3233)

3.15.0:
	- Added package_module for snap (CFE-2811)
	- Fixed pkgsrc in case where multiple Prefix paths are returned for pkg_install (CFE-3152)
	- Fixed pkgsrc module on Solaris/NetBSD (CFE-3151)
	- Moved zypper package module errors to the cf-agent output (CFE-3154)
	- Added new class mpf_enable_cfengine_systemd_component_management to enable
	  component management on systemd hosts. When defined on systemd hosts policy
	  will render systemd unit files in /etc/systemd/system for managed services
	  and that all units are enabled unless explicitly disabled. When this class
	  is not defined on systemd hosts the policy will not actively mange cfengine
	  service units (no change from previous behavior) (CFE-2429)
	- Fixed detection of service state on FreeBSD (CFE-3167)
	- Added known paths for true and false on linux
	  (ENT-5060)
	- Fixed path for restorecon on redhat systems to /sbin/restorecon
	- Added usermod to known paths for redhat systems
	- Added policy to manage federated reporting with CFEngine Enterprise
	- Introduced augments variable `control_hub_query_timeout` to control cf-hub query timeout.
	  (ENT-3153)
	- Added OOTB inventory for IPv6 addresses (sans ::1 loopback)
	  (ENT-4987)
	- Added and transitioned to using master_software_updates shortcut in self upgrade policy
	  (ENT-4953)
	- Added brief descriptions to bodies and bundles in cfe_internal/CFE_cfengine.cf
	  (CFE-3220)
	- Added support for SUSE 11, 12 in standalone self upgrade (ENT-5045, ENT-5152)
	- Changed policy triggering cleanup of __lastseenhostlogs to target only
	  3.12.x, 3.13.x and 3.14.x. From 3.15.0 on the table is absent. (ENT-5052)
	- Fixed agent disabling on systemd systems (CFE-2429, CFE-3416)
	- Ensured directory for custom action scripts is present (ENT-5070)
	- Excluded Enterprise federation policy parsing on incompatible versions
	  (CFE-3193)
	- Extended watchdog for AIX (ENT-4995)
	- Fixed cleanup of future timestamps from status table
	  (ENT-4331, ENT-4992)
	- Fixed re-spawning of cf-execd or cf-monitord after remediating duplicate concurrent processes
	  (CFE-3150)
	- Replaced /var/cfengine with proper $(sys.*) vars (ENT-4800)
    - Fixed selection of standard_services when used from non-default namespace (ENT-5406)

3.15.0b1:
	- Added continual checking for policy_server state (CFE-3073)
	- Added monitoring for PostgreSQL lock acquisition times (ENT-4753)
	- Added support for 'awk' filters in the FR dump-import process (ENT-4839)
	- Added support for configuring abortclasses and abortbundleclasses via
	  augments (ENT-4823)
	- Added support for filtering in both dump and import phases of the FR
	  ETL process (ENT-4839)
	- Added support for ordering FR awk and sed scripts (ENT-4839)
	- Added support for setting periodic package inventory refresh interval
	  via augments (CFE-2771)
	- Changed FR policy to honor target_state properly (ENT-4874)
	- Copy .awk and .sed files from masterfiles to inputs (ENT-4839)
	- Fixed Python 3 incompatibility in yum package module
	- Fixed synchronization of important configuration files from active to
	  passive hub (ENT-4944)
	- Made keys of all types from feeder hubs trusted on a superhub (ENT-4917)
	- Speeded-up FR import process by merging INSERT INTO statements (ENT-4839)
	- Suppressed stderr output from lldpctl when using path defined by
	  def.lldpctl_json (CFE-3109)
	- Added SQL to update feeder update timestamp during import (ENT-4776)
	- Added ssh_home_t type to cftransport .ssh dir (ENT-4906)
	- fix use of _stdlib_path_exists_<command> in FR transport_user policy
	  bundle (ENT-4906)
	- partitioned __inventory table for federated reporting (ENT-4842)
	- psql_wrapper needed full path to psql binary (ENT-4912)
	- yum package_module gets updates available from online repos if local
	  cache fails (CFE-3094)

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
	- Add Debian 9 to the self upgrade package map (ENT-4255)
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
	- Change class identifying runagent initiated executions from cfruncommand to cf_runagent_initiated
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
	- Make stock policy update more resilient (CFE-2587)
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
	- Change: Verify transferred files during policy update
	- Change select_region INI_section to match end of section or end of file
	  (CFE-2519)
	- Add class to enable post transfer verification during policy updates
	- Add: prunetree bundle to stdlib
	  The prunetree bundle allows you to delete files and directories up to a
	  specified depth older than a specified number of days
	- Do not symlink agents to /usr/local/bin on CoreOS (ENT-3047)
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
	- Change: Session Cookies use HTTPOnly and secure attributes (ENT-2781)
	- Change: Verify transferred files during policy update
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
	- Change: re-enable hub process maintenance
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
	- Support for user specified overriding of framework defaults without modifying
	  policy supplied by the framework itself (see example_def.json)
	- Support for def.json class augmentation in update policy
	- Run vacuum operation on PostgreSQL every night as a part of maintenance.
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
	- Relocate service_catalogue from promises.cf to services/main.cf. It is
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
	  update policy into promises.cf, update.cf is the entry for the update policy
	- _not_repaired outcome from classes_generic and scoped_classes generic (Redmine: # 7022)
	- standard_services now restarts the service if it was not already running
	  when using service_policy => restart with chkconfig (Redmine #7258)
	- Fix process_result logic to match the purpose of body process_select
	  days_older_than (Redmine #3009)
