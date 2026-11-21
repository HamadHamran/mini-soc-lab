#!/usr/bin/env bash
set -euo pipefail

TARGET="${TARGET:-127.0.0.1}"
USER_NAME="${USER_NAME:-soc}"

case "${1:-}" in
  ssh-bruteforce)
    for i in 1 2 3 4 5 6; do
      sshpass -p wrongpass ssh -o StrictHostKeyChecking=no "$USER_NAME@$TARGET" true || true
    done
    ;;
  honeypot-bruteforce)
    for i in 1 2 3 4 5 6; do
      sshpass -p wrongpass ssh -p 2222 -o StrictHostKeyChecking=no root@"$TARGET" true || true
    done
    ;;
  honeypot-session)
    ssh -p 2222 -o StrictHostKeyChecking=no root@"$TARGET"
    ;;
  new-admin)
    sudo useradd soc_test
    sudo usermod -aG sudo soc_test
    ;;
  fim)
    echo "mallory,99999" | sudo tee -a /srv/sensitive/passwords.txt >/dev/null
    ;;
  sudoers)
    echo "soc_test ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99-soc-test >/dev/null
    sudo chmod 440 /etc/sudoers.d/99-soc-test
    ;;
  cleanup)
    sudo rm -f /etc/sudoers.d/99-soc-test
    id soc_test >/dev/null 2>&1 && sudo userdel -r soc_test || true
    ;;
  *)
    echo "Usage: $0 {ssh-bruteforce|honeypot-bruteforce|honeypot-session|new-admin|fim|sudoers|cleanup}"
    exit 1
    ;;
esac
