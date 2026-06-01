param(
    [Parameter(Mandatory)]
    [string]$ProjectDir,

    [string]$TaskName = "AionUI-DailyPipeline",
    [string]$Time = "06:00AM",
    [string]$PythonPath = "python"
)

$ErrorActionPreference = "Stop"
$SchedulerPath = Join-Path $ProjectDir "scheduler\pipeline_daily.py"

# Unregister existing task if present
$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "[...] Unregistering existing task '$TaskName'..."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Create action
$action = New-ScheduledTaskAction `
    -Execute $PythonPath `
    -Argument $SchedulerPath `
    -WorkingDirectory $ProjectDir

# Create daily trigger
$trigger = New-ScheduledTaskTrigger -Daily -At $Time

# Run with highest privileges (needed for KNIME/Power BI)
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

# Register
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "AionUI daily pipeline: KNIME ETL -> PBIRS refresh -> Open Design dashboard"

Write-Host "[OK] Scheduled task '$TaskName' created at $Time daily" -ForegroundColor Green
Write-Host "[INFO] Script: $SchedulerPath" -ForegroundColor Cyan
