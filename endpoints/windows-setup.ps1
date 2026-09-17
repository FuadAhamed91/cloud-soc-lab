<#
    Windows endpoint setup: Sysmon (sysmon-modular config) + Wazuh agent.
    Run INSIDE the Windows VM in an ELEVATED PowerShell.

    Installs from the VirtualBox shared folder \\VBOXSVR\labshare, where the host has staged:
      wazuh-agent-4.9.2-1.msi, Sysmon.zip, sysmonconfig.xml
    (Fallback if the share is missing / no Guest Additions: download the same files from
     packages.wazuh.com, download.sysinternals.com, and the sysmon-modular repo.)
#>
$ErrorActionPreference = "Stop"
$Manager = "192.168.56.10"
$src  = "\\VBOXSVR\labshare"
$work = "$env:TEMP\wazuh-lab"
New-Item -ItemType Directory -Force $work | Out-Null

if (-not (Test-Path "$src\wazuh-agent-4.9.2-1.msi")) {
    Write-Error "Shared folder not found at $src (Guest Additions may be missing). Use the download fallback."
}

Write-Host "[*] Installing Sysmon with the sysmon-modular config..."
Expand-Archive "$src\Sysmon.zip" -DestinationPath "$work\Sysmon" -Force
Copy-Item "$src\sysmonconfig.xml" "$work\sysmonconfig.xml" -Force
& "$work\Sysmon\Sysmon64.exe" -accepteula -i "$work\sysmonconfig.xml"

Write-Host "[*] Installing the Wazuh agent (manager $Manager, group endpoints)..."
Copy-Item "$src\wazuh-agent-4.9.2-1.msi" "$work\wazuh-agent.msi" -Force
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$work\wazuh-agent.msi`" /q WAZUH_MANAGER=`"$Manager`" WAZUH_AGENT_GROUP=`"endpoints`""

Write-Host "[*] Starting the Wazuh service..."
Start-Service -Name WazuhSvc -ErrorAction SilentlyContinue
Start-Sleep 2
Get-Service WazuhSvc | Format-Table -AutoSize
Write-Host "[+] Done. The 'windows' agent should appear active in the Wazuh dashboard shortly."
