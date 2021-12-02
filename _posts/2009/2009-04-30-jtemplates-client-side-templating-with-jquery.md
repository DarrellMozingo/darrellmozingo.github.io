---
title: "jTemplates - Client-Side Templating With jQuery"
date: "2009-04-30"
categories: 
  - "javascript"
tags: 
  - "javascript"
---

We're using ASP.NET MVC on my current project at work, and we're heavily exploring jQuery and other client side tools for AJAX effects. One of the first areas where we needed it was a screen where the user enters a zip code and a list of various values get returned based on that code. We got it working just fine rather quickly, but only by slinging some nasty looking spaghetti code in the JavaScript, so we started looking around for a possible solution.

One of the first things we stumbled on was [jTemplates](http://jtemplates.tpython.com/), a client side templating plug-in for jQuery. Awesomeness. So lets say we have the following action on our Employee controller:

```csharp
public ActionResult LookupPeopleByZip(string zip)
{
    var peopleInZip = new List
        {
            new Person
                {
                    Name = "John",
                    Age = 25
                },
            new Person
                {
                    Name = "Jane",
                    Age = 30
                },
            new Person
                {
                    Name = "Mike",
                    Age = 21
                }
        };

    return Json(peopleInZip);
}
```

This creates a simple list of Person objects, uses the built-in ASP.NET MVC JSON result builder to serialize the object graph, and returns that JSON string. Now, let's look at one possible, and probably more common, way to display these results in a table from an AJAX call:

```javascript
<script type="text/javascript">
    $(document).ready(function() {
        $("#search").click(function() {
            var url = 'http://localhost:35125/Standard/LookupPeopleByZip/' + $("#zipCode").val();
<div></div>
            $.getJSON(url,
                function(allMatches) {
                    var matchCount = 0;
<div></div>
                    var tableHtml = '<table>' +
                                    '<tr>' +
                                        '<th>Name</th>' +
                                        '<th>Age</th>' +
                                    '</tr>';
<div></div>
                    for (var i in allMatches) {
                        matchCount++;
                        
                        tableHtml += '<tr>' +
                                    '<td>' + allMatches[i].Name + '</td>' +
                                    '<td>' + allMatches[i].Age + '</td>' +
                                 '</tr>';
                    }
<div></div>
                    tableHtml += '</table>';
<div></div>
                    var headerHtml = '<h3>Matches: ' + matchCount + '</h3>';
<div></div>
                    $("#searchResults").html(headerHtml + tableHtml);
                });
        });
    });
</script>
```

When the search button is clicked, we use jQuery's `getJSON` method to call out to our action depicted above. The resulting JSON string is constructed into an object graph and passed into our call back method (named allMatches above). We then piece meal our HTML together, looping through the object as needed and writing out the properties.

In the solution download at the end, you'll see it runs just fine. Snappy and everything. Damn that's some ugly Javascript code though, isn't it? This is all for a very simple two column table - just imagine something of even moderate complexity here. Instead, let's take a look at the jTemplates solution:

```javascript
<script type="text/javascript">
    $(document).ready(function() {
        $("#search").click(function() {
            var url = 'http://localhost:35125/JTemplates/LookupPeopleByZip/' + $("#zipCode").val();
<div></div>
            $.getJSON(url,
                function(allMatches) {
                    $('#searchResults').setTemplateURL('/Content/ResultTemplate.html');
                    $('#searchResults').processTemplate(allMatches);
                });
        });
    });
</script>
```

Just a wee-bit smaller, wouldn't you say? This code is mostly the same as the original, but instead of building the needed HTML template inline, it uses the jTemplates provided methods on the jQuery selector to set the location for our template, and execute it with our allMatches collection. The template referenced above, ResultTemplate.html, is a basic HTML snippet intermingled with a very minimalistic script like language that jTemplates parses out and updates appropriately:

```
### Matches: {$T.length}

    {#foreach $T as match}
        
    {#/for}

<table>
    <tbody><tr>
        <th>Name</th>
        <th>Age</th>
    </tr>
<tr>
            <td>{$T.match.Name}</td>
            <td>{$T.match.Age}</td>
        </tr></tbody></table>
```

The syntax is actually pretty similar to the [Spark view engine](http://sparkviewengine.com/). It simply loops through the passed in parameter (`$T`) and prints out the needed properties. Notice there's a few extra properties dangling off the parameter too, such as length, used to show the match count at the top.

That's pretty much the basics. Sort of an output only MVC pattern for Javascript (with the JSON return being the model, the return call method being the controller, and jTemplates providing the view engine). If you take a look through the jTemplates site you'll see there's quite a bit more to it if needed. Its come in handy in a few places on our project so far. Grab the [sample solution here](/wp-content/uploads/2009/04/jtemplates.zip).
