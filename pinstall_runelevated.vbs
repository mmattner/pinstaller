' VBS script - sole purpose is to trigger UAC eidget to get permission to
' elevate permissions before running the hardcoded script Temp\elevated_script.bat
' The content of this script is populated by the calling application (refer to
' pinstall_utils.run_elevated
'
Set UAC = CreateObject("Shell.Application")
UAC.ShellExecute "Temp\elevated_script.bat", "", "", "runas"