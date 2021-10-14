---
title: "The Pit of Success"
date: "2011-06-27"
categories: 
  - "design-principles"
tags: 
  - "design-principles"
---

![Pit of Success](/assets/2011/pit-of-success.jpg "Pit of Success")

I'm a **huge** believer in the Pit of Success. Quite a few have written [about](http://blogs.msdn.com/b/brada/archive/2005/10/07/478375.aspx) [it](http://www.codinghorror.com/blog/2007/08/falling-into-the-pit-of-success.html) [before](http://blogs.msdn.com/b/brada/archive/2003/10/02/50420.aspx), though not always in development terms. Put simply, there's two pits you can create in your application through conventions, infrastructure, culture, tools, etc: success and failure. I obviously choose the former.

The Pit of Success is when you and the other developers on your team have to think less about the mundane stuff and when there's only one easy development path to follow. Less thinking about crap = more thinking about business problems = faster software with less bugs. In general, if I see something that's going to be in a lot of classes/pages and it has a decent bit of setup and baggage for it, I instantly picture another developer forgetting to bring all that along when they start new features or refactor. If things break (visually or programatically) when that happens, there's a problem. Same goes for huge chunks of documentation explaining how to use a certain feature elsewhere in the system - time to make it easier to use! Here's a few examples of how we've dug out a Pit of Success on our current project:

- Need to create a new schedule task? [Drop in a class and implement a simple interface.](http://darrell.mozingo.net/2009/09/15/injecting-all-instances-of-a-given-type/) That same principal goes for a slew of other areas - missing information checks for users, HTTP handlers, sample data for geographic areas, etc. You don't have to go hunting down a master class to add these new things to, just create the class and you're golden.
- Security in our system isn't that complex yet, so we're able to consolidate everything in a nice tidy `ActionFilter`. It's applied to our custom controller, and we have a unit test that makes sure all Controllers in the system inherit from that custom one. So by following the rules (on your own or with the help of a broken test), you get security handled for you auto-magically.
- We continuously deploy [with our build server](http://darrell.mozingo.net/2010/09/24/production-deployment-with-your-build-script-part-1/), so it takes care of not only making sure all our unit/integration tests pass, but that all the needed debug settings are flipped, sites are pre-compiled, everything still works once it's live, etc. That saves us from remembering to do all that every time we push live, which is almost constantly these days.
- We completely agree with Chad Myers, Jeremy Miller, et al: if we're working with a static language, make the best of it. Everything in our system is strongly typed, from text box ids in HTML/Javascript/UI tests to URLs and help points. You shouldn't have to remember to go hunting and pecking through the whole system when you want to rename something, just rename it with ReSharper and move on. Same with finding where something is being referenced. The harder it is to rename things, the less they get renamed, and the crustier the system gets.
- We started creating one off modal dialogs to present information to the user. They looked great, but needed a lot of baggage and duplication to do it, so we overrode the default `alert` and `confirm` dialogs with our modal ones. Now there's not only nothing to add to your page to get this, but in most cases you don't even have to remember we're overriding it! There's a forthcoming post that'll cover what we did in more detail.
- We have a unit test that'll scan through all of our test files (which end with \*Fixture), and make sure there's a file name that matches (sans the Fixture part) in the corresponding directory structure in the main assembly. We constantly move files around when refactoring, and forgetting to move or rename their test files is a pain, so this test gently reminds us. Note we don't always follow a one-class-per-fixture setup, but even when we don't, we stick them in a matching fixture class for easy grouping and ReSharper discoverability.

It's worth noting we didn't set out from day one to build all this stuff. Its all grown over time as the project and our stakeholder's needs have changed. We always strive to keep KISS in mind ([even if it is hard](http://darrell.mozingo.net/2008/06/18/kiss-is-hard/)) and not build anything until it's absolutely needed. Don't try to create infrastructure to handle everything for you when a project's in its infancy. Harvest it out later.

There's also exceptions to all of these rules. Is automatic security always the right thing to do? No - if you need highly configurable security, put it out in the open and remember to set it on each request. Don't force things into the infrastructure if they're fighting you and have lots of exception cases. Perhaps there's another route of attack that'll solve the problem and still keep you circling around the Pit of Success.

You'll create your own Pit of Success on your project just by falling into the bigger Pit of Success that is the SOLID principals. The majority of the examples up there were arrived at by just adhering to the Open/Closed Principal or the Single Responsibility Principal. They create a sort of recursive pit, I suppose.

What have you done on your projects to help create a Pit of Success?
