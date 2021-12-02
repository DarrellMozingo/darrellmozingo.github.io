---
title: "Strongly Typed Views With Mvc Contrib - Part 3"
date: "2009-06-20"
---

[Part 1](http://darrell.mozingo.net/2009/04/30/strongly-typed-views-with-mvc-contrib-part-1/) discussed the benefits of a strongly typed view and [part 2](http://darrell.mozingo.net/2009/05/23/strongly-typed-views-with-mvc-contrib-part-2/) went through the typical usage of the Mvc Contrib project's fluent HTML library. Now we'll take a look at a neater usage for it - validation.

Each extension in the Mvc Contrib fluent HTML library takes "behaviors" into account, applying all known behaviors first when rendering themselves to strings. These behaviors are defined by the following interface:

public interface IMemberBehavior : IBehaviorMarker
{
	void Execute(IMemberElement element);
}

Very simple. The interface defines a single method that takes in an `IMemberElement`, which provides the LINQ expression being used to render the control and also inherits from the `IElement` interface, which is the base interface all the HTML extensions end up deriving from:

public interface IElement
{
	/// /// TagBuilder object used to generate HTML.
	/// 
	TagBuilder Builder { get; }

	/// /// How the tag should be closed.
	/// 
	TagRenderMode TagRenderMode { get; }

	/// /// Set the value of the specified attribute.
	/// 
	/// The name of the attribute.
	/// The value of the attribute.
	void SetAttr(string name, object value);

	/// /// Set the value of the specified attribute.
	/// 
	/// The name of the attribute.
	string GetAttr(string name);

	/// /// Remove an attribute.
	/// 
	/// The name of the attribute to remove.
	void RemoveAttr(string name);
	
	/// /// The text for the label rendered before the element.
	/// 
	string LabelBeforeText { get; set; }

	/// /// The text for the label rendered after the element.
	/// 
	string LabelAfterText { get; set; }

	/// /// The class for labels rendered before or after the element.
	/// 
	string LabelClass { get; set; }
}

This allows a behavior to do basic modifications to an element, including changing HTML attributes and adding text before/after the element. More advanced operations can be done by breaking polymorphism and checking what type the `IElement` parameter actually is. Mvc Contrib bundles in one behavior by default, the `ValidationBehavior`, which checks ASP.NET MVC's ModelState for any possible errors to display, effectively making the Mvc Contrib's HTML helpers act the same as the built in ASP.NET MVC's when it comes to error handling.

You'll notice above I said each HTML extension takes all "known" behaviors into account when rendering themselves to strings. So how do the extensions learn about these behaviors? Simply put, the `ModelViewPage` we had our view page inherit from takes an array of them in one of its constructor overloads. The default constructor only loads the ValidationBehavior. All we need to do is create our own view base page, inherit from the ModelViewPage, and pass in our own behaviors like so:

public class FluentViewPage : ModelViewPage where T : class
{
	public FluentViewPage()
		: base(new MaxLengthBehavior())
	{
	}
} 

There's really not much to the above behavior, either. Simply have it inherit from `IMemberBehavior` and you're good to go. Here it is in all its entirety:

public class MaxLengthBehavior : IMemberBehavior
{
	public void Execute(IMemberElement element)
	{
		var attribute = new MemberBehaviorHelper().GetAttribute(element);

		if(attribute != null && element is ISupportsMaxLength)
		{
			element.SetAttr(HtmlAttribute.MaxLength, attribute.MaximumLength);
		}
	}
} 

The passed in member element knows the property specified in the `this.TextBox(x => x.Name)` call (Name, in this case), as well as all the elements defined on the IElement interface above. We take that and use a helper class to pull the desired attribute off the passed in property. If it has the attribute we're looking for, and supports setting a maximum length (checking using the `ISupportsMaxLength` marker interface so we're not trying to somehow set the max length on a checkbox, for example), we set the max length HTML attribute on the element. Pretty simple, but again, this is only really scratching the surface of what can be done with these behaviors.

So with all this in place, simply slap the `StringLenght` attribute on any needed view model properties. For instance, if we modify the CustomerViewModel's name property like this:

\[StringLength(30)\]
public string Name { get; set; }

The outputted HTML would be:

Neat, huh? In our current project, we're using these to automatically denote required fields, and in conjunction with [xVal](http://www.codeplex.com/xval), require those fields complete with client side checks. All from a few simple attributes.
