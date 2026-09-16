# Endpoints

Two existing VirtualBox VMs, reused as monitored endpoints:

| VM | Role | Telemetry |
|----|------|-----------|
| `windows` (Win10) | Windows endpoint / Atomic Red Team target | Sysmon (sysmon-modular) + Wazuh agent |
| `kali-linux-2026.1` | Linux endpoint + attacker box | auditd + Wazuh agent |

## Before anything: snapshot

Atomic Red Team changes system state (registry keys, scheduled tasks, dropped files). A fresh
snapshot is taken per VM before testing so every run is reversible:

```
VBoxManage snapshot "<vm>" take "pre-atomic-lab" --description "clean state before ATT&CK tests"
```

## Networking

The manager lives on the host-only network at **192.168.56.10**. Each endpoint needs a NIC on
that same network so its agent can reach the manager (port 1514/1515). Added while the VM is
powered off:

```
VBoxManage modifyvm "<vm>" --nic2 hostonly --hostonlyadapter2 <vboxnet>
```

## Enrolment

1. Bring the manager up (`../wazuh` → `vagrant up`) and get the dashboard password.
2. Start the endpoint, run its setup script:
   - Windows (elevated PowerShell): `windows-setup.ps1`
   - Kali (sudo): `bash linux-setup.sh`
3. Confirm each agent shows **active** in the dashboard.

Sysmon/auditd log collection is pushed centrally from the manager via the `endpoints` group's
shared `agent.conf`, so the endpoints stay thin and config is version-controlled in one place.

## Networking lessons (learned the hard way)

- **Every endpoint mirrors the manager: NAT as the *primary* adapter (internet) + one host-only
  adapter (manager link). Nothing else.** A leftover extra adapter (an internal network) made
  Kali's NAT flaky and its routing unreliable.
- **After reordering adapters, NetworkManager may re-apply the old adapter's profile.** Kali's new
  NAT adapter came up with the old static `192.168.20.x` IP and *no default route*. Fix — force
  the profile onto DHCP:
  `nmcli connection modify "<profile>" ipv4.method auto ipv4.addresses "" ipv4.gateway "" && nmcli connection up "<profile>"`
- **VirtualBox NAT drops ICMP to the internet**, so a failing `ping 8.8.8.8` proves nothing.
  Test with a TCP request: `curl -sS -o /dev/null -w "%{http_code}" https://...`
- **No guest internet? A VirtualBox shared folder is a reliable file-transfer fallback**
  (needs Guest Additions): download on the host, then
  `VBoxManage sharedfolder add <vm> --name labshare --hostpath <dir> --transient` and
  `mount -t vboxsf labshare /mnt/labshare` inside the guest.
- Modern Kali ships no `dhclient`; NetworkManager (`nmcli`) owns DHCP.
