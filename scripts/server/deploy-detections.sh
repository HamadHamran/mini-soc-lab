#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

install -o wazuh -g wazuh -m 660 "$REPO_DIR"/wazuh/rules/*.xml /var/ossec/etc/rules/

for group in linux; do
  /var/ossec/bin/agent_groups -a -g "$group" -q >/dev/null 2>&1 || true
  install -o wazuh -g wazuh -m 660 "$REPO_DIR/wazuh/shared/$group/agent.conf" "/var/ossec/etc/shared/$group/agent.conf"
done

/var/ossec/bin/wazuh-analysisd -t
systemctl restart wazuh-manager
echo "Detections deployed. Manager restarted."
