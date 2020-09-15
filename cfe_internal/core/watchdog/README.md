The watchdog implements a process external to CFEngine which is responsible for identifying symptoms of pathology that result in CFEngine degrading into an inoperable non-recoverable state.

**Note**: This feature is not enabled by default.

If the class `cfe_internal_core_watchdog_enabled` is defined, the feature is
enabled and the watchdog will be active. If the class
`cfe_internal_core_watchdog_disabled` is defined, the feature is disabled and
the watchdog will not be active.

**Example enable/disable via augments:**

```json
{
    "classes": {
        "cfe_internal_core_watchdog_enabled": [ "aix::" ],
        "cfe_internal_core_watchdog_disabled": [ "!cfe_internal_core_watchdog_enabled::" ]
        }
}
```

## cron.d Watchdog

The generic cron.d watchdog looks for a running `cf-execd` processes and starts one if not found.

**History:**

- start cf-execd if not running (3.8.0)
- restart if processes not resulting in updated logs (3.12.0)

## AIX Watchdog

The AIX watchdog is implemented as a shell script rendered via mustache template.

When **enabled** the policy ensures that the watchdog script is available and executed via root's crontab.

When **disabled** the policy ensures that the cron job as identified with a trailing string `# CFEngine watchdog` is not active.

The watchdog logs to `/var/cfengine/watchdog.log`. Note, this log file is **not** automatically rotated or purged.

The watchdog records observation artifacts to `/var/cfengine/watchdog-archives/.`.

If there is less than 500MB of free space, the watchdog will clean up old archives, preserving the oldest and most recent collection.

**History:**

- Initially introduced with check that cf-execd is running (3.13.0)
- Introduced check for multiple instances of cf-execd (3.15.0)
- Introduced check for logged triggers of agent_expireafter (3.15.0)
- Introduced check for long running cf-agent processes (3.15.0)
- Introduced check for too many concurrent cf-agent processes (3.15.0)
- Introduced check for integrity issues identified by cf-check (3.15.0)

## Windows Watchdog

The Windows watchdog is implemented as a powershell script rendered via mustache template.

When **enabled** the policy ensures that the watchdog script is scheduled for execution via the windows task scheduler.

When **disabled** the policy ensures that the there it no scheduled task named `CFEngine-watchdog`.

The watchdog logs to `$(sys.workdir)/watchdog.log` (`C:\Program Files\Cfengine\watchdog.log`). Note, this log file is **not** automatically rotated or purged.

**History:**

- Initially introduced with check to terminate any cf-agent processes that have been running for longer than 5 minutes. (3.17.0, 3.15.3)

### Symptoms of pathology

The following conditions are included in the watchdog checks:

- `/var/cfengine/bin/cf-execd` is running
- `/var/cfengine/bin/cf-execd` is not running more than once
- `cf-execd` has not timed out long-running (as defined by `agent_expireafter`), non-responsive `cf-agent` processes based on inspection of `$(sys.workdir)/outputs/.*`
- `/var/cfengine/bin/cf-agent` processes currently running do not exceed 300 seconds of execution time
- `/var/cfengine/bin/cf-agent` processes currently running do not exceed concurrency of 3
- `cf-check` does not observe any critical integrity issues in embedded databases

If the pathology threshold (default 0) is breached the watchdog collects observations about the environment into an archive which is intended for submission to CFEngine Support. After the archive has been prepared the watchdog terminates all CFEngine processes, purges outputs (`$(sys.workdir)/outputs/*`), local databases (`$(sys.statedir)/*.lmdb*`), and then the watchdog will try to re-start the CFEngine processes. The agent will try up to 10 times, with a delay of 10 seconds between each attempt to ensure that `cf-execd`, `cf-serverd`, and `cf-monitord` are all running.

