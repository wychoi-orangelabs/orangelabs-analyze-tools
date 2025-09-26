[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 전체 시스템 메모리 현황
$os = Get-CimInstance Win32_OperatingSystem
$totalMemory = $os.TotalVisibleMemorySize * 1KB
$freeMemory = $os.FreePhysicalMemory * 1KB
$usedMemory = $totalMemory - $freeMemory

Write-Host "===== System Memory Information ====="
Write-Host "Total Memory : $([math]::Round($totalMemory / 1GB, 2)) GB"
Write-Host "Used  Memory : $([math]::Round($usedMemory / 1GB, 2)) GB"
Write-Host "Free  Memory : $([math]::Round($freeMemory / 1GB, 2)) GB"
Write-Host ""

# 시스템 프로세스와 사용자 프로세스 구분
$processes = Get-Process
$systemProcesses = $processes | Where-Object {$_.ProcessName -match "^(System|smss|csrss|wininit|winlogon|services|lsass|dwm|explorer)"}
$userProcesses = $processes | Where-Object {$_.ProcessName -notmatch "^(System|smss|csrss|wininit|winlogon|services|lsass|dwm|explorer)"}

$systemWS = ($systemProcesses | Measure-Object WorkingSet -Sum).Sum
$userWS = ($userProcesses | Measure-Object WorkingSet -Sum).Sum
$totalProcessWS = ($processes | Measure-Object WorkingSet -Sum).Sum

Write-Host "===== Process Memory Information ====="
Write-Host "Total  Process : $([math]::Round($totalProcessWS / 1GB, 2)) GB"
Write-Host "System Process : $([math]::Round($systemWS / 1GB, 2)) GB"
Write-Host "User   Process : $([math]::Round($userWS / 1GB, 2)) GB"
Write-Host ""

# 커널 메모리 정보
$kernelPaged = (Get-Counter "\Memory\Pool Paged Bytes").CounterSamples.CookedValue
$kernelNonPaged = (Get-Counter "\Memory\Pool Nonpaged Bytes").CounterSamples.CookedValue
$systemCache = (Get-Counter "\Memory\System Cache Resident Bytes").CounterSamples.CookedValue
$totalKernelUsed = $kernelPaged + $kernelNonPaged + $systemCache

Write-Host "===== Kernel Memory Information ====="
Write-Host "Total Kernel Used    : $([math]::Round($totalKernelUsed / 1MB, 2)) MB"
Write-Host "Kernel Paged    Pool : $([math]::Round($kernelPaged / 1MB, 2)) MB"
Write-Host "Kernel NonPaged Pool : $([math]::Round($kernelNonPaged / 1MB, 2)) MB"  
Write-Host "System cache         : $([math]::Round($systemCache / 1MB, 2)) MB"
Write-Host ""

$totalSystemUsed = $usedMemory
$totalProcessMemory = $totalProcessWS
$unaccountedMemory = $totalSystemUsed - $totalProcessMemory - $totalKernelUsed

Write-Host "===== Memory Use Analyze ====="
Write-Host "System Total Used        : $([math]::Round($totalSystemUsed / 1GB, 2)) GB"
Write-Host "Total Process Workingset : $([math]::Round($totalProcessMemory / 1GB, 2)) GB"
Write-Host "Total Kernel Used        : $([math]::Round($totalKernelUsed / 1GB, 2)) GB"
Write-Host "Untracked Memory         : $([math]::Round($unaccountedMemory / 1GB, 2)) GB"
Write-Host "Untracked Percent        : $([math]::Round(($unaccountedMemory / $totalSystemUsed) * 100, 1))%"
Write-Host ""