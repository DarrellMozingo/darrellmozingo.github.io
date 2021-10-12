---
title: "Getting started with TDD"
date: "2011-09-16"
categories: 
  - "musings"
  - "testing"
tags: 
  - "musings"
  - "testing"
---

When I first read about TDD and saw all the super simple examples that litter the inter-tubes, like the calculator that does nothing but add and subtract, I thought the whole thing was pretty stupid and its approach to development was too naive. Thankfully I didn't write the practice off - I started trying it, plugging away here and there. One thing I eventually figured out was that TDD is a lot like math. You start out easy (addition/subtraction), and continue building on those fundamentals as you get used to it.

So my suggestion to those starting down the TDD path is: don't brush it off. Start simple. Do the simple calculator, the stack, or the bowling game. Don't start thinking about how to mix in databases, UI's, web servers, and all that other crud with the tests. Yes, these examples are easy, and yes they ignore a lot of stuff you need to use in your daily job, but that's sort of the point. They'll seem weird and contrived at first, but that's OK. It serves a very real purpose. TDD has been around for a good while now, it's not some fad that's going away. People use it and get real value out of it.

The basic practice examples getting you used to the TDD flow - red, green, refactor. That's the whole point of things like [kata's](http://darrell.mozingo.net/code-katas/). Convert that flow into muscle memory. Get it ingrained in your brain, so when you start learning the more advanced practices (DIP, IoC containers, mocking, etc), you'll just be building on that same basic flow. Write a failing test, make it pass, clean up. You don't want to abandon that once you start learning more and going faster.

It seems everyone gets the red-green-refactor part down when they're doing the simple examples, but forget it once they start working on production code. Sure, you don't always know what your code is going to do or look like, but that's why we have the tests. If you can't even begin to imagine how your tests will work, write some throw away spike code. Get it working functionally, then delete it all and start again using TDD. You'll be surprised how it changes.

Good luck with your journey. If you're in the Canton area, don't forget to check out the monthly [Canton Software Craftsmanship](http://www.meetup.com/Canton-Software/) meetup. There are experienced people there that are eager to help you out.
