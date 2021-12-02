---
title: "ELMAH with ASP.NET MVC"
date: "2009-02-19"
---

We finally got to the point of needing some error reporting in our new application. We'd read about [ELMAH](http://code.google.com/p/elmah/) before and assumed we'd use that, but that was a while before we decided to go with the ASP.NET MVC framework instead of the traditional WebForms.

I was a little worried we'd hit some road block using ELMAH in conjunction with ASP.NET MVC, but it actually works out of the box without a hitch. ELMAH has a built in module for displaying any logged errors, and is accessible (by default) via `http://localhost/elmah.axd`. The latest releases of ASP.NET MVC automatically ignore routes with a .axd extension, though I'm not sure for how many releases they've been including that, so earlier releases will have a problem getting to that URL.

Simone Busoli wrote up an [excellent article](http://dotnetslackers.com/articles/aspnet/ErrorLoggingModulesAndHandlers.aspx) on the most important features of ELMAH and getting it setup. A must read if you're going to implement this solution.

Here's a quick run-down of the steps we went through for our application, though (using SQL logging & emailing the developers whenever an exception is logged):

1. Reference the ELMAH.dll assembly in your project.
2. Define the section group in your web.config:
    
3. Define the needed ELMAH section elements, along with their related SQL connection string, in your web.config (we're only allowing access to the error page via the local host):
    
4. Add the follow handler to the section that'll allow you to view the errors (I used the path errors.axd instead of the default elmah.axd, just because I hate using default URL like that in case we ever allow this on something other than localhost w/a restricted login):
    
5. Add the following modules to the section, which will actually catch exceptions for logging to SQL and emailing out:
    
6. (Optional) Add the following methods to your `Global.asax`, which will filter all exceptions thrown on the local host and ignore them (so developing on your local machine won't keep emailing everyone else, which, trust me, gets old pretty damn quick):
    
    public void errorLog\_Filtering(object sender, ExceptionFilterEventArgs e)
    {
        if(ErrorFiltering.Filter(new HttpContextWrapper(e.Context)))
        {
            e.Dismiss();
        }
    }
    
    public void errorMail\_Filtering(object sender, ExceptionFilterEventArgs e)
    {
        if(ErrorFiltering.Filter(new HttpContextWrapper(e.Context)))
        {
            e.Dismiss();
        }
    }
    
    and in another file somewhere (note the HttpContextWrapper in both of these pieces of code, for easier testing):
    
    public class ErrorFiltering
    {
        public static bool Filter(HttpContextWrapper httpContextWrapper)
        {
            return httpContextWrapper.Request.IsLocal;
        }
    }
    
7. Run the SQL script included with the ELMAH download to generate the needed table and stored procedures, then hookup SQL security and the connection string from the previous steps

You should be good to go now, ripe with error logging goodness. For added user friendliness, we use the following in our web.config to redirect users to nice pages when an error pops up:

The _only_ thing that buggs me about using ELMAH is how Resharper acts with it. The SectionHandler's defined in the sectionGroup in the web.config (from step 2 above) are internal to the ELMAH assembly, so Resharper freaks out that saying they're not defined. Bzzt. Sorry, Resharper, try again. So I've simply built a local version of the project with those attributes marked as public and it's all good. I'm looking into filing a bug report with Resharper on this issue now, as it does it with log4net too. Quite annoying when you have the Solution-wide Analysis option turned on and the web.config consistently shows up with "errors".
