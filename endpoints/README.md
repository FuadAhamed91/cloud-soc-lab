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
