---
title: "Automated Builds & Continuous Integration - Part 1"
date: "2008-08-28"
categories: 
  - "build-management"
tags: 
  - "build-management"
---

Ah yes, automated build scripts and continuous integration servers. They form the foundation of any software project, or rather they should, but how would one go about setting them up? Before we get to that, let's differentiate a little first.

##### Build Scripts

These are simply scripts that another program parses and executes to build your project, usually doing everything from wiping your build directory to running unit test and integration tests, to possibly creating and destroying test databases. Build scripts can range from simple batch files to more complex [NAnt](http://nant.sourceforge.net/) scripts.

Actually, you may not realize it, but you're probably using build scripts already. Starting with Visual Studio 2005, [MSBuild](http://msdn.microsoft.com/en-us/library/wea2sca5(VS.80).aspx) has been used behind the scenes to automatically build your solution when you hit Build -> Build Solution. MSBuild can also be used independently in much the same way as NAnt scripts, and in fact many people consider these two build systems to be the most mature/robust for the .NET environment. They both consist of a lot of XML, though, so [put on your goggles](http://www.youtube.com/watch?v=uE9Dgp4zlPg) before taking a gander at any examples. There's also the [Boo Build System](http://www.ayende.com/Blog/archive/2007/09/22/Introducing-Boobs-Boo-Build-System.aspx) (though I think its been renamed to Bake due to its original initials) that's based on the Boo language, [psake](http://code.google.com/p/psake/) based on Powershell, [FinalBuilder](http://www.finalbuilder.com/) for a graphical approach, and [rake](http://rake.rubyforge.org/) that's built on Ruby, among many others.

So build script are read by a build system, and executed. Complicated batch scripts, basically. They can be run locally, and many people actually opt to run these scripts instead of using Visual Studio's build command once they get a good script setup, or they can be run automatically by other programs. I haven't gotten to the point of replacing Visual Studio's build command yet, but I can see its benefits.

##### Continuous Integration Servers

These little beauties generally run on their own box, and can either poll your source code repository (in whatever form it may come, be it Visual Source Safe, Subversion, Git, etc.) or run on a schedule, basically kicking off your build script whenever it sees changes. For instance, if you check in an update, the build server will see that update, clean its local copy of source code, do a full update of the source code locally, then run the build script you normally run on your box, building the code and running all sorts of tests. It can then go a step further and start copying the output to a staging server for your customers or testing folks to take a sneak peek at.

Continuous Integration (CI) servers come in quite a few flavors. One of the more popular in the .NET world is [Cruise Control .NET](http://confluence.public.thoughtworks.org/display/CCNET/Welcome+to+CruiseControl.NET) (CC.NET), though it too has a heavy reliance on XML. JetBrains (the guys that make ReSharper) have released [TeamCity](http://www.jetbrains.com/teamcity/) as a free download (for up to 20 user accounts and build configurations, and 3 build agents), which has an awesome web interface and lets you get a server setup in no time. It has built in support for quite a few features, and even comes with a plug-in for Visual Studio that lets you run a fake build locally on your machine before doing a code check-in. There are quite a few other CI servers out there, but these are the only two I've had time to play around with.

## Setting Up a Build Script and CI Server

New with C# 3.0 comes extension methods, which I'm sure everyone's heard of, and I'm equally sure that everyone has a small collection of handy ones in some sort of extension library. This library is probably shared across projects, and any developer wishing to use it in their project needs to do a get latest from the source code repository, build the solution, find the compiled assembly on their machine, and copy the it into their project. This repeats if they want to update their project's copy, too.

Seems like a lot of steps just to use or update the library, huh? Let's tidy that up a little, by:

1. Setting up a build script using NAnt, which will:
    - Clean the /bin folder
    - Do a full recompile of the source code
    - Run FxCop to check for out of place coding standards
    - Run MbUnit (my testing framework of choice)
    - Run NCover (using the latest freely available copy)
    - Run NCoverExplorer, which will generate a neat little XML file you can use to graphically see your code coverage (again, using the latest freely available copy)
    - Be able to run locally on each developer's machine, if they so choose
2. Setting up a continuous integration server using Cruise Control .NET, which will:
    - Both periodically poll the source control server for any new commits, along with just running at a set time every night
    - Clean its source code copy and run an update from the source control repository
    - Run the build script previously created
    - Email any developer that checked in code during this run with an update on the fail/pass status of the build
    - Allow any developer running a handy-dandy desktop app to instantly see the status of the build server (success, failure, building, etc)

Alright, alright, so this might not seem like it'll really tidy up anything right now, just add a crap load of work to our plates, but trust me, it's not as bad as it looks. A lot of this can be heavily templated across projects too, so once you cut your teeth on it, it's tremendously easier to setup again going forward.

In [Part 2](http://darrell.mozingo.net/2008/09/26/automated-builds-continuous-integration-part-2/), I'll talk about setting up the build script using NAnt.
