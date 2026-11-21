#!/usr/bin/env bash
set -euo pipefail

MANAGER_IP="${1:?Usage: sudo bash install-agent.sh <wazuh_manager_ip>}"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0 $MANAGER_IP"
  exit 1
fi

apt-get update
apt-get install -y curl gnupg apt-transport-https rsyslog sshpass

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
apt-get update

WAZUH_MANAGER="$MANAGER_IP" WAZUH_AGENT_GROUP="linux" WAZUH_AGENT_NAME="linux-endpoint" apt-get install -y wazuh-agent

sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/wazuh.list
apt-get update

mkdir -p /srv/sensitive
printf 'admin,example\n' > /srv/sensitive/passwords.txt
chmod 640 /srv/sensitive/passwords.txt

systemctl daemon-reload
systemctl enable --now wazuh-agent
systemctl --no-pager status wazuh-agent | head -n 5
