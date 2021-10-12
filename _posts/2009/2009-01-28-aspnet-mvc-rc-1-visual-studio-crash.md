---
title: "ASP.NET MVC RC 1 Visual Studio Crash"
date: "2009-01-28"
categories: 
  - "quickie"
tags: 
  - "quickie"
---

After installing the newly released [ASP.NET MVC RC 1](http://weblogs.asp.net/scottgu/archive/2009/01/27/asp-net-mvc-1-0-release-candidate-now-available.aspx), Visual Studio started crashing on me when opening a View (.aspx filer), always with the following error in the Application event log:

> **Error 1/28/2009 10:50:31 AM .NET Runtime 1023 None**  
> .NET Runtime version 2.0.50727.3053 - Fatal Execution Engine Error (707F5E00) (80131506)

Though every few tries, this one would pop up too:

> **Error 1/28/2009 10:41:27 AM devenv 0 None**  
> The description for Event ID 0 from source devenv cannot be found. Either the component that raises this event is not installed on your local computer or the installation is corrupted. You can install or repair the component on the local computer.
> 
> If the event originated on another computer, the display information had to be saved with the event.
> 
> The following information was included with the event:
> 
> The data source '{130bada6-e128-423c-9d07-02e4734d45d4}' specifies no supporting providers or a set that are not registered.

Oh, and as an FYI, this is on a Vista 64-bit box.

Seems quite a few people had this almost identical problem with the Preview 5 release last time. Uninstalling all my add-ins (Visual SVN, ReSharper, Gallio, etc.) didn't help, nor did a complete MVC re-install after rebooting.

I eventually found a post [here](http://www.babel-lutefisk.net/2008/09/fix-for-aspnet-mvc-preview-5-bug-with.html) that mentioned whacking the bin folder and all its contents helped their Preview 5 issue. It didn't quite work for me, _however_, after removing and re-adding the references to all four MVC assemblies (`Microsoft.Web.Mvc`, `System.Web.Mvc`, `System.Web.Abstractions`, and `System.Web.Routing`) and doing a full rebuild, my problem disappeared and I was good to go.

It's odd how an assembly reference would cause Visual Studio to crash. It must be trying to do something with them when you open the .aspx page in the source view. Even odder is the fact that I overwrote the old Preview 5 assemblies with the new ones, so I thought doing a full rebuild in Visual Studio would have automatically used those new assemblies. Guess the IDE needs them re-referenced, though. Oh well, works now.
