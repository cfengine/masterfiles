' Helper script to enumerate installed software (packages)
' Based on original work of Cory Coager at CDPHP <cory.coager@cdphp.com>
' This module reads the installed packages from the registry using WMI

Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE
strComputer = "."
strKeys=Array("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\", "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\")
strDisplayNameEntryA = "DisplayName"
strDisplayNameEntryB = "QuietDisplayName"
strInstallDateEntry = "InstallDate"
strDisplayVersionEntry = "DisplayVersion"

' Read registry using WMI
Set objReg = GetObject("winmgmts://" & strComputer & "/root/default:StdRegProv")
' Iterate through each uninstall registry key
For Each strKey in strKeys
  ' Enumerate the subkeys
  objReg.EnumKey HKLM, strKey, arrSubkeys
  ' Iterate through each subkey
  For Each strSubkey In arrSubkeys
    strDisplayNameValue = ""
    strInstallDateValue = ""
    strDisplayVersionValue = ""
    ' Read the DisplayName
    intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey, strDisplayNameEntryA , strDisplayNameValue)
    If intRet1 <> 0 Then
      ' On failure, read the QuietDisplayName
      intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey, strDisplayNameEntryB , strDisplayNameValue)
    End If
    ' Check if key has a DisplayName, otherwise not valid
    If intRet1 = 0 And strDisplayNameValue <> "" Then
      ' Read the InstallDate
      objReg.GetStringValue HKLM, strKey & strSubkey, strInstallDateEntry, strInstallDateValue
      ' Read the DisplayVersion
      objReg.GetStringValue HKLM, strKey & strSubkey, strDisplayVersionEntry, strDisplayVersionValue
      ' Replace whitespace with dashes for CFEngine
      ' strDisplayNameValue = Replace(strDisplayNameValue, " ", "-")
      ' Print out the DisplayName
      WScript.Echo "Name=" & LCase(strDisplayNameValue)
      ' Print out the DisplayVersion
      WScript.Echo "Version=" & LCase(strDisplayVersionValue)
      ' Print out the Architecture
      If InStr(strKey, "6432") = 0 Then
        WScript.Echo "Architecture=amd64"
      Else
        WScript.Echo "Architecture=amd64"
      End If
    End If
  Next
Next
