# PB-04: Sensitive File Integrity Violation

| Field | Value |
|---|---|
| Rules | 100400 (sensitive data), 100401 (sudoers), 550, 553, 554 |
| MITRE ATT&CK | T1565.001 Stored Data Manipulation, T1548.003 Sudo and Sudo Caching |
| Default severity | High (level 12) |
| Owner | SOC Tier 1, escalate to Tier 2 and data owner |

## 1. Detection and Triage (target: 15 minutes)

1. Record: host, file path, change type (modified, added, deleted), old and new hashes, time.
2. Review the content diff in the alert (`syscheck.diff`) produced by `report_changes`.
3. Identify the actor:
   - Linux: correlate with `sudo` and SSH logon events around the change time.
4. Check for an approved change window.
5. Decide:
   - Approved maintenance: **Benign** - document.
   - Unknown actor or unexpected content: **Escalate as data tampering**.

## 2. Containment

1. Restrict write access to the directory.
2. Disable the actor account if unauthorized.
3. Preserve a copy of the modified file and its hash before any restore.

## 3. Eradication

1. Identify how the actor gained write access.
2. Remove unauthorized access paths (permissions, accounts, sudo rules).

## 4. Recovery

1. Restore the file from the last known-good backup.
2. Confirm the restored hash matches the baseline.
3. Notify the data owner.

## 5. Lessons Learned and Hardening

- Apply least-privilege file permissions on sensitive directories.
- Enable `whodata` FIM on Linux (auditd) to capture the exact user and process.
- Keep tested backups of sensitive data.

## Evidence Checklist

- [ ] File path, hashes before and after, diff
- [ ] Actor and process
- [ ] Approval status
- [ ] Restore confirmation
