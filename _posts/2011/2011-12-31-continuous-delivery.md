---
title: "Continuous Delivery"
date: "2011-12-31"
---

I recently finished reading [Continuous Delivery](http://www.amazon.com/gp/product/0321601912). It's an excellent book that manages to straddle that "keep it broad to help lots of people yet specific enough to actually give value" line pretty well. It covers testing strategies, process management, deployment strategies, and more.

At my former job we had a PowerShell script that would handle our deployment and related tasks. Each type of build - commit, nightly, push, etc. - all worked off its own artifacts that it created right then, duplicating any compilation, testing, or pre-compiling tasks. That eats up a lot of time. Here's a list of posts where I covered how that script generally works:

- [Part 1](http://darrell.mozingo.net/2010/09/24/production-deployment-with-your-build-script-part-1/)
- [Part 2](http://darrell.mozingo.net/2010/11/12/production-deployment-with-your-build-script-part-2/)
- [Part 3](http://darrell.mozingo.net/2010/11/24/production-deployment-with-your-build-script-part-3/)
- [Part 4](http://darrell.mozingo.net/2010/12/03/production-deployment-with-your-build-script-part-4/)

The book talks about creating a single set of artifacts from the first commit build, and passing those same artifacts through the pipeline of UI tests, acceptance tests, manual testing, and finally deployment. I really like that idea, as it cuts down on unnecessary rework, and gives you more confidence that this one set of artifacts are truly ready to go live. Sure, the tasks could call the same function to compile the source or run unit tests, so it was effectively the same, but there could have been slight differences where the assemblies produced from the commit build were slightly different than those in the push build.

I also like how they mention getting automation in your project from day one if you're lucky enough to work on a green-field app. I've worked on production deployment scripts for legacy apps and for ones that weren't production yet, but still a year or so old. The newer an app is and the less baggage it has, the easier it is to get started, and getting started is the hardest part. Once you have a script that just compiles and copies files, you're 90% of the way there. You can tweak things and add rollback functionality later, but the meat of what's needed is there.

However you slice it, **you have to automate your deployments**. If you're still copying files out by hand, you're flat out doing it wrong. In the age of PowerShell, there's really no excuse to not automate your line of business app deployment. The faster deliveries, more transparency, and increased confidence that automation gives you can only lead to one place: [the pit of success](http://darrell.mozingo.net/2011/06/26/the-pit-of-success/), and that's a good place to be.
