# Windows Extension (not validated)

Optional detections for a Windows endpoint with Sysmon. These files were written for the lab but never tested against a live Windows VM, so treat them as a starting point.

| Path | Purpose |
|---|---|
| rules/soc_windows_rules.xml | Rules 100110, 100300, 100301 |
| rules/soc_powershell_rules.xml | Rules 100200-100203 |
| shared/agent.conf | Windows agent group configuration |
| scripts/Install-Endpoint.ps1 | Agent, Sysmon, and audit policy setup |
| scripts/windows-tests.ps1 | Attack simulations |
| playbooks/PB-02-suspicious-powershell.md | Response playbook |

To enable: copy the rule files to `/var/ossec/etc/rules/` on the server, create the `windows` agent group, place `shared/agent.conf` in `/var/ossec/etc/shared/windows/`, run `sudo /var/ossec/bin/wazuh-analysisd -t`, then restart the manager. Validate each rule before relying on it.

The download-cradle test expects an HTTP server on the attacker side that serves `hello.ps1` on port 8000 (for example `python3 -m http.server 8000`).
