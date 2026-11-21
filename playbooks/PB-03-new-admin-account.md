# PB-03: New Account or Privileged Group Membership

| Field | Value |
|---|---|
| Rules | 100310, 100311 (Linux), 100401 (sudoers change) |
| MITRE ATT&CK | T1136.001 Create Local Account, T1098 Account Manipulation, T1548.003 Sudo and Sudo Caching |
| Default severity | High (level 12) for privilege grants, Medium (level 10) for account creation |
| Owner | SOC Tier 1, escalate to Tier 2 if unauthorized |

## 1. Detection and Triage (target: 15 minutes)

1. Record: host, new or modified account, actor account (sudo user), time.
2. Check for an approved change request covering this account.
3. Review what the actor did before the change:
   - `rule.groups:sudo and agent.name:<host>`.
4. Decide:
   - Approved change: **Benign** - link the ticket and close.
   - No approval, or actor account itself is suspicious: **Escalate as possible persistence**.

## 2. Containment

1. Disable the new account:
   - `sudo usermod -L -e 1 <account>`
2. Remove the privileged membership:
   - `sudo gpasswd -d <account> sudo` and remove any file in `/etc/sudoers.d/` that grants it rights.
3. Reset the password of the actor account if it was used without authorization.

## 3. Eradication

1. Review all actions performed by the new account.
2. Check other hosts for the same account name.
3. Delete the account after evidence is preserved.

## 4. Recovery

1. Audit all members of privileged groups on affected hosts.
2. Monitor for re-creation of the account for 7 days.

## 5. Lessons Learned and Hardening

- Require change tickets for privileged access.
- Use just-in-time admin access instead of permanent membership.
- Review privileged group membership weekly.

## Evidence Checklist

- [ ] Account name, actor, host, time
- [ ] Change approval status
- [ ] Actions performed by the account
- [ ] Containment and removal steps
- [ ] Privileged group audit result
