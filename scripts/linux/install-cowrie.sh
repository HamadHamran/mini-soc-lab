#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

COWRIE_VERSION=3.1.7
COWRIE_HOME=/home/cowrie/cowrie

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y python3-venv python3-dev libssl-dev libffi-dev build-essential

id cowrie >/dev/null 2>&1 || adduser --disabled-password --gecos "" cowrie

sudo -u cowrie -H bash -c "
  set -euo pipefail
  mkdir -p $COWRIE_HOME && cd $COWRIE_HOME
  python3 -m venv cowrie-env
  cowrie-env/bin/python -m pip install --upgrade pip
  cowrie-env/bin/python -m pip install cowrie==$COWRIE_VERSION
  mkdir -p var/log/cowrie var/lib/cowrie
"

echo "Cowrie $COWRIE_VERSION installed in $COWRIE_HOME."
echo "Start it as the cowrie user: cd $COWRIE_HOME && cowrie-env/bin/cowrie start"
echo "The honeypot listens on port 2222. Real SSH stays on port 22."
