The watchdog implements a process external to CFEngine which is responsible for identifying symptoms of pathology that result in CFEngine degrading into an inoperable non-recoverable state.

## cron.d Watchdog

The generic cron.d watchdog looks for a running `cf-execd` processes and starts one if not found.

## AIX Watchdog

The AIX watchdog is implemented as a shell script rendered via mustache template.

When **enabled** the policy ensures that the watchdog script is available and executed via root's crontab.

When **disabled** the policy ensures that the cron job as identified with a trailing string `# CFEngine watchdog` is not active.

The watchdog logs to `/var/cfengine/watchdog.log`. Note, this log file is **not** automatically rotated or purged.

The watchdog records observation artifacts to `/var/cfengine/watchdog-archives/.`.

If there is less than 500MB of free space, the watchdog will clean up old archives, preserving the oldest and most recent collection.

### Symptoms of pathology

The following conditions are included in the watchdog checks:

- `/var/cfengine/bin/cf-execd` is running
- `/var/cfengine/bin/cf-execd` is not running more than once
- `cf-execd` has not timed out long-running (as defined by `agent_expireafter`), non-responsive `cf-agent` processes based on inspection of `$(sys.workdir)/outputs/.*`
- `/var/cfengine/bin/cf-agent` processes currently running do not exceed 300 seconds of execution time
- `/var/cfengine/bin/cf-agent` processes currently running do not exceed concurrency of 3
- `cf-check` does not observe any critical integrity issues in embedded databases

If the pathology threshold (default 0) is breached the watchdog collects observations about the environment into an archive which is intended for submission to CFEngine Support. After the archive has been prepared the watchdog terminates all CFEngine processes, purges outputs (`$(sys.workdir)/outputs/*`), local databases (`$(sys.statedir)/*.lmdb*`), and then the watchdog will try to re-start the CFEngine processes. The agent will try up to 10 times, with a delay of 10 seconds between each attempt to ensure that `cf-execd`, `cf-serverd`, and `cf-monitord` are all running.
