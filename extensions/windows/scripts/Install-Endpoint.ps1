param(
    [Parameter(Mandatory = $true)]
    [string]$ManagerIp,
    [string]$AgentVersion = "4.14.9-1"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$work = "C:\SOC-Setup"
New-Item -ItemType Directory -Path $work -Force | Out-Null

$msi = Join-Path $work "wazuh-agent.msi"
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-$AgentVersion.msi" -OutFile $msi -UseBasicParsing
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msi`" /q WAZUH_MANAGER=$ManagerIp WAZUH_AGENT_GROUP=windows WAZUH_AGENT_NAME=windows-endpoint"

Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile (Join-Path $work "Sysmon.zip") -UseBasicParsing
Expand-Archive -Path (Join-Path $work "Sysmon.zip") -DestinationPath (Join-Path $work "Sysmon") -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile (Join-Path $work "sysmonconfig.xml") -UseBasicParsing
& (Join-Path $work "Sysmon\Sysmon64.exe") -accepteula -i (Join-Path $work "sysmonconfig.xml")

$sbl = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $sbl -Force | Out-Null
New-ItemProperty -Path $sbl -Name "EnableScriptBlockLogging" -Value 1 -PropertyType DWord -Force | Out-Null

auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable | Out-Null
auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable | Out-Null
auditpol /set /subcategory:"Logon" /success:enable /failure:enable | Out-Null
auditpol /set /subcategory:"Process Creation" /success:enable | Out-Null

Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True -Profile Any

New-Item -ItemType Directory -Path "C:\Sensitive" -Force | Out-Null
Set-Content -Path "C:\Sensitive\payroll.csv" -Value "employee,salary`r`nalice,12000`r`nbob,11000"

Start-Service -Name WazuhSvc
Get-Service -Name WazuhSvc, Sysmon64 | Format-Table Name, Status
