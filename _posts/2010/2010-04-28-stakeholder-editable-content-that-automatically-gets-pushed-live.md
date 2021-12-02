---
title: "Stakeholder editable content that automatically gets pushed live"
date: "2010-04-28"
---

I finally got around to implementing help screens on our site recently. We needed a system that would enable our domain peeps to update the help text directly with no intervention from us, along with being easy to implement and maintain on our end. I ended up using flat HTML files and a jQuery modal dialog ([Colorbox](http://colorpowered.com/colorbox/)), which has support for asynchronously loading those HTML files from disk when needed. The one thing we didn't want to do with this solution was give our domain peeps production server access or the responsibility of keeping those HTML files up to date on the servers - I could only imagine the chaos that'd ensue from that.

Solution: use our build script & build server to handle it for us.

We gave our domain peeps commit access to the repository - thankfully we're still on SVN, as I'm sure their heads will explode when we switch to a DVCS. This provides nice versioning and accountability features if someone messes up (imagine that), and gives us a hook for the build server. All help files are contained in a hierarchy under a folder that's appropriately named `HelpFiles`. I checked out just that folder from the source tree on their machines and gave them a quick commit/update spiel. We created empty HTML files for them, and they went about their way filling them all in.

Now on to the more interesting part, our build script. As I've mentioned previously, we're using [psake](http://code.google.com/p/psake/). Here's the relevant properties and task:

properties {
	$scm\_hidden\_dir = ".svn";
	
	$executing\_directory = new-object System.IO.DirectoryInfo $pwd
	$base\_dir = $executing\_directory.Parent.FullName

	$source\_dir = "$base\_dir\\src"
	$build\_dir = "$base\_dir\\build"
	$build\_tools\_dir = "$build\_dir\\tools"

	$share\_web = "wwwroot"
	$servers\_production = @("server1", "server2")

	$security\_user = "user\_with\_write\_access"
	$security\_password = "pa55w0rd"

	$tools\_robocopy = "$build\_tools\_dir\\robocopy\\robocopy.exe"

	$help\_folder = "HelpFiles"
	$help\_local\_dir = "$source\_dir\\$project\_name.Web\\$help\_folder"
	$deployTarget\_help = "$project\_name\\$help\_folder"
}

task publish\_help {
	foreach ($server in $servers\_production)
	{
		$full\_server\_share = "\\\\$server\\$share\_web"

		exec { & net use $full\_server\_share /user:$security\_user $security\_password }

		& $tools\_robocopy $help\_local\_dir $full\_server\_share\\$deployTarget\_help /xd $scm\_hidden\_dir /fp /r:2 /mir

		# See page 33 of the help file in the tool's folder for exit code explaination.
		if ($lastexitcode -gt 3)
		{
			Exit $lastexitcode
		}

		exec { & net use $full\_server\_share /delete }
	}
}

There's an array of production server names, which we iterate over and use the `net` command built into Windows to map its `wwwroot` share using a different username & password than the current user (this allows the build server to run as an unprivileged user but still access needed resources).

Then we use the surprisingly awesome [Robocopy](http://en.wikipedia.org/wiki/Robocopy) tool from Microsoft, which is basically xcopy on steroids, to copy out the help files themselves. The `xd` flag is excluding the hidden .svn folders, the `fp` flag is displaying full path names in the output (for display in the build output from TeamCity later), the `r` flag is telling it to only retry failed file twice (as opposed to the default _million_ times!), and the `mir` flag is telling it to mirror the source directory tree to the destination, including empty folders and removing dead files.

We can't use psake's built in `exec` function to run Robocopy, as exec only checks for non-zero return codes before considerng it a failure. Of course, just to be different, Robocopy only fails if its return code is above 3 (1 = one or more files copied successfully, 2 = extra files or folders detected, and there is no 3). So we check the return code ourselves and exit if Robocopy failed. We then delete the share, effectively making the machine forget the username/password associated with it.

With that done, we created a new build configuration in TeamCity and had it check the repository for changes only to the help file directory by adding `+:src/Project.Web/HelpFiles/**` to the Trigger Patterns field on the Build Triggers configuration step.

That's pretty much it. Our domain peeps have been pretty receptive to it so far, and they love being able to edit the help files, commit, and see them live only a minute or two later. We loved not having to pull all that text from the database on each page load and not having to create editing/viewing/versioning/etc tools around such a process. It's a win-win.
