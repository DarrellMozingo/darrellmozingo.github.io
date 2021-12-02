---
title: "Injecting all instances of a given type"
date: "2009-09-15"
---

I'm sure I'm a little late to the game here, but I recently stumbled across how to do collection injection with [Structure Map](http://structuremap.sourceforge.net/Default.htm). I've known it was possible, and have seen it hinted at in other blogs posts for a while, but I just didn't know how exactly it was done.

Why would you want to do this? Lets take an actual situation from our system. We rolled a small scheduled task framework (sorry [Quartz.NET](http://quartznet.sourceforge.net/) and [Topshelf](http://code.google.com/p/topshelf/), you just didn't fit the bill for our needs). I wanted us to just drop a [POCO](http://en.wikipedia.org/wiki/Plain_Old_CLR_Object) object in the project and implement an `ITask` interface, which had exactly one method: `Run()`. I also wanted these objects to be pulled from the container so they could have services/repositories injected in as needed.

To make it easy for our network admins to schedule these tasks, I wrote the application to take a single **/run <taskName>** parameter. So if you wanted to run the `EmailUsersTask`, you'd simply run the app with **/run EmailUsers**. I also added a `TaskDescription` attribute so task authors could add a single sentence letting everyone know what it did, which would be displayed when the user ran the app with no parameters in a list with all the available tasks and a description of each.

Simple enough, right?

My first stab at it, and it actually ran for a while like this, took in Structure Map's `IContainer` to retrieve the task with all its dependencies satisfied, and to display all the available tasks it would just loop through all types in the assembly (filtered for only those implementing `ITask`), and get the needed display information.

Worked fine and dandy, but testing it was slow. I had to scan all the types in the assembly, even if I knew I was looking for a single test dummy class. I didn't like it, so I began tinkering with Structure Map. I wanted the fully initialized objects (from the container) injected in as an `IEnumerable<ITask>`, so I could just pluck the needed one to run, and loop through that list to build up the small display when needed. It would be easier to read and also make testing quicker and simpler. Here's what I ended up with:

```csharp
public static void BootstrapStructureMap()
{
    ObjectFactory.Initialize(y =>
                             {
                                 y.Scan(x =>
                                        {
                                            x.TheCallingAssembly();
                        x.WithDefaultConventions();
                        x.AddAllTypesOf();
                                        });
                                 
                    y.ForRequestedType<>()
                                     .TheDefault.Is.ConstructedBy(x => ObjectFactory.GetAllInstances());
                             });
} 
```

This is called while our app is boot strapping (though we use separate Registries for each area of the app, I just simplified it for posting). Pretty self explanatory - the `AddAllTypesOf` tells Structure Map to gather up all implementors of `ITask` in the assembly, and we then tell Structure Map to get all instances of that interface to pass it in whenever `IEnumerable<ITask>` is requested. Without that, you'd have to take in an array of `ITask's`. Same difference, I just prefer enumerables.

So there you go - get a collection of fully constructed types injected into your objects. We did this assembly type looping in one or two other system startup areas of the app, and I was able to kill them all off with this technique while shaving a good 4 seconds off our unit test suite. Pretty neato.

As a moral, of sorts, for this story, I also learned after doing all this to [always RTFM](http://structuremap.sourceforge.net/ScanningAssemblies.htm#section5) when you have a question. It'll save you a lot of time tinkering on your own :)
