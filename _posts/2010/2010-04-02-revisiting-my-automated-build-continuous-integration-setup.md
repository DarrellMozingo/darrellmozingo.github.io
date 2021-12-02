---
title: "Revisiting my automated build & continuous integration setup"
date: "2010-04-02"
---

A while back I wrote a small series on creating a basic build script and setting up a build server ([part 1](http://darrell.mozingo.net/2008/08/28/automated-builds-continuous-integration-part-1/), [part 2](http://darrell.mozingo.net/2008/09/26/automated-builds-continuous-integration-part-2/), and [part 3](http://darrell.mozingo.net/2008/12/31/automated-builds-continuous-integration-part-3/)). I used [NAnt](http://nant.sourceforge.net/) and [CruiseControl.NET](http://confluence.public.thoughtworks.org/display/CCNET/Welcome+to+CruiseControl.NET) in that series, but alluded to a few other options for each. I recently got around to switching our build script from NAnt to [psake](http://code.google.com/p/psake/), which is written in [PowerShell](http://technet.microsoft.com/en-us/scriptcenter/dd742419.aspx), and switching our build server from CruiseControl.NET to JetBrain's [TeamCity](http://www.jetbrains.com/teamcity/). I'll give a quick overview of our new build script here, which I'll use to build on in future posts showing a few of the more interesting things that suddenly became much easier with this setup, and in a few cases, possible at all.

To start with, you'll want to make sure you have the latest versions of PowerShell (2.0) and psake. Here's the basics of our build script:

$ErrorActionPreference = 'Stop'

Include ".\\functions\_general.ps1"

properties {
	$project\_name = "MainApplication"
	$build\_config = "Debug"
}

properties { # Directories
	$scm\_hidden\_dir = ".svn";
	
	$executing\_directory = new-object System.IO.DirectoryInfo $pwd
	$base\_dir = $executing\_directory.Parent.FullName

	$source\_dir = "$base\_dir\\src"

	$build\_dir = "$base\_dir\\build"
	$tools\_dir = "$base\_dir\\tools"
	$build\_tools\_dir = "$build\_dir\\tools"

	$build\_artifacts\_dir = "$build\_dir\\artifacts"
	$build\_output\_dir = "$build\_artifacts\_dir\\output"
	$build\_reports\_dir = "$build\_artifacts\_dir\\reports"

	$transient\_folders = @($build\_artifacts\_dir, $build\_output\_dir, $build\_reports\_dir)
}

properties { # Executables
	$tools\_nunit = "$tools\_dir\\nunit\\nunit-console-x86.exe"
	$tools\_gallio = "$tools\_dir\\Gallio\\Gallio.Echo.exe"
	$tools\_coverage = "$build\_tools\_dir\\ncover\\ncover.console.exe"
	$tools\_coverageExplorer = "$build\_tools\_dir\\ncover\_explorer\\NCoverExplorer.Console.exe"
}

properties { # Files
	$solution\_file = "$source\_dir\\$project\_name.sln"

	$output\_unitTests\_dll = "$build\_output\_dir\\$project\_name.UnitTests.dll"
	$output\_unitTests\_xml = "$build\_reports\_dir\\UnitTestResults.xml"
	$output\_coverage\_xml = "$build\_reports\_dir\\NCover.xml"
	$output\_coverage\_log = "$build\_reports\_dir\\NCover.log"
	$output\_coverageExplorer\_xml = "$build\_reports\_dir\\NCoverExplorer.xml"
	$output\_coverageExplorer\_html = "$build\_reports\_dir\\NCover.html"
}

properties { # Skip coverage attributes
	$skipCoverage\_general = "Testing.SkipTestCoverageAttribute"
}

task default -depends unit\_test\_coverage

task clean {
	$transient\_folders | ForEach-Object { delete\_directory $\_ }
	$transient\_folders | ForEach-Object { create\_directory $\_ }
}

task compile -depends clean {
	exec { msbuild $solution\_file /p:Configuration=$build\_config /p:OutDir=""$build\_output\_dir\\\\"" /consoleloggerparameters:ErrorsOnly }
}

task unit\_test\_coverage -depends compile {
	exec { & $tools\_coverage $tools\_nunit $output\_unitTests\_dll /nologo /xml=$output\_unitTests\_xml //reg //ea $skipCoverage\_general //l $output\_coverage\_log //x "$output\_coverage\_xml" //a $project\_name }
	exec { & $tools\_coverageExplorer $output\_coverage\_xml /xml:$output\_coverageExplorer\_xml /html:$output\_coverageExplorer\_html /project:$project\_name /report:ModuleClassFunctionSummary /failMinimum }
}

As the second line alludes to, you can break functions out into separate files and include them back into the main one. Here's `functions_general.ps1`:

function delete\_directory($directory\_name)
{
	Remove-Item -Force -Recurse $directory\_name -ErrorAction SilentlyContinue
}

function create\_directory($directory\_name)
{
	New-Item $directory\_name -ItemType Directory | Out-Null
}

This script will build our project and run the unit tests, producing a coverage report we can display later inside Team City. Much of this maps loosely one to one against the NAnt version discussed in my past series, and there's plenty of articles/posts online explaining this stuff in much more detail than I can here. Note that all the pieces that can "fail" the script are wrapped in `exec`, which will execute the code block (i.e. lambda/anonymous delegate) and basically alert the build server if it fails. Not too difficult, at least for now :)

As for getting this to work with Team City, if you specify the runner as a command line and point it at a batch file with these contents:

@echo off
cls
powershell -Command "& { Set-ExecutionPolicy Unrestricted; Import-Module .\\build\\tools\\psake\\psake.psm1; $psake.use\_exit\_on\_error = $true; Invoke-psake '.\\build\\build.ps1' %\*; Remove-Module psake}"

You'll be golden. This batch allows the build server to run the script (perhaps setting unrestricted execution isn't the smartest from a security standpoint, but oh well), sets up the psake environment, tells psake to raise its warnings in a way that TeamCity can pick up on, executes your build script, and tears down the psake environment. Looks a little complicated, but it's just a bunch of smaller commands strung together on one line, and you shouldn't have to look at it again.
