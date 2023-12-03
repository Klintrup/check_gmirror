# monitor gmirror from NRPE / cron for FreeBSD

This is a Nagios/NRPE check script designed to monitor the status of gmirror volumes on a system. If any volumes are found to be in a failed state, the script will output the names of these volumes.

## Syntax

`$path/check_gmirror.sh [email] [email]`

If no arguments are specified, the script will assume its run for NRPE.

If one or more email addresses are specified, the script will send an email in case an array reports an error.

## Output

`gm3: DEGRADED / gm0: rebuilding / gm1: ok / gm2: ok`

Failed/rebuilding volumes will always be first in the output string, to help diagnose the problem when recieving the output via pager/sms.

### Output Examples

| output | description |
| -- | -- |
| ok | The device is reported as ok by gmirror |
| DEGRADED | The volume is degraded, it's still working but without the safety of RAID, and in some cases with severe performance loss. |
| rebuilding | The RAID is rebuilding, will return to OK when done. Expect performance degradation while volume is rebuilding. |
| starting | The geom device is currently starting, you shouldn't see this and will return an unknown code to nagios |
| unknown state | Volume is in an unknown state. Please report this to me (github at klintrup.dk) so I can update the script. Include the following output. `gmirror status`, `gmirror list` |

## Compability

The script should work on any FreeBSD platform until gmirror changes input/output syntax, I have tested the script on the following platforms

FreeBSD 6.2
FreeBSD 6.3
FreeBSD 7.0(amd64)
FreeBSD 8.0(amd64)
