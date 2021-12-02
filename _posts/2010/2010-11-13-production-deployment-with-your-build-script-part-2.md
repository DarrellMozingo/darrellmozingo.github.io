---
title: "Production deployment with your build script - Part 2"
date: "2010-11-13"
---

In the [first post](http://darrell.mozingo.net/2010/09/24/production-deployment-with-your-build-script-part-1/) I gave a quick overview of what our deployment script does and why you'd want one. This post will go over some of the pre-deployment steps we take. Most all of this code will probably be pretty self explanatory, but I know just having something to work off of is a huge boost to starting your own, so here ya go.

function modify\_web\_config\_for\_production($webConfig)
{
	echo "Modifying $webConfig for production deployment."

	$xml = \[xml\](Get-Content $webConfig)
	$root = $xml.get\_DocumentElement();

	$root."system.web".compilation.debug = "false"

	$xml.Save($webConfig)
}

Given the path to a `web.config` file, this function switches off the debug flag (and any other changes you'd need). Being a dynamic language, you can access XML keys quite easily. You'll need the quotes around `system.web` since there's the dot in the name though. Also, if you need access to any of the `app.settings` keys, you can use something like: `$xml.selectSingleNode('//appSettings/add[@key="WhateverYourKeyIs"]').value = "false"`.

function precompile\_site($siteToPreCompile, $compiledSite)
{
	echo "Precompiling $siteToPreCompile."

	$virtual\_directory = "/"

	exec { & $tools\_aspnetCompiler -nologo -errorstack -fixednames -d -u -v $virtual\_directory -p "$siteToPreCompile" $compiledSite }
}

This little beauty precompiles the site (located in the `$siteToPreCompile` directory, with the results output to the `$compiledSite` directory) using the ASP.NET compiler. I prefer to copy the actual compiler executable into the project folder even though it's installed with the Framework. Not sure why. Anyway, `$tools_aspnetCompiler` can either point locally, or to `C:\Windows\Microsoft.NET\Framework\vwhatever\aspnet_compiler.exe`. You can also configure the options being passed into the compiler to suit your needs.

function execute\_with\_secure\_share($share, \[scriptblock\]$command)
{
	try
	{
		echo "Mapping share $share"
		exec { & net use $share /user:$security\_full\_user $security\_password }

		& $command
	}
	finally
	{
		echo "Unmapping share $share"
		exec { & net use $share /delete }
	}
}

This is more of a helper method that executes a given script block (think of it as an `Action` or anonymous code block in C#) while the given share is mapped with some known username and password. This is used to copy out the site, create backups, etc. I'll leave the `$security_full_user` & `$security_password` variable declarations out, if you don't mind! We just put them in plain text in the build script (I know, \*gasp!\*).

properties {
	$share\_web = "wwwroot"
	$servers\_production = @("server1", "server2")
	$live\_backup\_share = "\\\\server\\LiveSiteBackups"

	$number\_of\_live\_backups\_to\_keep = 10
}

function archive\_current\_live\_site
{
	$current\_datetime = Get-Date -Format MM\_dd\_yyyy-hh\_mm\_tt
	$one\_of\_the\_production\_servers = $servers\_production\[0\]

	$web\_share\_path = "\\\\$one\_of\_the\_production\_servers\\$share\_web"

	echo "Archiving $web\_share\_path"

	$full\_backup\_path = "$web\_share\_path\\\*"
	$full\_archive\_file = "$live\_backup\_share\\$current\_datetime.zip"

	execute\_with\_secure\_share $web\_share\_path {
		execute\_with\_secure\_share $live\_backup\_share {
			exec { & $tools\_7zip a $full\_archive\_file $full\_backup\_path } 
		}
	}
}

function delete\_extra\_live\_site\_backups
{
	execute\_with\_secure\_share $live\_backup\_share {
		$current\_backups = Get-ChildItem $live\_backup\_share -Filter "\*.zip" | sort -Property LastWriteTime
		$current\_backups\_count = $current\_backups.Count

		echo "Found $current\_backups\_count live backups out there, and we're aiming to keep only $number\_of\_live\_backups\_to\_keep."

		$number\_of\_backups\_to\_kill = ($current\_backups\_count - $number\_of\_live\_backups\_to\_keep);

		for ($i = 0; $i -lt $number\_of\_backups\_to\_kill; $i++)
		{
			$file\_to\_delete = $current\_backups\[$i\]
			$extra\_backup = "$live\_backup\_share\\$file\_to\_delete"

			echo "Removing old backup file: $extra\_backup"
			delete\_file $extra\_backup
		}
	}
}

These pair of methods create a backup of the current live site and make sure we're only keeping a set number of those backups from previous runs, to keep storage and maintenance in check. Nothing too complicated. To create the backup, we just farm out to [7-Zip](http://www.7-zip.org/) to compress the directory, which is ran withing nested `execute_with_secure_share` calls from above, which map the web server file share and backup file share. Likewise, the second method just gets a count of zip files in the storage directory and deletes the oldest ones in there until the total count gets to a specified count.

## Conclusion

That's the basics for what we do pre-deployment. Again, not really that complicated, but it can give you a starting point for your script. I'll go over our actual deployment steps in the next post, then follow that up with some post-deployment goodness. I know, you can't wait.
