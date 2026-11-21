# Dashboard

The lab uses the built-in **Threat Hunting** dashboard of the Wazuh dashboard, set to the last 24 hours. All custom alerts share the rule group `mini_soc`, so they can be isolated with:

```
rule.groups:mini_soc
```

Honeypot alerts also carry the group `cowrie`, and file integrity alerts carry `fim`.

## Useful Queries

| Goal | Query |
|---|---|
| All custom detections | `rule.groups:mini_soc` |
| High severity custom detections | `rule.groups:mini_soc and rule.level >= 12` |
| Honeypot activity | `rule.groups:cowrie` |
| Honeypot credentials tried | `rule.id:(100502 or 100504)` |
| Attacker commands | `rule.id:100505` |
| File integrity events | `rule.id:100400` |

## Screenshot Procedure

1. Open **Discover**, index pattern `wazuh-alerts-*`, time range last 24 hours.
2. Enter the query for the detection.
3. Add the columns `rule.description`, `rule.level`, `rule.id`, and `data.srcip`.
4. Capture the table so the alert row, rule ID, and level are visible.
