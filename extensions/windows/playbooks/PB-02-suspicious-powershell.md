# PB-02: Suspicious PowerShell Execution

| Field | Value |
|---|---|
| Rules | 100200 (encoded command), 100201 (download cradle), 100202 (bypass/hidden), 100203 (script block) |
| MITRE ATT&CK | T1059.001 PowerShell, T1027 Obfuscation, T1105 Ingress Tool Transfer, T1564.003 Hidden Window |
| Default severity | High (level 12), Medium for 100202 alone |
| Owner | SOC Tier 1 triage, Tier 2 investigation |

## 1. Detection and Triage (target: 15 minutes)

1. Record from the alert: host, user, full command line, parent process (`data.win.eventdata.parentImage`), process GUID, time.
2. Decode any Base64 payload safely on the analyst workstation:
   ```powershell
   [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String("<payload>"))
   ```
3. Review the related script block events: `rule.groups:powershell and agent.name:<host>` around the same time.
4. Assess the parent process. Office applications, browsers, `wscript.exe`, or `mshta.exe` as parent strongly suggest malicious execution.
5. Check for network activity from the process: Sysmon Event ID 3 with the same `processGuid`.
6. Decide:
   - Known admin script or software deployment tool: **Benign** - document and consider a tuned exception.
   - Unknown script, external URL, or obfuscation: **Escalate** and contain.

## 2. Containment

1. Isolate the host from the network (disconnect the adapter or use EDR isolation).
2. Kill the process: `Stop-Process -Id <pid> -Force`.
3. Block any URL or IP contacted at the firewall or proxy.
4. Disable the user account if the execution was not performed by the user.

## 3. Eradication

1. Collect and hash any downloaded files (Sysmon Event ID 11 file create).
2. Search for persistence: `Get-ScheduledTask`, Run keys, services, WMI subscriptions.
3. Remove malicious artifacts and run a full antivirus scan.

## 4. Recovery

1. Reconnect the host only after a clean scan and validation.
2. Reset credentials for the affected user.
3. Monitor the host for 48 hours.

## 5. Lessons Learned and Hardening

- Enforce PowerShell Constrained Language Mode for standard users.
- Keep Script Block Logging and Module Logging enabled.
- Apply application control (WDAC / AppLocker) to restrict script execution.
- Maintain an allow-list of legitimate admin scripts to reduce false positives.

## Evidence Checklist

- [ ] Full command line and decoded payload
- [ ] Parent / child process tree
- [ ] Network connections and downloaded file hashes
- [ ] Containment actions with timestamps
- [ ] Classification and root cause
