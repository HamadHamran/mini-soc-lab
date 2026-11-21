#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

cd /root
curl -sSO https://packages.wazuh.com/4.14/wazuh-install.sh
bash ./wazuh-install.sh -a

sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/wazuh.list 2>/dev/null || true

echo
echo "Dashboard: https://$(hostname -I | awk '{print $1}')"
tar -O -xf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt | grep -A1 "'admin'"
