---
title: "MbUnit's ThreadedRepeat Attribute"
date: "2008-05-30"
---

I ran into some old code in a utility library the other day that would open an XML file on a network share, read a few settings, and close it. This particular piece of code is called quite often in many situations, and often in larger loops, as the calling developer just sees a string being returned and is oblivious to the fact that it's pretty damn expensive to get that string.

So I figured I'd go ahead and implement some quick caching around this by storing the strings in generic static Dictionary, especially as the method itself was static. As I'm still trudging up the steep hill that is the learning curve of Test Driven Development (TDD), I thought I'd get a failing test in there first, then make it pass. An interface for [dependency injection](http://msdn.microsoft.com/en-us/library/aa973811.aspx) and a [mock](http://weblogs.asp.net/stephenwalther/archive/2008/03/22/tdd-introduction-to-rhino-mocks.aspx) or two later and it works. All is good and well in the world.

Unfortunately, it didn't take long for me to realize there were some serious threading issues going on. Whoops. So I started writing up a unit test to fail on the bug before I fixed it, and in the process of creating a bunch of worker threads to hit the method at the same time, I stumbled across a nifty feature in MbUnit: the `ThreadedRepeate` Attribute. Behold, a fake example:

```csharp
[Test]
[ThreadedRepeat(5)]
public void Should_handle_multithreaded_access()
{
    Assert.IsNotEmpty(MyClass.GetExpensiveString());
}
```

Just like the normal `[Repeat(5)]` attribute, which would simply call the test 5 consecutive times back to back, the `[ThreadedRepeat(5)]` attribute will call the test 5 times **in parallel**, firing off a separate thread for each one.

Pretty freakin' nifty if you ask me, and a whole lot easier than having to write your own code to spin up a bunch of worker threads.
