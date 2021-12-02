---
title: "The Strategy Pattern and Filtering"
date: "2008-05-16"
---

The strategy pattern is a way to inject algorithms into a chunk of code, or as I like to think of it, basically a way to refactor out multiple lines of code and pass them into a method. Let's look at an example.

Say you have a method with some hard coded strings:

public string WrapWithSingleQuote(string text)
{
	return "'" + text + "'";
}

Now in your next iteration you're asked to wrap any needed text in double quotes and/or parenthesis. Being the awesome developer that you are, you generalize the method like so:

public string WrapWithString(string text, string wrapper)
{
	return wrapper + text + wrapper;
}

See that? The `wrapper` parameter that allowed you to pass whatever you want to wrap the text in? That's a **simplistic and primitive** example of the strategy pattern, but an example nonetheless. Now the method allows you to wrap the given text in whatever characters your heart desires.

Now for a bit more robust and real world example of the pattern. Let's consider the .NET WinForm's TextBox control. This control has auto-complete functionality built into it to, able to suggest completed entries based off the currently entered text from a variety of sources: file system, URL's, a custom source, and more.

A few requirements come in stating that the users want auto-completion for the company text box in their mythical application, so you whip up the following user control:

public partial class CompanyFindTextBox : TextBox
{
	public CompanyFindTextBox()
	{
		InitializeComponent();
		this.AutoCompleteMode = AutoCompleteMode.Suggest;
		this.AutoCompleteSource = AutoCompleteSource.CustomSource;
	}

	public CompanyFindTextBox(IContainer container)
		: this()
	{
		container.Add(this);
	}

	protected override void OnKeyUp(KeyEventArgs e)
	{
		HandleAutoComplete(this.Text.Trim());
		base.OnKeyUp(e);
	}

	private void HandleAutoComplete(string searchText)
	{
		if(searchText != string.Empty)
		{
			using(DatabaseDataContext db = new DatabaseDataContext())
			{
				var matchingCompanies =
					from c in db.Companies
					where c.Name.ToUpper().StartsWith(searchText)
					orderby c.Name
					select c.Name;

				this.AutoCompleteCustomSource.AddRange(matchingCompanies.ToArray());
			}
		}
	}
}

Now, of course, the users want the same functionality on their job, candidate, contractor, and who knows what other text boxes. Looks like a refactoring is in order. Ah, but this time there isn't a simple string to extract as a parameter to fix the problem! You need to generalize your LINQ statement, but each text box type is searching on different databases, fields, etc.

This where the power of the strategy pattern comes in. With it, you can tell the control/method how to go about executing a certain algorithm. Specifically, in C# we usually use delegates (which are nothing more than methods passed into other methods as parameters - or function points from lower level languages). Since C# 3.0 introduced lambdas (simply more concise ways to declare delegates), let's go ahead and use those. Here's a more generalized user control which uses the strategy pattern to pull out the specific database accessing code:

public partial class EntityFindTextBox : TextBox
{
	public Func AutoCompleteStrategy { get; set; }

	public EntityFindTextBox()
	{
		InitializeComponent();
		this.AutoCompleteMode = AutoCompleteMode.Suggest;
		this.AutoCompleteSource = AutoCompleteSource.CustomSource;
	}

	public EntityFindTextBox(IContainer container)
		: this()
	{
		container.Add(this);
	}

	protected override void OnKeyUp(KeyEventArgs e)
	{
		HandleAutoComplete(this.Text.Trim());
		base.OnKeyUp(e);
	}

	private void HandleAutoComplete(string searchText)
	{
		if(AutoCompleteStrategy != null && searchText != string.Empty)
		{
			this.AutoCompleteCustomSource.AddRange(AutoCompleteStrategy(searchText));
		}
	}
}

Notice how this implementation has a function property named `AutoCompleteStrategy`. This says we're looking for a method that takes in a string and returns an array of strings. Now in the `HandleAutoComplete` method, we make sure this isn't null and call it with the text box's contents. This abstracts out the actual database searching algorithm so the new user control can be used with any type of entity the system needs, be it companies, jobs, contractors, etc. That's the strategy pattern in all its glory.

After dropping the new control on a form, you might set it up for a company like so:

txtCompanies.AutoCompleteStrategy = (searchTerm =>
	{
		using(DatabaseDataContext db = new DatabaseDataContext())
		{
			var matchingCompanies =
				from c in db.Companies
				where c.Name.ToUpper().StartsWith(searchText)
				orderby c.Name
				select c.Name;
			return matchingCompanies.ToArray();
		}
	});

Now we're setting the `AutoCompleteStrategy` property to a new lambda expression (think quick method declaration) that's accepting a string parameter named `searchTerm` and using it in the same LINQ query from before, ultimately returning an array of company names which contain whatever was passed in. We could do this for a job text box just as easily, simply swapping out the LINQ statement for a new one (or even XML file searching, a web service call, whatever).

Simple enough, right?
