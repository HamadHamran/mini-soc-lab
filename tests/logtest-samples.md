# Rule Unit Tests with wazuh-logtest

Before running live attacks, validate each Linux-side rule offline on the Wazuh server:

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Paste each sample line and confirm the expected rule ID in **Phase 3** of the output. Frequency-based rules (brute force) need the same line pasted repeatedly within the timeframe.

| Rule | Sample log line | Expected |
|---|---|---|
| 100100 | `Oct 23 10:00:01 linux-endpoint sshd[2101]: Failed password for root from 192.168.56.40 port 51234 ssh2` (paste 6+ times) | 5760 for the first lines, then 100100 |
| 100101 | `Oct 23 10:00:01 linux-endpoint sshd[2101]: Failed password for invalid user oracle from 192.168.56.40 port 51234 ssh2` (paste 6+ times) | 5710, then 100101 |
| 100310 | `Oct 23 10:05:00 linux-endpoint usermod[3301]: add 'soc_test' to group 'sudo'` | 100310 |
| 100311 | `Oct 23 10:04:00 linux-endpoint useradd[3300]: new user: name=soc_test, UID=1001, GID=1001, home=/home/soc_test, shell=/bin/bash, from=/dev/pts/0` | 100311 |
| 100501 | `{"eventid":"cowrie.session.connect","src_ip":"192.168.56.40","src_port":40112,"dst_ip":"192.168.56.30","dst_port":2222,"session":"a1b2c3d4","protocol":"ssh","message":"New connection","sensor":"srv-db01","timestamp":"2026-10-23T10:10:00.000000Z"}` | 100501 |
| 100502 | `{"eventid":"cowrie.login.failed","username":"root","password":"root","src_ip":"192.168.56.40","session":"a1b2c3d4","message":"login attempt [root/root] failed","sensor":"srv-db01","timestamp":"2026-10-23T10:10:01.000000Z"}` | 100502 (paste 6+ times for 100503) |
| 100504 | `{"eventid":"cowrie.login.success","username":"root","password":"123456","src_ip":"192.168.56.40","session":"a1b2c3d4","message":"login attempt [root/123456] succeeded","sensor":"srv-db01","timestamp":"2026-10-23T10:10:05.000000Z"}` | 100504 |
| 100505 | `{"eventid":"cowrie.command.input","input":"cat /etc/passwd","src_ip":"192.168.56.40","session":"a1b2c3d4","message":"CMD: cat /etc/passwd","sensor":"srv-db01","timestamp":"2026-10-23T10:10:09.000000Z"}` | 100505 |
| 100506 | `{"eventid":"cowrie.session.file_download","url":"http://192.168.56.40:8000/test.sh","outfile":"var/lib/cowrie/downloads/abc","shasum":"abc","src_ip":"192.168.56.40","session":"a1b2c3d4","message":"Downloaded URL","sensor":"srv-db01","timestamp":"2026-10-23T10:10:12.000000Z"}` | 100506 |

FIM rules (100400-100401) are validated with live tests in [docs/attack-simulations.md](../docs/attack-simulations.md), because their events come from the syscheck module rather than plain log lines.
