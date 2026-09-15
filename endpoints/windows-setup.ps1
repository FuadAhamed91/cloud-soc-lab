<#
    Turns the Windows 10 VM into a monitored endpoint:
      1. Sysmon (Sysinternals) with the sysmon-modular config
      2. Wazuh agent enrolled to the manager

    Run INSIDE the Windows VM, in an elevated PowerShell.
    Sysmon event collection is configured centrally from the manager (shared agent.conf),
    so this script only installs the pieces.
#>
param(
    [string]$Manager = "192.168.56.10",
    [string]$AgentGroup = "endpoints",
    # Agent version should be <= manager version. Check https://packages.wazuh.com/4.x/windows/
    [string]$AgentVersion = "4.9.2"
)

$ErrorActionPreference = "Stop"
$work = "$env:TEMP\wazuh-lab"
New-Item -ItemType Directory -Force -Path $work | Out-Null

Write-Host "[*] Installing Sysmon with sysmon-modular config..."
Invoke-WebRequest "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "$work\Sysmon.zip"
Expand-Archive "$work\Sysmon.zip" -DestinationPath "$work\Sysmon" -Force
Invoke-WebRequest "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml" -OutFile "$work\sysmonconfig.xml"
& "$work\Sysmon\Sysmon64.exe" -accepteula -i "$work\sysmonconfig.xml"

Write-Host "[*] Installing Wazuh agent (manager $Manager)..."
$msi = "$work\wazuh-agent-$AgentVersion-1.msi"
Invoke-WebRequest "https://packages.wazuh.com/4.x/windows/wazuh-agent-$AgentVersion-1.msi" -OutFile $msi
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msi`" /q WAZUH_MANAGER=`"$Manager`" WAZUH_AGENT_GROUP=`"$AgentGroup`""
Start-Service -Name WazuhSvc

Write-Host "[+] Done. Confirm the agent appears 'active' in the Wazuh dashboard."
