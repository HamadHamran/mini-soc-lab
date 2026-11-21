# PB-05: SSH Honeypot Activity

| Field | Value |
|---|---|
| Rules | 100501 (connect), 100502 / 100503 (login failures, brute force), 100504 (login success), 100505 (command), 100506 (file download) |
| MITRE ATT&CK | T1046, T1110, T1078, T1059.004, T1105 |
| Default severity | Low for connections, High for commands, Critical for downloads |
| Owner | SOC Tier 1, threat intelligence |

Any interaction with the honeypot is suspicious by definition, because no legitimate user or service should connect to it.

## 1. Detection and Triage (target: 15 minutes)

1. Record: source IP, session ID (`data.session`), credentials tried, commands, URLs downloaded.
2. Rebuild the full session timeline: `data.session:<session_id>` sorted by time.
3. Determine the source:
   - Internal IP: an internal host is scanning the network, which indicates a possibly compromised host. **Escalate immediately.**
   - External IP (internet-facing honeypot only): collect as threat intelligence.
4. Check whether the same source IP touched any production host: `data.srcip:<source_ip> or data.win.eventdata.ipAddress:<source_ip>`.

## 2. Containment

1. Block the source IP at the perimeter and on all hosts.
2. If the source is internal, isolate that host and open an investigation under PB-01 or PB-02 as applicable.

## 3. Intelligence Extraction

1. Export credentials tried and add them to a deny-list for password policy checks.
2. Collect downloaded files from the honeypot download directory, hash them, and analyze them only in an isolated sandbox.
3. Record URLs, IPs, and hashes as indicators of compromise (IOCs).
4. Map observed commands to MITRE ATT&CK techniques.

## 4. Recovery

1. Rotate any real credential that appears in the attempted credential list.
2. Reset the honeypot to a clean state if it was modified.

## 5. Lessons Learned and Hardening

- Feed IOCs into the Wazuh CDB lists to alert on matching activity across all endpoints.
- Keep the honeypot isolated from production segments.
- An internet-facing honeypot must run on a dedicated, hardened cloud server with no other workloads.

## Evidence Checklist

- [ ] Session timeline export
- [ ] Credential list
- [ ] Commands and MITRE mapping
- [ ] IOCs (IPs, URLs, hashes)
- [ ] Blocking actions
