---
title: "Production deployment with your build script - Part 3"
date: "2010-11-25"
categories: 
  - "build-management"
tags: 
  - "build-management"
---

In the [first post](http://darrell.mozingo.net/2010/09/24/production-deployment-with-your-build-script-part-1/) I gave a quick overview of what our deployment script does and why you'd want one, then the [second post](http://darrell.mozingo.net/2010/11/12/production-deployment-with-your-build-script-part-2/) went over pre-deployment steps. This post will go over the actual deployment steps we take to publish our site. Like the last post, most all of this code will probably be pretty self explanatory.

function deploy\_and\_prime\_site
{
	modify\_web\_config\_for\_production
	precompile\_site

	archive\_site
	delete\_extra\_live\_site\_backups

	try
	{
		stop\_dns\_caching

		foreach ($server in $servers\_production)
		{
			deploy\_site\_to $server
			preload\_site\_on $server
		}

		foreach ($server in $servers\_production)
		{
			ensure\_error\_emails\_are\_working\_on $server $live\_url
		}
	}
	finally
	{
		remove\_hosts\_file\_entries
		start\_dns\_caching
	}
}

This is the function the build target actually calls into. The part you'll care about here is where it loops through the known production servers and deploys the site to each one in tern. The "preloading" of the site, checking for functioning error emails, and DNS caching stuff is some of the post-deployment steps we take, which I'll discuss in the next post.

## IIS Remote Control

Here's how we control IIS remotely (this is IIS7 on Windows 2008 R2 - not sure how much changes for different versions):

function execute\_on\_server($target\_server, \[scriptblock\]$script\_block)
{
	$secure\_password = ConvertTo-SecureString $security\_password -AsPlainText -Force
	$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $security\_full\_user, $secure\_password

	Invoke-Command -ComputerName $target\_server -Credential $credential -ScriptBlock $script\_block
}

function stop\_iis\_on($target\_server)
{
	echo "Stopping IIS service on $target\_server..."

	execute\_on\_server $target\_server { & iisreset /stop }
}

function start\_iis\_on($target\_server)
{
	echo "Starting IIS service on $target\_server..."

	execute\_on\_server $target\_server { & iisreset /start }
}

The secret sauce to getting this to work is the `execute_on_server` function. The actual stop & start methods just execute standard `iisreset` commands (which is a built-in command line tool w/IIS). So the top function converts our plain text server username & passwords in the build script into a `SecureStringPSCredential` object. Not the most secure way to do this, I'm sure (hence the `-Force` parameter), but it's working for us. After connecting to the remote machine, it executes the given script block with those credentials (like the `execute_with_secure_share` function from the last post). In order to make this work though, you'll need to give some lovin' on your build server and web servers:

- Make sure all boxes have at least PowerShell 2.0 with WinRM 2.0 (which is what allows the remote machine command execution)
- On each web server, you'll need to run this one time command from a PowerShell prompt: `Enable-PSRemoting`

## Deployment

With that out of the way, the actual deployment part is pretty easy - it's just copying files after all:

properties {
	$siteWebFolder\_name = $solution\_name

	$ident\_file = "Content\\ident.txt"
}

function pause\_for($seconds)
{
	sleep -s $seconds
}

function deploy\_site\_to($server)
{
	echo "\*\*\* Beginning site deployment to $server."

	$compiled\_site = "$compiled\_site\\\*"
	$web\_share = "\\\\$server\\$share\_web"
	$live\_site\_path = "$web\_share\\$siteWebFolder\_name"

	stop\_iis\_on $server

	pause\_for 10 #seconds, to give IIS time to release file handles.

	execute\_with\_secure\_share $web\_share {
		echo "Deleting the existing site files on $server ($live\_site\_path )."
		delete\_directory\_with\_errors "$live\_site\_path \\\*"

		echo "Copying the new site files (from $compiled\_site) to $server."
		copy\_directory $compiled\_site $live\_site\_path 

		echo "Creating ident file at $live\_site\_path."
		"$server" > "$live\_site\_path\\$ident\_file"
	}

	start\_iis\_on $server
}

Stop IIS, give it a few seconds, copy files, start IIS. Like I said - simple. If your situation can't allow this for some reason (perhaps you have a more complicated load balancing scheme or whatever), you can expand as needed. We actually deploy several sites and a few console apps at the same time so everything's in sync. The ident file is a simple way for us to find out which server a user's on for troubleshooting purposes. We can navigate to the url + /Content/ident.txt and it'll have the server's name.

## Conclusion

Other than the actual remote manipulation of the servers, which we keep to a pretty minimum IIS start & stop, there's not much to this part of the build either. This code provides a good jumping off point for customization to your setup, as well as some helper methods you can hopefully make use of. The next post will wrap up this series by showing some of the post-deployment steps we take.
