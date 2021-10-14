---
title: "When's the best time to write tests?"
date: "2009-08-19"
categories: 
  - "testing"
tags: 
  - "testing"
---

I often hear people get apathetic about testing, especially on brown field applications. "There's already so much untested code," they say, or "we'll get to it when we start this next portion of the application, we swear." Obviously this gets put off to the start of the next feature, and the next, and the next, ad infinitum. All the while, there's more untested code piling up, helping their first argument, and the code base on a whole is becoming more rigid and jumbled up, almost guaranteeing they'll never have the time to untangle it and add tests after the fact.

Fear not, though, I have the perfect answer! It's actually a simple, definitive, mathematical proof. For a given application **A**, that has **x** lines of code and has been in development for **n** months with a client base of **C** clients, we derive the best time to start writing tests, **wt** as thus:

![Right time to test equation](/assets/2009/testing_time_equation.png "Right time to test equation")

What'd I say? Simple.

Ok, ok, a little sarcastic. Seriously though, there's never a better time then right now, this very moment. Even a huge UI & database interacting integration test using something like [WaitN](http://watin.sourceforge.net/). It's better than nothing. Like I said, the longer you wait, the more untested code you accumulate, the harder/scary it is to change things, and the more code you'll need to eventually test. Even if it's only a portion of your app that you've put off testing (for us, it'd be the UI and controllers/services) - just do it. They might not look pretty at first, but you can refine that later. They'll expose pain points that need refactoring in the classes you're testing, and the tests themselves might even require some object builders, helper methods, or base test classes, but it's all worth it.

Don't wait for tomorrow, the next iteration, or the next big version. Do it **right now!**
