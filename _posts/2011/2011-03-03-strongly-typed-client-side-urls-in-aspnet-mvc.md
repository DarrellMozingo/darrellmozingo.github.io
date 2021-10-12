---
title: "Strongly typed client-side URLs in ASP.NET MVC"
date: "2011-03-03"
categories: 
  - "aspnet-mvc"
tags: 
  - "aspnet-mvc"
---

## The problem

We try to strongly type everything in our MVC project, especially URLs. It's pretty easy to do using all the build in functionality of ASP.NET MVC along with some lovin' from [MvcContrib](http://mvccontrib.codeplex.com/), but the one situation we've always had problems with was client-side javascript. If it's a basic action call with no arguments, we're golden (using `<%= Html.BuildUrlFromExpression(x => x.MyAction()) %>`). It gets tricky when we have a slightly more complex action though:

\[AcceptAjax\]
public string DoSomethingComplex(int id, string accountNumber, int amount)
{
	return string.Format("id = {0}, accountNumber = {1}, amount = {2}", id, accountNumber, amount);
}

If we wanted to do an AJAX call to this bad boy, we'd unfortunately have to resort to string concatenation to build up the URL:

// get these values from form fields or something...
var id = 3;
var accountNumber = "123456";
var amount = 325;

var ugly\_url = "/Home/DoSomethingComplex/" + id + "?accountNumber=" + accountNumber + "&amount=" + amount;

Booo creepy magic strings. Renaming the action name or any of the parameter names left us relying on either ReSharper's ability to catch the change, manual search and replace, or hoping we had a UI test hitting the page to catch it. Basically, nothing too terribly reliable to keep our app in working order. The more you worry about small changes breaking your application, the less likely you are to refactor it. The less you refactor, the faster your application degrades into nastiness (code not matching up with current business conventions, etc), and the slower you are to respond to change. Not cool.

## The solution

Before I go further, I should probably throw up this **disclaimer:** We use the default routes for everything. The application is behind a login page, and we have no need for fancy SEO friendly URLs, so the solution I'm about to show caters to that scenario. If your application leverages custom routes, you'll either have to tweak this solution to your needs, or figure out something else. Sorry.

### In a nutshell

You'll end up being able to build the URL above like this:

var beautiful\_url = "<%= Html.UrlTemplate(x => x.DoSomethingComplex(Any.Arg, Any.Arg, Any.Arg)) %>"
						.substitute(id, accountNumber, amount); 

This'll produce a URL template like `"/Home/DoSomethingComplex/{0}?accountNumber={1}&amount={2}"` on the client. You then plug in the template's holes with your client-side values. Pretty simple, really.

There's a few server and client-side pieces to this puzzle.

### Server-side portion

The heart of this solution (and the biggest chuck of code) is the actual building of the URL template.

private static bool onlyTakesInSingleViewModel(string\[\] routeValues)
{
	return (routeValues.Length == 3 && routeValues\[2\].ToLower().EndsWith("viewmodel"));
}

public static string UrlTemplateFor(Expression\> action) where CONTROLLER : Controller
{
	var routeValues = Microsoft.Web.Mvc.Internal.ExpressionHelper.GetRouteValuesFromExpression(action);
	var actionPath = string.Format("/{0}/{1}", routeValues\["Controller"\], routeValues\["Action"\]);

	if (routeValues.Count > 2)
	{
		var routeValuesKeysArray = routeValues.Keys.ToArray();

		if (onlyTakesInSingleViewModel(routeValuesKeysArray))
		{
			return actionPath;
		}

		if (routeValuesKeysArray\[2\] == "id")
		{
			actionPath += "/{0}";
		}
		else
		{
			actionPath += "?" + routeValuesKeysArray\[2\] + "={0}&";
		}

		var placeHolderCounter = 1;

		if (routeValues.Count > 3)
		{
			if (actionPath.Contains("?") == false)
			{
				actionPath += "?";
			}

			for (var i = 3; i < routeValues.Count; i++)
			{
				actionPath += routeValuesKeysArray\[i\] + "={" + placeHolderCounter++ + "}&";
			}
		}

		actionPath = actionPath.TrimEnd('&');
	}

	return actionPath;
} 

This method (which has unit tests in the sample project provided at the end of the post) basically builds up the URL template by leaning on a method inside the MVC Futures assembly to get the controller, action, and parameter names. This is the portion you'd have to tweak if you use different routing rules.

Then it's simply a matter of wrapping the UrlBuilder call with an HTML Helper extension method:

public static class HtmlHelperExtensions
{
	public static string UrlTemplate(this HtmlHelper htmlHelper, Expression\> action) where CONTROLLER : Controller
	{
		return UrlBuilder.UrlTemplateFor(action);
	}
} 

Looking at the example of using this method above, you can see all the parameters in the `UrlTemplate` call replaced with calls to an `Any` class. Technically speaking, whatever values you put in the expression passed to `UrlTemplate` will be ignored. You can put in nulls for references & nullable types, 0's for value types, etc. I decided to drive home the point to anyone looking at the code that we _don't care_ what value they provide by making a very slim class that provides the default value for whatever type is needed:

public class Any {
	public static T Arg
	{
		get { return default(T); }
	}
} 

It drives home that whole not caring point pretty well, but it's also a bit wordy, especially if there's 3 or 4 parameters that need specified. You can omit using the `Any` class and just give dummy values if you want. Your choice.

### Client-side portion

There's not a whole lot to the client-side portion. Basically a very simple version of the .NET Framework's `string.Format` method (which you'll probably want to put in an external js file and reference as needed). It's written as an extension on the string type to make reading the final product a bit more natural:

String.prototype.replaceAll = function (patternToFind, replacementString) {
	return this.replace(new RegExp(patternToFind, "gi"), replacementString);
}

String.prototype.substitute = function () {
	var formatted = this;

	for(var i = 0; i < arguments.length; i++) {
		formatted = formatted.replaceAll("\\\\{" + i + "\\\\}", arguments\[i\]);
	}

	return formatted;
}

That's it. Using all these pieces together gives us the final product:

var beautiful\_url = "<%= Html.UrlTemplate(x => x.DoSomethingComplex(Any.Arg, Any.Arg, Any.Arg)) %>"
						.substitute(id, accountNumber, amount); 

You can provide the values for the URL template from client-side code, or from your ViewModel by just outputting the value in the proper spot (i.e. use `<%= Model.Id %>` rather than the client-side `id` property). This setup has proven very helpful and quite versatile for us so far.

## Potential pitfalls

Having shown all this, there are a few potential pitfalls you need to be aware of:

1. The building of the URL template is pretty rudimentary. It also relies on a method inside the MVC Futures assembly, which I haven't checked to see if it even exists in MVC3, let alone in future versions. I couldn't find anything in the main MVC assembly or MvcContrib to fill my needs. Having said that, it's isolated to one location and we could always get the controller, action, and parameter names by hand with a little expression tree walking, especially since we're already limited to the default route setup and therefore know where they'd be with pretty good certainty.
2. This allows you to rename controller, action, and parameter names with complete confidence. However, if you switch parameter positions around, especially if they're the same type, you might run into a problem. In my usage example above, for instance, switching the `id` and `amount` parameters around would still compile and technically run, but the Javascript would continue passing the `id` in for the `amount` parameter and vise-versa. You don't usually switch around parameters for no reason, but it's worth noting, as you'd have to do a find usages and make sure all the calls are updated properly. At least you'd be able to find all the usages with certainty, though.

## Conclusion

Next time you find yourself needing to concatenate strings on the client-side to call URLs, think about using this technique (or something similar) to keep it all strongly typed. If you're going to work in a static language like C#, you might as well leverage it as much as possible. Strong typing lets you refactor with full confidence that no references to the rename will get left behind by mistake.

You can grab a copy of the source code for the project [right here](https://github.com/DarrellMozingo/Blog/tree/master/StronglyTypedMvcClientSideUrls) (built with MVC2). Give it a spin and let me know if you have any problems, or if you know a better way to do this without building the URLs by hand.
