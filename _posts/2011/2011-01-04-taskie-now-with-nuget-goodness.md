---
title: "Taskie - now with NuGet goodness"
date: "2011-01-04"
---

![NuGet](/assets/2011/nuget-229x64.png "NuGet")

In addition to a few small bug fixes, Taskie is now filled with NuGet-y goodness (or should that be the other way around?). Anyway, you can grab the [package to use locally right here](https://github.com/downloads/DarrellMozingo/Taskie/taskie.0.999.nupkg) (with instructions on how to [host it locally](http://haacked.com/archive/2010/10/21/hosting-your-own-local-and-remote-nupack-feeds.aspx)). I'm working on getting it into the main NuGet package feed in the next week or two.

As part of this release, I'm merging StructureMap into the main assembly so you only have to worry about a single `Taskie.dll` assembly. I'm also going to see about getting this project on [Code Better's Team City](http://teamcity.codebetter.com/) setup for some continuous building lovin'. When that's done, I'll provide packages for both merged and unmerged flavors, just in case you need them separated out for whatever reason.

Next up on the list is adding task logging, along with the ability to see when a given task was last run (some of our accounting procedures depend upon the last date they were successfully run, so knowing this programatically is a must for us, and will come in handy for future features as well). Not sure how I'm going to go about it - perhaps a pluggable interface for your own implementation, a connection string you provide, or maybe Taskie's own internal Sqlite/Raven database. I'll have to play around with the options a bit.
