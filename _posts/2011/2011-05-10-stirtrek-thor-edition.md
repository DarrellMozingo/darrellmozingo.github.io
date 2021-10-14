---
title: "StirTrek: Thor Edition"
date: "2011-05-10"
categories: 
  - "events"
tags: 
  - "events"
---

![thor](/assets/2011/thor.png "thor")

I went with a few co-workers to [Stir Trek](http://stirtrek.com) this past Friday. They've put an event on for the past two years, but this was the first one I've been to. It was an excellent event. Good talks, very well planned out, and a pretty decent movie to boot! Here's the talks I went to:

- **Are You Satisfied With Your Tests?** ([Jim Weirich](http://onestepback.org/)) - Jim gave a good overview of testing (do it, make them fast, etc.) and tips (clear naming, refactoring, when to combine/split tests, etc.). Overall pretty good. My co-workers gave a laugh as I harp on many of these points all the time already.
- **Node.js - Show and Tell** ([Leon Gersing](http://twitter.com/rubybuddha)) - A neat explanation of this async javascript framework. Leon gave a demo of a simple client/server chat setup, and a run down of a slightly more advanced website. I hadn't seen any Node.js stuff other than very broad overview articles, so it was cool to get the explanation of when/where to use it, and look at working examples. Unfortunately he ran out of time before getting to the testing examples, but I guess that give me a place to start in my personal learning.
- **Testable Object-Oriented JavaScript** ([Jon Kruger](http://jonkruger.com/blog/)) - One of the better talks I attended, as it tilted more towards the intermediate/advanced level than others. Jon walked through a live demo of building out a simple Twitter client by test-driving the javascript with [Jasmine](http://pivotal.github.com/jasmine/) to run the tests, and his custom [JS View](https://github.com/JonKruger/JSView/) framework to fake out the HTML. Pretty darn neat, and I'm looking forward to digging into it a bit more for our new features, as they'll be far more client-side dependent than previous ones, and we haven't gotten to the UI part just yet.
- **Getting Started with User Research: DIY Quick Course** ([Carol Smith](http://www.askauser.com/)) - Carol went over the basics of user research via interviews, observance, and card sorting, which helps you structure you application's layout to match how users would expect it to be. Very helpful for a high-level overview talk, and gave me a few tips to pursue with getting information on our application.
- **Testing Web Applications with Selenium** ([Jim Holmes](http://www.frazzleddad.com)) - I was definitely looking forward to this talk the most, and it didn't disappoint. We use Watin at work and have only dabbled once in Selenium, so seeing how he structures his tests was helpful. Unfortunately he spent 80% of the time going over a basic UI test and overview of Selenium. By time he got to the lessons he's learned from running 14,000 some-odd UI tests, he ran out of time. Booo. It was actually quite comical... "OK, now the most important things you need to know... I'm out of time, aren't I?". A few of the database/browser handling tips will come in handy for our UI test suite though, and I'm looking forward to giving them a shot.

I really wanted to hit up the GitHub talk, executable requirements, and a mobile talk or two, but I guess there's always next year. Overall it was an excellent conference, and the peeps that ran it did a great job. Thor itself turned out to be pretty decent flick, too.

They already scheduled next year's version in May: StirTrek Avenger's Edition. Looking forward to it!
