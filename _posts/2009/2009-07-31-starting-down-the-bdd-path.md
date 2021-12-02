---
title: "Starting Down The BDD Path"
date: "2009-07-31"
---

[Behavior Driven Development](http://dannorth.net/introducing-bdd)'s (BDD) meaning has, until recently, skipped right past me. I'd read about it and used it heavily for a week during [JP's Nothin' But .NET Boot Camp](http://darrell.mozingo.net/2008/12/03/nothin-but-net-training/), but when it came down to really seeing the value in it over the normal bunch of tests per test fixture TDD style, well, I simply didn't. The assertion naming with extension methods (`value.ShouldEqual(10)` vs. `Assert.AreEqual(10, value)`) and sentence-like test names (`Should_calculate_the_sum_of_all_hours_worked` vs `Method_Intial_Expected`) were pretty neat and we've been using them for a while now, but all the rest was lost on me. I mean, a whole class just for one or two assertions? Seemed like a lot.

That was, however, until I realized some of our test `SetUp` methods were literally several pages long. Sure, all of our tests after that were only a half dozen or so lines and it all totally made sense to us when we wrote it, but I found having to go back into these tests to add/modify behavior was proving difficult. I honestly feel the classes and the tests themselves were following the Single Responsibility Principal pretty good, but these few classes just needed a lot of context to set them up before checking the outputs. There wasn't really an easy way around it - either we have the huge setup with shorter tests, or we have more fairly large tests.

Another example of the situation breaking down was a few of our test fixtures, where we'd have the `SetUp` method setup a context (which, again, was a bit large), but each test would slightly the context for its need. The result is needing to look in two places to get the whole picture of the context, and even taking into account some tests that would override certain parts of the context for their own needs. It wasn't pretty.

While trying to figure out which pieces of the setup context applied to the specific test I was modifying, I knew there had to be a better way. While watching a presentation on InfoQ by Jeremy D. Miller, [The Joys and Pains of a Long Lived Codebase](http://www.infoq.com/presentations/Lessons-Learned-Jeremy-Miller), Jeremy talked a bit about how his testing strategy has evolved, and how he'd come to accept BDD after staying away from it. He talked about how important the context of a test was to understanding what it was doing, and how he resorts to copy & paste for parts of the context if he has to in order to keep it easily readable. That part really clicked with me, and I decided to give BDD a honest shot in our current project.

There's plenty of existing BDD frameworks for .NET, including [Machine.Specification](http://github.com/machine/machine.specifications/tree/master), [NBehave](http://nbehave.org/), [Develop With Passion.BDD](http://github.com/developwithpassion/developwithpassion.bdd/tree/master), and [xUnit BDD Extensions](http://code.google.com/p/xunit-bdd-extensions/), but I wanted to keep it simple for now as we integrate it with our existing project, and the other devs on my team had never used the syntax before (and I only had one intense week of exposure), so I didn't want to clutter it up too much for the time being.

In light of that, I created a super simple specification base class:

```csharp
public class SpecBase
{
    [TestFixtureSetUp]
    public void Once_before_any_specification_is_ran()
    {
        infastructure_setup();
        context();
        because();
    }

    protected virtual void infastructure_setup()
    {
    }

    protected virtual void context()
    {
    }

    protected virtual void because()
    {
    }
}
```

I wasn't kidding - there's not much to it at all. The `infastructure_setup` method allows me to create base classes for testing services/controllers/mapper, where I can setup our AutoMocking container and create the system under test as neeeded. For example, here's the base spec class we use for testing our services:

```csharp
public class ServiceSpecBase : SpecBase
    where SERVICE : class, INTERFACE
{
    protected RhinoAutoMocker _serviceMocks;
    protected INTERFACE _service;

    protected override void infastructure_setup()
    {
        _serviceMocks = new RhinoAutoMocker();
        _service = _serviceMocks.ClassUnderTest;
    }
} 
```

The auto mocker (from StructureMap, in this case), just makes an empty dynamic mock for each argument of a given constructor. Our services generally take in a good half dozen objects, so this saves us from having to create them by hand (via something like `var mockRepository = MockRepository.GenerateMock()`). The system under test is then created after the automocker is initialized (I don't generally like the generic "sut" variable name if I can avoid it - you'll see I'm using `_service` for this class as the service is _always_ the system under test for anything using this base class).

Here's an example specification using this new `SpecBase` class:

```csharp
[TestFixture]
public class When_hiring_an_unemployed_person : SpecBase
{
    private readonly Company _company = new Company();
    private readonly Person _person = new Person();

    protected override void context()
    {
        _person.IsEmployed = false;
    }

    protected override void because()
    {
        _company.Hire(_person);
    }

    [Test]
    public void Should_increase_the_number_of_employees_in_the_company_by_one()
    {
        _company.Employees.Count().ShouldEqual(1);
    }

    [Test]
    public void Should_mark_the_person_as_employed()
    {
        _person.IsEmployed.ShouldBeTrue();
    }
}
```

This example doesn't really show how well BDD has started helping reduce the complexity of some of our tests by explicitly naming the context they're running in and making them easier to read. As with every other example on the Internet, this one isn't quite complex enough to really show the benefits, but I hope you at least catch a glimpse of them. I also realize this might not be "correct" BDD styling, and that I should be leveraging share contexts with a base class more (for that mater, I should be using an actual framework for this), but it's serving the purpose well, and it's a simple first step to introducing it to the code base and my team. It'll evolve - always does.

Another great resource I found helpful was [Rob Conery's Kona episode 3](http://blog.wekeroad.com/mvc-storefront/kona-3/), where he explains BDD and converts some tests to using them.
