---
title: "Taskie runner is now bundled"
date: "2011-03-04"
categories: 
  - "taskie"
tags: 
  - "taskie"
---

The latest version of [Taskie](https://github.com/DarrellMozingo/Taskie) (which is available on NuGet) now comes bundled with a console runner. Simply implement `ITaskieServiceLocator` with your IoC container of choice, and put your compiled assembly with that implementation in the same directory as `Taskie.exe`. Taskie will pick up on the implementation and use it like normal.

This should reduce the usage overhead if you don't feel like creating a virtually empty console project in your application, and lower the getting started barrier even more. If you'd still like to host your own console application for Taskie, that option will continue to be supported and its usage hasn't changed.
