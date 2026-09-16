#!/usr/bin/env bash
# Turns the Kali/Debian VM into a monitored endpoint.
# Resilient to flaky distro mirrors: installs the Wazuh agent from packages.wazuh.com
# only, forces apt to IPv4, and treats auditd (from distro mirrors) as best-effort.
# Run INSIDE the Kali VM with sudo:  sudo bash linux-setup.sh 192.168.56.10
set -euo pipefail

MANAGER="${1:-192.168.56.10}"
AGENT_GROUP="${2:-endpoints}"

echo "[*] Forcing apt to IPv4 (VirtualBox NAT IPv6 is unreliable)..."
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

echo "[*] Adding the Wazuh repository..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
  > /etc/apt/sources.list.d/wazuh.list

echo "[*] Refreshing ONLY the Wazuh repo (skips distro mirrors that may be unreachable)..."
apt-get update \
  -o Dir::Etc::sourcelist="sources.list.d/wazuh.list" \
  -o Dir::Etc::sourceparts="/dev/null" \
  -o APT::Get::List-Cleanup="0"

echo "[*] Installing the Wazuh agent (manager ${MANAGER})..."
WAZUH_MANAGER="${MANAGER}" WAZUH_AGENT_GROUP="${AGENT_GROUP}" apt-get install -y wazuh-agent

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

echo "[*] (best-effort) Installing auditd for richer command-line telemetry..."
if apt-get install -y auditd audispd-plugins 2>/dev/null; then
  cat > /etc/audit/rules.d/lab.rules <<'RULES'
-a exit,always -F arch=b64 -S execve -k exec
-a exit,always -F arch=b32 -S execve -k exec
RULES
  augenrules --load 2>/dev/null || service auditd restart 2>/dev/null || true
  echo "[+] auditd installed and rules loaded."
else
  echo "[!] auditd skipped (distro mirror unreachable) — the agent still works; add it later."
fi

echo "[+] Done. Confirm the agent shows 'active' in the Wazuh dashboard."
