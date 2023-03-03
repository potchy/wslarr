' in this file, you can configure what services will be available to other computers in your network.
' if you need other services besides Overseerr and Plex, just uncomment them below.

Option Explicit

Dim services
Set services = CreateObject("Scripting.Dictionary")
' services.Add "Bazarr", 6767
services.Add "Overseerr", 5055
services.Add "Plex", 32400
' services.Add "Prowlarr", 9696
' services.Add "Radarr", 7878
' services.Add "Sonarr", 8989
' services.Add "Tautulli", 8181
' services.Add "Transmission", 9091

Dim shell
Set shell = CreateObject("WScript.Shell")

Function ShellExec(ByVal command)
	Dim exec
	Set exec = shell.Exec(command)

	Dim stdout
	stdout = exec.StdOut.ReadAll()

	If exec.ExitCode <> 0 Then
		Dim message
		message = stdout

		Dim stderr
		stderr = exec.StdErr.ReadAll()

		If Len(stderr) > 0 Then
			message = message & vbCrLf & stderr
		End If

		WScript.Echo message
		WScript.Quit exec.ExitCode
	End If

	ShellExec = stdout
End Function

Dim distros
distros = ShellExec("wsl --list --quiet")

If Len(Trim(distros)) = 0 Then
	ShellExec("wsl exit")
	WScript.Echo "WSL has been started."
Else
	WScript.Echo "WSL is already running."
End If

Dim ipAddresses
ipAddresses = ShellExec("wsl.exe hostname -I")
ipAddresses = Split(ipAddresses, " ")

Dim ipAddress
ipAddress = ipAddresses(0)
WScript.Echo "WSL IP address is: " & ipAddress & "."

Dim service
For Each service In services
	Dim port
	port = services(service)

	shell.Run "netsh advfirewall firewall delete rule name=" & service, 0, True
	WScript.Echo "Any existing firewall rule for service '" & service & "' has been deleted."

	ShellExec("netsh advfirewall firewall add rule name=" & service & " dir=in action=allow enable=yes profile=private localport=" & port & " protocol=tcp")
	WScript.Echo "The firewall rule for service '" & service & "' on port " & port & " has been added successfully."

	' forward requests from Windows to the Linux distribution.
	' check the following link for more information: https://gist.github.com/jamietre/d463f0f9132f564bf1d7727257eabf13
	shell.Run "netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=" & port, 0, True
	WScript.Echo "Any existing portproxy on port " & port & " has been deleted."

	ShellExec("netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=" & port & " connectaddress=" & ipAddress & " connectport=" & port)
	WScript.Echo "The portproxy rule on port " & port & " has been added successfully."
Next

' by maintaining a terminal session alive, WSL will not shutdown on its own.
' check the following link for more information: https://github.com/microsoft/WSL/issues/8854
shell.Run "wsl", 0