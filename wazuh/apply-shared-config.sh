#!/usr/bin/env bash
# Run ON the Wazuh manager to create the "endpoints" agent group and install the
# shared agent.conf. Idempotent — safe to re-run.
#
#   vagrant ssh -c "sudo bash /vagrant/apply-shared-config.sh"
#
# Vagrant mounts the repo's wazuh/ dir at /vagrant inside the manager VM.
set -euo pipefail

GROUP="endpoints"
SRC="/vagrant/shared/endpoints-agent.conf"

if ! /var/ossec/bin/agent_groups -l | grep -qw "$GROUP"; then
  /var/ossec/bin/agent_groups -a -g "$GROUP" -q
  echo "[*] Created agent group '$GROUP'."
fi

install -m 660 -o wazuh -g wazuh "$SRC" "/var/ossec/etc/shared/$GROUP/agent.conf"
echo "[+] Installed shared agent.conf for group '$GROUP'."
echo "[*] Enrolled endpoints joined to '$GROUP' will collect Sysmon (Windows) / auditd (Linux)."
