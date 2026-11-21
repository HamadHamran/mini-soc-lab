# PB-01: Brute Force Authentication Attack

| Field | Value |
|---|---|
| Rules | 100100, 100101 (SSH), 5763, 5712 |
| MITRE ATT&CK | T1110.001 Password Guessing, T1110.003 Password Spraying |
| Default severity | High (level 10) - Critical if followed by a successful logon |
| Owner | SOC Tier 1, escalate to Tier 2 on compromise |

## 1. Detection and Triage (target: 15 minutes)

1. Open the alert and record: source IP, target host, targeted accounts, attempt count, time window.
2. Check whether any attempt succeeded from the same source:
   - Linux: `rule.groups:authentication_success and data.srcip:<source_ip>`
3. Classify the source: internal lab host, known admin workstation, or unknown.
4. Decide:
   - No success and unknown source: **True positive, no compromise** - continue to containment.
   - Success after failures: **Escalate as account compromise** to Tier 2 immediately.
   - Known admin with a forgotten password: **Benign true positive** - document and close.

## 2. Containment

1. Block the source IP on the target:
   - `sudo iptables -I INPUT -s <source_ip> -j DROP`
2. If an account was compromised: disable it, terminate its sessions, and reset its password.
3. Optional automation: enable the Wazuh `firewall-drop` active response for rules 100100 and 100101.

## 3. Eradication

1. Review successful sessions from the source for persistence: new users, scheduled tasks, cron jobs, SSH `authorized_keys`, services.
2. Remove any artifact found and document it.

## 4. Recovery

1. Re-enable the account with a new strong password and MFA where available.
2. Monitor the account and host for 24 hours with a saved search on the source IP and account name.

## 5. Lessons Learned and Hardening

- Disable SSH password authentication and use keys only.
- Enforce an account lockout policy (e.g. 5 attempts, 15 minutes).
- Restrict SSH to management networks.
- Tune thresholds if legitimate activity triggers the rule.

## Evidence Checklist

- [ ] Alert JSON exported
- [ ] Source IP, accounts targeted, attempt count
- [ ] Success / failure determination
- [ ] Containment actions with timestamps
- [ ] Ticket closed with classification
