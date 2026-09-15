#!/usr/bin/env bash
# Provisions Wazuh (all-in-one) on the manager VM and tunes it for a low-RAM host.
set -euo pipefail

WAZUH_VERSION="4.9"

if systemctl is-active --quiet wazuh-manager 2>/dev/null; then
  echo "[*] Wazuh manager already running; skipping install."
  exit 0
fi

echo "[*] Installing prerequisites..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl tar

cd /root
echo "[*] Downloading Wazuh install assistant ${WAZUH_VERSION}..."
curl -sO "https://packages.wazuh.com/${WAZUH_VERSION}/wazuh-install.sh"

echo "[*] Running all-in-one install (several minutes; downloads ~1-2 GB)..."
bash wazuh-install.sh -a -i -o

echo "[*] Tuning indexer JVM heap to 1g for the low-RAM host..."
sed -i 's/^-Xms.*/-Xms1g/; s/^-Xmx.*/-Xmx1g/' /etc/wazuh-indexer/jvm.options
systemctl restart wazuh-indexer

echo "[*] Extracting dashboard credentials..."
tar -O -xf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt \
  > /root/wazuh-passwords.txt 2>/dev/null || true

echo
echo "[+] Wazuh install complete."
echo "[+] Credentials: /root/wazuh-passwords.txt  (dashboard user: admin)"
echo "[+] Dashboard:  https://192.168.56.10  (accept the self-signed cert)"
