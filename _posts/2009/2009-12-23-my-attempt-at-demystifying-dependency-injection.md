---
title: "My attempt at demystifying dependency injection"
date: "2009-12-23"
categories: 
  - "design-principles"
tags: 
  - "design-principles"
---

I think I can safely say I finally "get" dependency injection (DI) and the need for a framework (such as [StructureMap](http://structuremap.sourceforge.net), [Ninject](http://ninject.org/), Windsor, or [any other](http://www.hanselman.com/blog/ListOfNETDependencyInjectionContainersIOC.aspx)). More importantly, I think I finally get the best way to use it in an application. Its taken me a bit to get to this point, and almost everything I've read and heard on the subject was very _hand-wavy_, at least to me. So here's my attempt at demystifying the subject along with a straight forward way to go about using it in your application, something I wish I could have heard a while ago.

## What is it?

Many objects have an outside dependency of some sort. Instead of creating the dependency inside your class (by doing something like `myDependency = new Dependency()`), you want these dependencies to be "injected" in, usually by the constructor:

public class OrderProcessingService
{
	private readonly IRepository \_repository;

	public OrderProcessingService(IRepository repository)
	{
		\_repository = repository;
	}
}

That's it. Seriously. It's not hard to grasp, and you're probably already doing it, but the trick for me was figuring out how to actually go about using this in any sort of sane and recommended way, as you'll notice the requirement is now on the caller to provide an instance of `IRepository`. If you want more details on this pattern, [there's plenty out there](http://www.google.com/search?q=dependency+injection).

## Why should I bother using it?

1. **It takes handling the dependency's life cycle out of your hands.** Perhaps you want your database access class to stick around for a whole web request, another object to be a singleton, and another to be per thread when used in a Windows app, but per request in a Web app? Using a proper DI framework/container, you don't have to worry about writing anything to support that, and changing the lifespan of a given object is a one line (and usually even enumeration value) change.
2. **It loosens up your code.** You're no longer "newing" up your data access or web service classes right in the middle of your operation. Swapping out implementations of, say, an interface, is a simple operation that's located in one place. Just stick the dependency in your constructor, and you're good to go. I've actually used this in quite a few places beyond the academic and largely unused-in-the-real-world "switching from Ms SQL to Oracle" examples, too.
3. **Greatly eases and simplifies unit testing.** In many cases, using dependency injection is the only way to unit test portions of your code base (unless you use [a certain tool to do it for you](http://site.typemock.com/index2/)). By taking your dependencies in your constructor, you're giving your unit tests a seam to inject fake implementation of these dependencies. This lets you skip actually hitting the database, web service, hard drive, or anything else that would kill the running time of a unit test or be almost impossible to setup and control in a repeatable manner.

If you're looking for more detailed reasons, you'll again want to refer to the [gobs of information](http://www.google.com/search?q=dependency+injection) already out there.

## How can I use it?

Ah, now for the juicy part I know you're all dying to hear: how the hell to actually use the pattern in conjunction with one of the tools I mentioned at the beginning of the post. Before giving away the answer, let's quickly go over the three primary ways to use a DI container in your app:

1. **Service locator:** this pattern is generally considered a no-no, as it still burys your dependencies deep inside your code. Sure, you can swap them out when needed for unit testing, but they're still very opaque and will almost certainly get very hard to work with, very fast:  
      
    
    public void ProcessOrder()
    {
    	var repository = IoC.Resolve();
    	
    	// Do stuff with repository.
    } 
    
    In the above example, `IoC.Resolve` is a simple static method that delegates to whatever DI framework you're using. Callers won't know about this dependency, though, and without fully boot strapping your framework in your unit test (icky) or injecting a fake into your container, the call will either throw or return null, neither of which you want to be checking for everywhere.  
      
    
2. **Poor-man's dependency injection:** This is a slight twist on normal constructor DI. You have one empty constructor for most of the program to use, which delegates to a "loaded" constructor that unit tests use. While making the dependencies clear, this removes lifetime management from the container's hands, and also gets ugly when you start changing dependencies around. This is usually used in conjunction with the service locator pattern above:  
      
    
    public class OrderProcessingService
    {
    	private readonly IRepository \_repository;
    	
    	public OrderProcessingService() : this(IoC.Resolve())
    	{
    	}
    
    	public OrderProcessingService(IRepository repository)
    	{
    		\_repository = repository;
    	}
    } 
    
3. **True dependency injection:** Classes generally have only one constructor which takes in all the required dependencies (see the first code snippet at the top of the post).

#3, true dependency injection, is the one I had no idea how to go about setting up in my app. Everyone said not to use the service locator pattern or poor-man's dependency injection, but how was I supposed to _not_ use them and still get everything injected in? It seems like I was never supposed to call my DI container's `Resolve` method. So what gives? Every time someone got close to answering it, it seemed like they'd blow off the question. Ugh.

After enough playing around, reading, and looking at other open source projects, though, it finally clicked: **only call Resolve at the furthest edges of your application, and as few times as possible**. So what does that mean and where should you be calling it in your app? Well... it depends.

#### Wait, isn't that just another cop-out?

Well, yes and no. Yes in the fact that I'm not giving a solid answer, no in the sense that it really does depend on your application: what frameworks you're using, how you have its architecture setup, etc.

Just so you can't say I'm not providing anything solid, here's how I'm using it in our current app:

1. We're using ASP.NET MVC & StructureMap, so we're using a [custom controller factory](http://devlicio.us/blogs/derik_whittaker/archive/2008/08/15/setting-up-ioc-di-for-your-controllers-in-asp-net-mvc.aspx) that creates controllers from the container. This means we can create an `EmployeeService`, extract an interface for it named `IEmployeeService`, put it as a requirement in the controller's constructor, and it's satisfied magically at run time. Even cooler, everything down the object graph from `EmployeeService` (say, an `EmployeeRepository`, or `LoggingService`, or `EmailService`, or anything else you need) gets their dependencies all satisfied automagically, too. We can stick a constructor argument in virtually anywhere and it's taken care of for us, without giving it a second thought! Each web request, this all gets built out.
2. We have a basic home brewed scheduled task framework that, given the name of a task you want to run (say `/run Emailer` runs the `EmailerTask`), instantiates the requested task class, and runs it. We use the container at the point of instantiation, effectively treating each "task" class as a controller from above, filling all the dependencies it needs down the object graph.
3. We also fire off the scheduled task app by doing an `IoC.Resolve<IApplication>().Run()` in the console app's `Main` method, giving the app everything it needs.

In all, **we call `IoC.Resolve` only 4 times in our app**, and it handles everything for us. We usually forget it's even there, and take its services for granted when working with legacy applications that don't have it.

Now, what if you're using WebForms? Well, you're not \*completely\* out of luck. It's a pain, to be sure, but [still doable](http://www.google.com/search?q=webforms+ioc).

## Wrapping up

I hope this helped cleared up dependency injection for you a bit. Just remember to use the actual `Resolve` call of your container in as few places as possible in your application, and only on the "outside edges" of the app. Look at where you do all your main object creation (your web forms, Windows forms, controllers, WCF factories, Silverlight pages, etc). **Stick the call in there, and forget about it.**

Good luck.
