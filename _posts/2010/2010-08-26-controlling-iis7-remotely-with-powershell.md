---
title: "Controlling IIS7 remotely with PowerShell"
date: "2010-08-26"
---

Our deployment script needed to do some basic IIS administrative tasks remotely on a Windows 2008 (non-R2) server, which runs IIS7, recently. Finding the information and fiddling around with it took me a good day and a half, so I thought I'd post the steps here to help someone else (more than likely myself) in the future:

1. Download the [Windows Management Framework Core package](http://support.microsoft.com/kb/968929) for your setup
2. If your machine is something older than Windows 7 or Server 2008 **R2**, you'll need to get the [PowerShell IIS7 Snap-In](http://www.iis.net/download/powershell)
3. If your workstation/build server and target web servers happen to be on different Windows domains, you'll need to run this one time on each client machine:
    
    Set-Item WSMan:\\localhost\\Client\\TrustedHosts \*
    
4. Run this command once on each server:
    
    winrm quickconfig
    
5. You'll need to load the PowerShell Snap-In once on each client, which differs depending on which version of Windows you're running. Anything older than Windows 7 or Server 2008 **R2**:
    
    Add-PSSnapin WebAdministration
    
    Windows 7 and Server 2008 **R2** run:
    
    Load-Module WebAdministration
    
6. Check if it's working properly by running this command on any version of Windows (you should see the IIS7 Snap-In listed):
    
    Get-Module -ListAvailable
    
7. [Get credentials for accessing the remote server](http://www.brangle.com/wordpress/2009/08/pass-credentials-via-powershell)
8. Start running some remote commands on your web servers:
    
    Invoke-Command -ComputerName "webserver\_computerName" -Credential $credentials\_from\_last\_step -ScriptBlock { Add-PSSnapin WebAdministration; Stop-Website IIS\_Site\_Name }
    

It's not really that hard once you get the proper packages installed and the permissions worked out, and since it's so powerful and useful for scripting purposes it's well worth the trouble. The available commands are awesome for use in automated deployment scripts.

You can learn more about the PowerShell Snap-In provider [here](http://learn.iis.net/page.aspx/428/getting-started-with-the-iis-70-powershell-snap-in), and at its download site [here](http://www.iis.net/download/powershell).
