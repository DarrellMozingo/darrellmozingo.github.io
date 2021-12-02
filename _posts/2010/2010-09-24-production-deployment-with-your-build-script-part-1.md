---
title: "Production deployment with your build script - Part 1"
date: "2010-09-24"
---

Pushing to production with a **script**? Crazy talk, right? Well, maybe not. Sure, there are lots of insane corporate setups out there where a script might not completely work, but for the vast majority of companies out there, this is totally within the realm of possibility. Maybe you want to save some steps when you're deploying, or maybe you want to stop forgetting some of those crazy "best practices" people always talk about (building in release mode? turning off debugging in the web.config? pre-compiling sites?). Whatever the reason, a deployment script is a great solution.

## What it does

Our current deployment script will:

1. Get a completely _clean_ copy of the code base from source control
2. Build it in release mode
3. Run all unit tests, slow/integration tests, and UI tests
4. Switch off debugging in the web.config
5. Pre-compile the site with the ASP.NET compiler
6. Archive the current live site to a backup server, just in case (keeping a few previous versions as well)
7. Deploy the latest copy of our 3rd party tools to each server
8. XCopy deploy the site to each server in our cluster (taking down IIS first and letting our load balancer get users off that server)
9. Visit the site with a browser to do all the first time pre-load reflection stuff (NHibernate, AutoMapper, StructureMap, etc)
    1. It'll actually change its local DNS hosts file to make sure its looking at each server in the cluster too, so that each one is "primed"
10. Make sure our error emails are working by visiting a test URL that throws an exception (therefore creating an error email), then logging into a special email account and making sure that email was received

OK, so this script takes a while to run (with all the tests taking up a majority of the time), but we gain a lot. A single click in TeamCity kicks the whole thing off, and we're guaranteed little to nothing is broken in the system thanks to all the tests (unit, integration, and UI), that there's backup copies if something does happen, and that everything is compiled/configured for production so we're not missing any easy performance gains. I'd say that's a win.

## How it's ran

We don't have have this running in any automatic fashion, but instead run the target by hand from our build server whenever we're ready. Our build server lets us easily schedule the "build" whenever we need to, though, so we can schedule it late at night so we don't disrupt access. Our test servers are also being setup right now, so we'll probably continuously deploy to those when they're ready (twice a day? every check-in?).

## Fail safes

There honestly aren't a whole lot. As we come across certain failures we'll add checks to keep them from cropping back up, but I didn't want to complicate the script with all sorts of edge case checking if it'll never need to worry about them. You need to apply the KISS and YAGNI principals to your build scripts just like your code. We do a few operations in try/catch blocks to make sure servers are kept down if they're not deployed to correctly, or our 3rd party tools get cleaned up properly, etc., but not many.

I'm sure that'll unsettle many of you, but a script like this is going to be highly customized to your environment, and your environment might have a higher chance of certain parts of the script failing, so you'll need to guard against that. I'd highly recommend starting simple and only building out as situations arise though.

## Build server bonuses

We use [TeamCity](http://www.jetbrains.com/teamcity/ab_index.html) as our build server, so I can't speak about the others (CC.NET, Hudson, etc) and how much or little of the following benefits they offer.

The two biggest benefits we get, virtually for free, with using TeamCity to run our deployment script include:

- **Auditing** - you can see who's ran the script, and when
- **Tracking** - it'll show you, for each run, which changes were included in that deployment down to a diff of each file and source control comments
    - It'll also show which changes are pending for the next run: ![Pending Changes in TeamCity](/assets/2010/pendingchanges.png)
    - We don't use a bug tracker that's supported by TeamCity, but theoretically it can link right to each bug fix that's included in each deployment

## What's next?

I'm going to show off parts of our build script and how we handle different situations in the next blog post(s). I'm not sure how many it'll take or how deep I'll go since much of it is situation specific, but I'll definitely get you started on the road with your own.

As a heads up, this will all be written in PowerShell. [We've moved our build script setup to it](http://darrell.mozingo.net/2010/04/02/revisiting-my-automated-build-continuous-integration-setup/) and it's what made this deployment scenario possible.

## Conclusion

Manual deployment sucks. Automated deployment rocks.

If there's any way you can script your deployment (or even parts of it), I'd recommend it in a heart beat. It's a bit bumpy getting it up and running, I won't lie, but it's a **huge** help once it's stable and working. I'll take a look at some of the basic pre-deployment steps we take in the next post.
