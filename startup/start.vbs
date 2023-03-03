' this file should be configured to run at startup with Windows Task Scheduler.
' follow the settings below.
' 
' General -> Security Options:
'   When running the task, use the following user account: select the user you use with WSL and Docker.
'   Run only when user is logged on: checked.
'	Run with highest privileges: checked.
' 
' Triggers -> New:
'   Begin the task: select "At log on".
'   Settings -> Specific user: select the user you use with WSL and Docker.
'	Enabled: checked.
' 
' Actions -> New:
'   Action: select "Start a program".
'   Program/script: select this file.
'   Start in (optional): enter the directory this file is in.

Option Explicit

Dim shell
Set shell = CreateObject("WScript.Shell")

shell.Run "cscript config.vbs", 0