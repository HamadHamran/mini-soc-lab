# Attack Simulations

All simulations run only inside the isolated host-only network, on the linux-endpoint. Copy `simulations/linux-tests.sh` to the endpoint and run it with the commands below.

## Test Matrix

| ID | Technique | Command | Expected rules | Result |
|---|---|---|---|---|
| T-01 | SSH brute force (T1110.001) | `bash linux-tests.sh ssh-bruteforce` | 5760, **100100** | Alert fired |
| T-02 | SSH user enumeration (T1110.003) | Repeated logins with non-existent users | 5710, **100101** | Not yet tested |
| T-03 | New Linux user (T1136.001) | `bash linux-tests.sh new-admin` | **100311** | Alert fired |
| T-04 | User added to sudo (T1098) | `bash linux-tests.sh new-admin` | **100310** | Not yet tested |
| T-05 | Sensitive file tampering (T1565.001) | `bash linux-tests.sh fim` | **100400** | Alert fired |
| T-06 | Sudoers persistence (T1548.003) | `bash linux-tests.sh sudoers` | **100401** | Not yet tested |
| T-07 | Honeypot brute force (T1110) | `bash linux-tests.sh honeypot-bruteforce` | **100501**, **100502**, **100503** | 100501, 100502 fired |
| T-08 | Honeypot interactive session (T1059.004) | `bash linux-tests.sh honeypot-session` | **100501**, **100504**, **100505** | Alerts fired |
| T-09 | Honeypot file download (T1105) | `wget` inside the honeypot session | **100506** | Not yet tested |

Run `bash linux-tests.sh cleanup` after T-03, T-04, and T-06.

## Honeypot Session (T-08)

```bash
bash linux-tests.sh honeypot-session
```

Use any password. Then run inside the session:

```bash
uname -a
whoami
cat /etc/passwd
exit
```

## Verifying Each Test

In the Wazuh dashboard open **Threat Hunting** > **Events** (or **Discover**) with index `wazuh-alerts-*`, set the time range to the last hour, and query by rule ID, for example:

```
rule.id:100100
```

Add the columns `rule.description`, `rule.level`, `rule.id`, and `data.srcip` before taking a screenshot.

## If a Rule Does Not Fire

1. Confirm the raw event is on the endpoint, for example `sudo grep useradd /var/log/auth.log`.
2. Paste the raw log line into `sudo /var/ossec/bin/wazuh-logtest` on the server and read which rule matched in Phase 3.
3. If a built-in rule wins, adjust the custom rule's `if_sid` or field regex, redeploy with `deploy-detections.sh`, and re-run the test.
4. Check the rules load cleanly: `sudo /var/ossec/bin/wazuh-analysisd -t`.
