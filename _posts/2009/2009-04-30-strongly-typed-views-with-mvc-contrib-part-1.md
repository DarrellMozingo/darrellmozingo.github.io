--- title: "Strongly Typed Views With Mvc Contrib - Part 1"
date: "2009-04-30"
---

Out of the box, ASP.NET MVC uses weakly typed extension methods to generate various HTML elements (inputs, check boxes, select lists, etc). By weakly typed I mean they require strings, which are actually strings based on the properties of your view model. For instance, given this view model:

```csharp
public class OrderViewModel
{
    public int Quantity { get; set; }
    public bool ApplyDiscount { get; set; }
}
```

You'd generate an input box for the quantity, using the standard HTML helper extensions, like so:

`<%= Html.TextBox("Quantity") %>`

Ew, strings. That's so .NET 1.1, right? With .NET 3 we get Expressions and lambdas. Now lambdas are just more concise ways to define delegates (methods you can pass around as variables), so they're nothing really new new. Expressions, for the purposes of this post, allow you to specify, in a compile safe manner, which property you want to use for something, which can then be parsed during run-time to get the property's string name (suffice to say Expressions can do much more and form the foundation for LINQ To SQL). For instance, what if, instead of using the above TextBox method for the quantity product, we could do this:

`<%= Html.TextBox(x => x.Quantity) %>`

Rest assured it'd produce the same HTML in the end while giving us the type safety we're looking for. What do I mean by type safety? I mean you can preform a rename refactoring on Quantity and you'd also rename the usage in the view (Resharper will actually do most rename refactorings on strings too, but it's not 100% reliable - it's a guess at best). That means less chance of something breaking (especially something you won't find out about until runtime when your customers are in there), which means high quality, which is just cool.

OK, so we're aware of what a strongly typed view would look like and the benefits of it. How can we do it? Well, we can roll our own (which has been done in a few places very nicely but is quite a bit of work), we can use the basic ones provided in the MVC Futures assembly (which provide pretty much the same functionality, look, and feel as the existing ones in System.Web.Mvc but with the strong typed goodness), or we can use the ones included in the open source [MVC Contrib](http://www.codeplex.com/MVCContrib) project. This is a project that provides a lot of really nice "glue" to help out with any ASP.NET MVC project, taking advantage of many of the extensibility points built into the framework already.

Unfortunately, it looks like the latest release download doesn't include the Fluent Html assembly (fluent html is what most people use when referring to this strong typed HTML tag output because it's a "fluent" interface, as you'll see shortly). You'll need to build the project from source, so grab the latest copy at [http://mvccontrib.googlecode.com/svn/trunk](http://mvccontrib.googlecode.com/svn/trunk), then run the _ClickToBuild_ batch file in the root folder. It'll do it's thing, then when it's finished you'll need to grab the following files in the newly created **buildnet-3.5.win32-MVCContrib-release** folder:

- MvcContrib.dll
- MvcContrib.pdb (optional - provides line numbers if you need to debug anything)
- MvcContrib.xml (method and parameter comments)
- MvcContrib.FluentHtml.dll
- MvcContrib.FluentHtml.pdb
- MvcContrib.FluentHtml.xml

In the next part I'll go over the basic usage of the library, then in the third part I'll cover some of the cooler aspects, like tying it into validation and other things.

[Part 2](http://darrell.mozingo.net/2009/05/23/strongly-typed-views-with-mvc-contrib-part-2/) and [Part 3](http://darrell.mozingo.net/2009/06/20/strongly-typed-views-with-mvc-contrib-part-3/).
