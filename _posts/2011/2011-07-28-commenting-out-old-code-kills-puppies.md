---
title: "Commenting out old code kills puppies"
date: "2011-07-28"
---

There, I said it. Actually, I'm kind of worried that title won't adequately state the intensity of this situation.

This is one of the fundamental reasons we have source control people, so we can go back through a file's history and see the different revisions. Please, for the love of all that is holy, don't comment out old code. **Just delete it!** Feel free to slap your own knuckles with a ruler if you start to think about commenting it. Don't try to recreate a source control system through commented out code. Everyone knows exactly what I'm talking about:

// John Doe - 7/5/2011 - Changed to allow a higher limit.
// dozens of lines of old code....

// John Doe - 7/18/2011 - Changed algorithm slightly.
// dozens of lines of old code....

// random dozen lines of old code with no comment at all

public void ActualCode() { }

Those extra comment chunks are just crap to sift through to get to the real code, extra stuff you'll have to parse to see if it's relevant to the current situation, and creating more false-positives for ReSharper (and I'm guessing other refactoring tools) to pick up when you rename a variable/method that's used inside those commented chunks. That chunk of old code at the bottom without even a hint as to why it's commented out? That's the worst of the worst - someone's going to sit there and stare at it for a good while before they figure out why it was commented out, and we know when the author actually committed this file with that commented out the commit comment was blank too. Awesome.

So anyway, just remember what actually happens the next time you're about to comment out old code and **don't do it**, you'll be doing future programers (and more than likely yourself) a huge service...

![Commenting code kills puppies](/assets/2011/dead_puppies.jpg "Commenting code kills puppies")
