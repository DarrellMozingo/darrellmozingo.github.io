---
title: "Comments are just missed refactorings"
date: "2010-09-02"
categories: 
  - "musings"
tags: 
  - "musings"
---

Ah comments, those delectable little nuggets of static information that routinely get out of sync with your code's intention. Actually, I'm sort of excited when I run into them though. See, to me they represent missed refactorings that are usually pretty easy to implement.

Say you run across a piece of code like this:

public void ProcessOrder(Order order)
{
	// If the order is on hold, figure out why and get the next availability date.
	if (order.Status == OrderStatus.OnHold && order.OrderDate < DateTime.Now)
	{
		// order.OnHoldReason = (result of complex logic above);
	
		// order.NextAvailableDate = (result of complex logic above);
	}
} 

So it's usually not this obvious in real code bases, but almost every time I've run into a grouping of comments in this arrangement it could be boiled down into something this simple. Can you see the refactoring potential? It's pretty easy - extracting some variables and methods based upon the text in the comment:

public void ProcessOrder(Order order)
{
	var orderIsOnHold = (order.Status == OrderStatus.OnHold && order.OrderDate < DateTime.Now);
	
	if (orderIsOnHold)
	{
		order.OnHoldReason = getOnHoldReason(order)
		order.NextAvailableDate = getNextAvailableDate(order);
	}
}

public string getOnHoldReason(Order order)
{
	return // }

public DateTime getNextAvailableDate(Order order)
{
	return // } 

Like I said, it's not much and it's certainly not hard (a few keystrokes in Visual Studio, with or without ReSharper), but it moves the comments from sitting idly above the code, not participating, to being true first class citizens in the program in the form of variable and method names. It doesn't guarantee they'll be updated with the code if the logic changes in the future, but it gives them a lot better shot at it. I mean, there aren't really developers out there lazy enough to update the intention of a variable or method and _not_ change the name, right? Right?
