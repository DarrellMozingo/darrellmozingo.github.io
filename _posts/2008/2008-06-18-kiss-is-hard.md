---
title: "KISS Is Hard"
date: "2008-06-18"
categories: 
  - "testing"
tags: 
  - "testing"
---

![KISS Logo](/assets/2008/kisslogo.png "KISS Logo")No, I'm not referring to [the band](http://en.wikipedia.org/wiki/Kiss_(band)), but [the KISS principle](http://en.wikipedia.org/wiki/KISS_principle) (Keep It Simple, Stupid), and its close cousin, the idea of [YAGNI](http://en.wikipedia.org/wiki/You_Ain%27t_Gonna_Need_It) (You Ain't Gonna Need It).

They're hard. Sure, they might seem easy at first glance, but they are both deceptively hard. This is especially true if you have any sort of background in your problem domain, and let's face it, most of us do if we're writing the usual problem tracking or invoice tracking applications. You know what I'm talking about: you start with an empty solution in front of you, tasked with creating your companies next, say, customer management system, and you start walking through the new application in your mind.

"Well," you say to yourself, "I'm going to need a Customer object, a customer repository to store the object, a Job object, maybe an invoice object, tables and repositories for each of those, and I'm sure they're going to ask for filtering next, so I might as well save myself the time and throw in a few specification and filtering classes." This process goes on for a while and before you know if you've pumped out a few dozen classes and added all sorts of neat functionality.

Odds are, though, some, if not most, of those classes will end up either going unused or be _heavily_ modified before the features are finished. Hence the above two principles (or ideas or whatever you want to call them). Wait until the last **reasonable** moment to add additional complexity to your application, but do so with a bit of judgment. Sometimes you simply know you're going to need something, like a database back-end, so don't start with text files just for the sake of keeping it simple. For the vast majority of decisions, though, you should use the simplest implementation until you find justifiable evidence that proves you need something more complex.

KISS and YAGNI go hand-in-hand with test driven development. Write your test, then write the simplest code you can to make the test pass. The code can always be refactored later to extract classes, interfaces, patterns, et cetera. I understand that your training as a developer is hard to resist - that urge to create things you're pretty sure you'll need while you're working in a particular area. Resist it.

I'm starting on a new project at work, and it's a particularly large project at that. It lends itself incredibly well to TDD, and so far the YAGNI ideal and TDD practice has proven themselves very versatile and helpful. As we're unsure on how to split up the work load this early in the project, we're working together (3 developers) on a machine with a projector. We're **constantly** reminding each other not to over complicate things and toss in hooks and features we might someday need. Trust me, I literally mean almost every feature we add we're reminding each other to go with the simpler implementation, because it really is that hard to overcome. We're trying to stick to today, not tomorrow, by making it simple, making it fast, and making it easy to understand. I think we're doing a great job of it so far.

We're also well assured that the dozens and dozens of unit tests we have, along with the multitude of user generated acceptance/integration tests, will give us the safety net we need to refactor and introduce new features as we move forward. I, for one, am quite looking forward to what comes next.
