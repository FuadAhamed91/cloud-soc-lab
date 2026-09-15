#!/usr/bin/env bash
# Turns the Kali/Debian VM into a monitored endpoint:
#   1. auditd (execve + key syscalls) for command-line telemetry
#   2. Wazuh agent enrolled to the manager
# Run INSIDE the Kali VM with sudo.
set -euo pipefail

MANAGER="${1:-192.168.56.10}"
AGENT_GROUP="${2:-endpoints}"

echo "[*] Installing auditd..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y auditd audispd-plugins gpg curl

echo "[*] Adding audit rules (process execution)..."
cat > /etc/audit/rules.d/lab.rules <<'RULES'
-a exit,always -F arch=b64 -S execve -k exec
-a exit,always -F arch=b32 -S execve -k exec
RULES
augenrules --load || service auditd restart

echo "[*] Installing Wazuh agent (manager ${MANAGER})..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
  > /etc/apt/sources.list.d/wazuh.list
apt-get update -y
WAZUH_MANAGER="${MANAGER}" WAZUH_AGENT_GROUP="${AGENT_GROUP}" apt-get install -y wazuh-agent

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

echo "[+] Done. Confirm the agent shows 'active' in the Wazuh dashboard."
