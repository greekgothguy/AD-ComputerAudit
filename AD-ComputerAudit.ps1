# Define OS
$windowsVersions = @(
    "Windows 10",
    "Windows 11",
    "Windows Server 2016",
    "Windows Server 2019",
    "Windows Server 2022",
    "Windows Server 2022"
)

#MENU
Clear-Host
Write-Host "===== Inactive & Active Computer Checker =====" -ForegroundColor Cyan
Write-Host "`nSelect the Windows version to check:`n"

for ($i = 0; $i -lt $windowsVersions.Count; $i++) {
    Write-Host "[$($i + 1)] $($windowsVersions[$i])"
}

#Selection
do {
    $selection = Read-Host "`nEnter the number of your selection"
    $valid = ($selection -as [int]) -and ($selection -ge 1 -and $selection -le $windowsVersions.Count)
    if (-not $valid) {
        Write-Host "Invalid input. Please enter a number between 1 and $($windowsVersions.Count)." -ForegroundColor Red
    }
} until ($valid)

$selectedVersion = $windowsVersions[$selection - 1]
Write-Host "`n✅ You selected: $selectedVersion`n" -ForegroundColor Green

#Inactivity time-window
$defaultDays = 90
$daysInput = Read-Host "Enter number of days to check for inactivity (default = $defaultDays)"
$inactiveDays = if ([string]::IsNullOrWhiteSpace($daysInput)) { $defaultDays } else { [int]$daysInput }
$thresholdDate = (Get-Date).AddDays(-$inactiveDays)

Write-Host "`n🔍 Checking for enabled '$selectedVersion' computers against a $inactiveDays-day threshold (since $($thresholdDate.ToShortDateString()))..."

#Query and filter fpr inactive and active computers
$computers = Get-ADComputer -Filter 'Enabled -eq $true' -Properties Name, OperatingSystem, LastLogonDate |
Where-Object { $_.OperatingSystem -like "*$selectedVersion*" }

$inactiveComputers = $computers | Where-Object {
    $_.LastLogonDate -lt $thresholdDate -and $_.LastLogonDate -ne $null
} | Select-Object Name, OperatingSystem, LastLogonDate | Sort-Object LastLogonDate

$activeComputers = $computers | Where-Object {
    $_.LastLogonDate -ge $thresholdDate -or $_.LastLogonDate -eq $null
} | Select-Object Name, OperatingSystem, LastLogonDate | Sort-Object LastLogonDate -Descending

#Print out results
Write-Host "`n========== INACTIVE COMPUTERS ==========" -ForegroundColor Yellow
if ($inactiveComputers.Count -gt 0) {
    Write-Host "Found $($inactiveComputers.Count) inactive computer(s):`n"
    $inactiveComputers | Format-Table -AutoSize
} else {
    Write-Host "✅ No inactive '$selectedVersion' systems found in the last $inactiveDays days."
}

Write-Host "`n========== ACTIVE COMPUTERS ==========" -ForegroundColor Green
if ($activeComputers.Count -gt 0) {
    Write-Host "Found $($activeComputers.Count) active computer(s):`n"
    $activeComputers | Format-Table -AutoSize
} else {
    Write-Host "❗ No active '$selectedVersion' systems found (unexpected)."
}

# Microsoft hygiene guidance
Write-Host "`n📘 Microsoft Hygiene Recommendations:" -ForegroundColor Cyan
Write-Host "- Disable stale accounts first, then delete after monitoring."
Write-Host "- Regularly check for unused computers to reduce attack surface."
Write-Host "- Suggested threshold: 90 days (adjust per org policy)."
Write-Host "- Official Microsoft Links:"
Write-Host "  → https://learn.microsoft.com/en-us/services-hub/unified/health/remediation-steps-ad/regularly-check-for-and-remove-inactive-user-accounts-in-active-directory"
Write-Host "  → https://learn.microsoft.com/en-us/entra/identity/devices/manage-stale-devices"
Write-Host "- Official Microsoft Release Information:"
Write-Host "  → https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information"
Write-Host "  → https://learn.microsoft.com/en-us/windows/release-health/release-information"

#Export results into text file - active computer only, inactive computer only or both
$exportChoice = Read-Host "`nDo you want to export the results to a text file? (yes/no)"
if ($exportChoice -match '^y') {
    Write-Host "`nChoose what to export:"
    Write-Host "[1] Inactive computers only"
    Write-Host "[2] Active computers only"
    Write-Host "[3] Both inactive and active computers"

    do {
        $exportOption = Read-Host "Enter your choice (1, 2, or 3)"
    } until ($exportOption -in '1','2','3')

    $outputPath = "$env:USERPROFILE\Desktop\AD-ComputerCheck-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

    switch ($exportOption) {
        '1' {
            "===== INACTIVE COMPUTERS =====" | Out-File $outputPath
            $inactiveComputers | Format-Table -AutoSize | Out-String | Out-File $outputPath -Append
        }
        '2' {
            "===== ACTIVE COMPUTERS =====" | Out-File $outputPath
            $activeComputers | Format-Table -AutoSize | Out-String | Out-File $outputPath -Append
        }
        '3' {
            "===== INACTIVE COMPUTERS =====" | Out-File $outputPath
            $inactiveComputers | Format-Table -AutoSize | Out-String | Out-File $outputPath -Append
            "`n===== ACTIVE COMPUTERS =====" | Out-File $outputPath -Append
            $activeComputers | Format-Table -AutoSize | Out-String | Out-File $outputPath -Append
        }
    }

    Write-Host "`n✅ Export complete! File saved to:`n$outputPath" -ForegroundColor Cyan
}
