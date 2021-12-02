---
title: "OCP in action"
date: "2010-05-22"
---

### What is OCP?

The [Open/Closed Principle](http://www.objectmentor.com/resources/articles/ocp.pdf) is the O in the nearly infamous [SOLID](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod) set of design principles. The gist of the principle is that any given class should be open for extension, but closed for modification. In more practical terms, you should be able to make most classes do something new or different without actually changing a single line of code within the class itself.

That's simple! Right? Ummm, sure. How, exactly, is a class supposed to be able to do more stuff without being modified? Well, there's lots of ways, if you think about it. I mean, that's sort of what inheritance and polymorphism were made for. There's also other pretty neat ways, too. One of them shows the true beauty of inversion of control, and dependency injection frameworks.

Lets say you have a collection of customers. You need to loop through these people, running a few different checks on them (only preferred customers can carry a negative balance, credit cards on file aren't expired, etc), and adding any resulting errors from those checks to another collection for display later. Nothing too terribly complicated.

### Solving without considering OCP

First we have to load up the customers and send them on through:

private static void Main(string\[\] args)
{
	var customers = get\_customers\_from\_somewhere();

	var check\_runner = new Check\_runner();
	var warnings = check\_runner.run\_checks\_on(customers);

	foreach (var warning in warnings)
	{
		Console.WriteLine(warning);
	}

	Console.ReadLine();
}

private static IEnumerable get\_customers\_from\_somewhere()
{						// database, webservice, whatever.
	return new\[\]
	       	{
	       		new Customer
	       			{
					name = "Joe Smith",
	       				credit\_card = new Credit\_card { is\_valid = true },
	       				balance = 100,
	       				is\_preferred = true
	       			},
	       		new Customer
	       			{
					name = "Nathan Hawes",
	       				credit\_card = new Credit\_card { is\_valid = false },
	       				balance = 0,
	       				is\_preferred = true
	       			},
	       		new Customer
	       			{
					name = "Melinda Plunkett",
	       				credit\_card = new Credit\_card { is\_valid = true },
	       				balance = -100,
	       				is\_preferred = false
	       			}
	       	};
} 

The class running all the checks:

public class Check\_runner
{
	private static readonly IList \_warnings = new List();

	public IEnumerable run\_checks\_on(IEnumerable customers)
	{
		foreach (var customer in customers)
		{
			check\_that\_only\_preferred\_customer\_can\_have\_a\_negative\_balance(customer);
			check\_that\_on\_file\_credit\_card\_is\_not\_expired(customer);
			// additional checks in the future...
		}

		return \_warnings;
	}

	private static void check\_that\_on\_file\_credit\_card\_is\_not\_expired(Customer customer)
	{
		if (customer.credit\_card.is\_valid)
		{
			return;
		}

		\_warnings.Add("Credit card expired for customer: " + customer.name);
	}

	private static void check\_that\_only\_preferred\_customer\_can\_have\_a\_negative\_balance(Customer customer)
	{
		if (customer.is\_preferred || customer.balance >= 0)
		{
			return;
		}

		\_warnings.Add("Negative balance for non preferred customer: " + customer.name);
	}
} 

Pretty standard. Loop through the customers, calling a separate private method for each check you need to preform, adding a message for that check's error to a collection that ultimately gets returned to the caller for display.

### The problems with the first approach

At first blush, this way of running the checks might seem very simple and understandable, but it starts to break down for a few different reasons:

- New checks could get pretty complicated, requiring access to other expensive objects (repositories, web services, file I/O, etc). Even if only one check needed a certain dependency, the whole `Check_runner` class is now burdened with that dependency.
- Every new check requires you to open up the `Check_runner` class and making a modification. Opening a class **and** modifying it? That's pretty much the definition of an OCP violation. Modifying a class always introduces the possibility for regression bugs. No matter how small the possibility or bug, they're there.
- Testing this thing as it gets larger and larger is going to be a pain in the rear. It'll also get much harder, especially if outside dependencies are brought in (having to setup multiple dependencies when the one check you're testing doesn't even use them isn't fun, or clear to read later).

### One possible solution

There's a few different ways to go about fixing this. My suggestion would be to break each check into its own individual class, with the `Check_runner` taking them all in and looping through them, running each as it goes. It sounds a little more black-magicy than it really is. I'm going to show all the code first, then go over the benefits of an approach like this later on. Lets start by defining an interface for these check classes:

public interface ICustomer\_check
{
	string buildWarningFor(Customer customer);
	bool failsFor(Customer customer);
}

Now we can define a single check, which knows when it fails for a given customer, and how to build a warning message for that failure. The check classes for the two checks that are ran above would be a simple conversion of the existing code:

public class Negative\_balance\_check : ICustomer\_check
{
	public string buildWarningFor(Customer customer)
	{
		return "Negative balance for non preferred customer: " + customer.name;
	}

	public bool failsFor(Customer customer)
	{
		return (!customer.is\_preferred && customer.balance < 0);
	}
}

public class Expired\_credit\_card\_check : ICustomer\_check
{
	public string buildWarningFor(Customer customer)
	{
		return "Credit card expired for customer: " + customer.name;
	}

	public bool failsFor(Customer customer)
	{
		return (customer.credit\_card.is\_valid == false);
	}
}

Now the `Check_runner` just has to loop through all of the `ICustomer_check` implementations and run them:

public class Check\_runner
{
	private readonly IEnumerable \_customer\_checks;

	public Check\_runner(IEnumerable customerChecks)
	{
		\_customer\_checks = customerChecks;
	}

	public IEnumerable run\_checks\_on(IEnumerable customers)
	{
		var warnings = new List();

		foreach (var customer in customers)
		{
			foreach (var check in \_customer\_checks)
			{
				if (check.failsFor(customer))
				{
					warnings.Add(check.buildWarningFor(customer));
				}
			}
		}

		return warnings;
	}
} 

Again, pretty simple and focused. Where does that enumeration of `ICustomer_check` implementations come from though? The missing key: our dependency injection framework. I'll use [StructureMap](http://structuremap.github.com/structuremap/index.html) for this example. After downloading that and referencing the assembly, we'll modify our `main` method to set it up:

private static void Main(string\[\] args)
{
	ObjectFactory.Initialize(y => y.Scan(x =>
	                                     {
	                                     	x.TheCallingAssembly();
						x.AddAllTypesOf();
	                                     }));

	var customers = get\_customers\_from\_somewhere();

	var check\_runner = ObjectFactory.GetInstance();
	var warnings = check\_runner.run\_checks\_on(customers);

	foreach (var warning in warnings)
	{
		Console.WriteLine(warning);
	}

	Console.ReadLine();
} 

We fire up StructureMap, telling it to scan the calling assembly and find all implementations of `ICustomer_check`. When we ask for an instance of `Check_runner`, StructureMap knows to provide all the implementations it found of `ICustomer_check` to `Check_runner`'s constructor argument in a list. Since this is the [outer most edge of the application](http://darrell.mozingo.net/2009/12/23/my-attempt-at-demystifying-dependency-injection/), we'll interact with the dependency injection framework here instead of inside `Check_runner`.

### Benefits

So perhaps other than the StructureMap related code (if you don't already know the basics of it), nothing I've done here has really complicated the system. It's still a few primitive classes working together in a fairly obvious way. What benefits do we gain from these changes though?

- Each piece of the system now has a single, specific responsibility. You can look at each check and quickly figure out what its purpose is. The runner simply takes in all the checks and runs them (funny how its name now follows its responsibility too).
- The check classes can now take in their own dependencies. Need an `ICustomerRepository` or `ICustomerAccountService` for something? List it in the constructor. Each check is getting pulled from the container, so their dependencies will get filled as well. Checks will also only take on what each one needs, as opposed to requiring dependencies they might not have before.
- With decreased responsibilities, each piece now becomes much easier to test. Supply a list of dummy checks and dummy customer to make sure the runner is doing its job. Same for the checks themselves. In fact, too many tests for a class is a smell that class is doing too much in the first place.
- The point of the article: **no more OCP violations**! Future requirements for different kinds of checks now become almost mind numbingly easy. Slap in a new class and implement `ICustomer_check`. That's it - the container will take care of the rest. Virtually no possibility of introducing a regression bug and messing up one of the other checks by adding a new one.

### Conclusion

One thing to remember when looking for OCP violations in your code base is that "closed for modifications" should be taken within context. Fixing bugs, adding complete new features, etc, will obviously require modifications to something. You're not going to create every class in your system and never touch them again. Within reason, you should apply the Open-Closed Principle to your code as much as possible. It makes it simpler to understand on the micro and macro level once your familiar with some of the more common patterns, and it helps reduce the possibility of introducing bugs from future additions.
