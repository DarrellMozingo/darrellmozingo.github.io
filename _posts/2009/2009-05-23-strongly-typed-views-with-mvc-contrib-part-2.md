---
title: "Strongly Typed Views With Mvc Contrib - Part 2"
date: "2009-05-23"
categories: 
  - "aspnet-mvc"
tags: 
  - "aspnet-mvc"
---

In [part 1](http://darrell.mozingo.net/2009/04/30/strongly-typed-views-with-mvc-contrib-part-1/), I explained the reasoning behind using strongly typed HTML helpers in your view (with ease of refactoring being chief among them). Now that you have an ASP.NET MVC project referencing the needed Mvc Contrib assemblies, how can you actually get started using them?

Lets start by taking this sexy looking view model that represents a single customer:

public class CustomerViewModel
{
	public int Id { get; set; }
	public string Name { get; set; }
	public CustomerType Type { get; set; }
}

Where `CustomerType` is a standard enumeration:

public enum CustomerType
{
	Preferred,
	Standard,
	Delinquent
}

Then we'll provide an easy enough action for editing a customer:

// In reality, we'd take in a customer Id and use that to load the customer from the database.
public ActionResult Edit()
{
	var customerViewModelLoadedFromDatabase = new CustomerViewModel
	                                          	{
	                                          		Id = 10,
	                                          		Name = "John",
                                                    		Type = CustomerType.Standard
	                                          	};

	return View("Edit", customerViewModelLoadedFromDatabase);
}

Before looking at the view, though, we'll need to reference the `MvcContrib.FluentHtml.dll` assembly, and add the following to our `web.config`, under the configuration/system.web/pages/namespaces node:

With all that out of the way, here's the relevant portion of the edit view:

<% using(Html.BeginForm(x => x.Update(null))) { %>
	<%= this.Hidden(x => x.Id) %>

	

<table>
		<tbody><tr>
			<td><b>&lt;%= this.Label(x =&gt; x.Name) %&gt;:
			</b></td><td>&lt;%= this.TextBox(x =&gt; x.Name) %&gt;</td>
		</tr>
		<tr>
			<td><b>&lt;%= this.Label(x =&gt; x.Type).Value("Customer Type") %&gt;:</b></td>
			<td>&lt;%= this.Select(x =&gt; x.Type).Options<customertype>().Selected(Model.Type) %&gt;</customertype></td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				&lt;%= this.SubmitButton("Update Customer") %&gt;
			</td>
		</tr>
	</tbody></table>

<% } %> 

First, note that **the page must inherit from `MvcContrib.FluentHtml.ModelViewPage`, not the standard Mvc `ViewPage` class**. The strongly typed Html.BeginForm is from the [Mvc Futures Assembly](http://www.asp.net/mvc/download/). Also, these extensions are on the ModelViewPage base class, not the normal Html helper type methods (i.e. they're `this.TextBox` instead of `Html.TextBox`).

These fields are mostly self explanatory: you'll see the Id is written to a hidden field on the page using the `Hidden` extension, the Name using the `TextBox` extension, and the Type (as a drop down list) using the `Select` extension. All of these extensions have quite a few customizable methods on them, such as the Options and Selected methods on the Select extension shown above. The options method allows you to specify (via generic type or otherwise with an overload) the options for the drop down, while the selected method allows you to specify which option of the list should be highlighted (it'll default to the top item if the parameter is null). The Label extension can generate an HTML label "for" the specified control, so by clicking the "Name" or "Customer Type" labels above, most browsers will set focus to their respective controls.

Another quite useful extension is the `this.IdFor(x => x.Name)`, which for our setup would simply output **Name**, but it comes in handy when dealing with sub objections and collections. This allows you to put a strongly typed reference to your control id's in Javascript, so renaming the view model's property renames _all_ references, including the Javascript ones. Huge help there.

Alright, I'll admit for basic cases like this it's a bit harder to see the immediate benefits of strong typing, so let's complicate it a tad by introducing a sub view model for an address, and a collection of order view models by adding this in the Edit action to the customer object initialization:

Address = new AddressViewModel
          	{
          		Street = "123 Easy St.",
          		City = "Beverly Hills",
          		State = "CA",
          		Zip = "90210"
          	},
Orders = new List {
         		new OrderViewModel
         			{
					Id = 300,
         				ApplyDiscount = true,
         				Quantity = 10
         			},
         		new OrderViewModel
         			{
					Id = 301,
         				ApplyDiscount = false,
         				Quantity = 20
         			}
         	} 

Here's one way to modify the edit page to deal with these new objects:

	**Address:**
	
		

<table>
			<tbody><tr>
				<td>Street:</td>
				<td>&lt;%= this.TextBox(x =&gt; x.Address.Street) %&gt;</td>
			</tr>
			<tr>
				<td>City:</td>
				<td>&lt;%= this.TextBox(x =&gt; x.Address.City) %&gt;</td>
			</tr>
			<tr>
				<td>State:</td>
				<td>&lt;%= this.TextBox(x =&gt; x.Address.State).Styles(width =&gt; "30px") %&gt;</td>
			</tr>
			<tr>
				<td>Zip:</td>
				<td>&lt;%= this.TextBox(x =&gt; x.Address.Zip) %&gt;</td>
			</tr>
		</tbody></table>

	


	**Orders:**
	<% for(int i = 0; i < Model.Orders.Count; i++) { %>
		
			<%= this.Hidden(x => x.Orders\[i\].Id) %>
			

<table>
				<tbody><tr>
					<td>Quantity:</td>
					<td>&lt;%= this.TextBox(x =&gt; x.Orders[i].Quantity) %&gt;</td>
				</tr>
				<tr>
					<td>&lt;%= this.Label(x =&gt; x.Orders[i].ApplyDiscount).Value("Apply Discount") %&gt;:</td>
					<td>&lt;%= this.CheckBox(x =&gt; x.Orders[i].ApplyDiscount)%&gt;</td>
				</tr>
			</tbody></table>

		
	<% } %>

You'll notice this is all still in a strongly typed manor, even with the sub object and object collection. These are basically the same extensions as before, except for `CheckBox`, which works as you'd expect. Note the Styles method on most of these extensions, which takes a param of Func's that allows you to define CSS styles. The state text box, for examples, is defining the width CSS style and setting it to 30px.

All of these extensions take the current ViewData into account when rendering, just as the default ASP.NET MVC extensions do. For instance, the above CheckBox extension will render "checked" if the ApplyDiscount property is true coming in. You can also start to imagine how using the `this.IdFor(x => x.property)` extension to reference controls in your Javascript would start to come in handy here, as HTML id tag rendering for arrays (where the brackets are replaced with underscores) and sub objects (where dots are replaced with underscores) can get pretty complex.

That pretty much covers the basics of the FluentHTML extensions. These reasons alone were enough to get my team to switch our current project over to using them, let alone some of the more advanced features, such as basic validation integration. I'll go over a few of those in the next part of this series, though.
