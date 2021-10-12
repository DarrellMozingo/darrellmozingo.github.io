---
title: "In-memory view rendering with Spark"
date: "2010-01-28"
categories: 
  - "aspnet-mvc"
tags: 
  - "aspnet-mvc"
---

We recently had a requirement to start printing some documents from our web application. These documents required some very precise positioning of a few elements that can't be achieved with standard web browser printing capabilities. After weighing our options, we decided to go the generated PDF route. There's quite a few HTML -> PDF generation options out there, but they almost all require you to either point them at an HTML document on disk or feed them a string of your HTML. Options, options, options. Yea, I think we'll take the string route, thanks.

Turns out (surprise surprise!) that getting your rendered HTML from the Web Forms view engine that's used by default in ASP.NET MVC isn't so, um, easy. It likes its HttpContext with a side of HttpSession, and that's just the appetizer. Kind of hard to get that to it in-memory without firing up a whole other server instance. Thankfully, it turns out our good friend [Spark](http://sparkviewengine.com/) makes rendering a view to an HTML string in-memory incredibly easy.

How? Glad you asked:

public static string RenderViewToHtml(string viewPathAndName, VIEW\_MODEL viewModel) where VIEW\_MODEL : class
{
	var templatesLocation = new FileSystemViewFolder(HttpContext.Current.Server.MapPath("~/Views"));
	var viewEngine = new SparkViewEngine(BuildSparkSettings()) { ViewFolder = templatesLocation };
	var descriptor = new SparkViewDescriptor().AddTemplate(viewPathAndName);

	var view = (SparkView)viewEngine.CreateInstance(descriptor);
	view.ViewData = new ViewDataDictionary(viewModel);

	string html;

	using (var writer = new StringWriter())
	{
		view.RenderView(writer);
		html = writer.ToString();
	}

	return html;
}

public static SparkSettings BuildSparkSettings()
{
	return new SparkSettings()
		.AddNamespace("System.Linq")
		.AddNamespace("System.Web.Mvc")
		.AddNamespace("Microsoft.Web.Mvc")
		.SetPageBaseType(typeof(SparkView))
		.SetDebug(false);
} 

Simply pass in a path to your view (minus the `/View` part) along with a view model and you'll get back a string full of rendered HTML goodness. The `BuildSparkSettings()` method can shared with the application startup code where you create and add Spark as an ASP.NET MVC view engine. Here's a sample call:

It's worth noting that Spark and WebForms views can happily live side-by-side in a single project, too. We use this for only a hand full of pages and the rest are still using the WebForms view engine. Plus, converting them to Spark was as simple as renaming the file and adding a view model declaration at the top of the page (along the lines of `<viewdata model="OurNeatViewModel" />`). Granted these pages aren't really leveraging the power and beauty of Spark, but they still run and with virtually no modifications.

Will we be converting all of our views to Spark and using some of it's neat-o features and conventions? Probably not any time soon. While lots of folks are apparently feeling lots of pain with Web Forms views, we're not (well, other than this whole in-memory rendered affair anyway). So there really isn't much gain for us from switching over. I also really don't like the non-strongly-typedness of their views, which already bit me a few times just on the hand full of views we're using it for. Perhaps that might get fixed or ReSharper will step up with support for it.

Spark does have a lot of neat features though. It's ability to easily render a full view to an HTML string in-memory was just the first thing we needed from it. I'm sure there'll be more in the future.
