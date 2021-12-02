---
title: "Clever vs Explicit"
date: "2010-08-20"
---

When we all start out developing, either through classes in high school/college or slowly on our own time, we inevitably want to write code thats super clever. Like, use-3-lines-to-express-what-used-to-take-20-lines type of clever. We see less code and we're pleased. All is good and well with the world.

Until you look at that code a few months down the road and wounder what the hell you were smoking, and it takes you almost as long to decipher it again as it did to write it in the first place. All of a sudden saving those few extra lines of code don't seem so smart, huh?

The simple fact of the matter is you spend more time maintaining code than you do writing it in the first place, so **being more explicit in your code always trumps being clever** to save a few lines. Always.

There's the obvious places where people get clever, like algorithms or loops, but there's plenty of other places too. Places where I wouldn't really call it "being clever", or at least I'm sure the original authors never thought they were trying to be clever when they wrote it. It was probably just quicker to write it in a certain way. For example, take this code:

```csharp
var mappedEmployees = new List();

foreach (var employee in _employeeRepository.All().Where(x => x.IsRetired == false && x.Salary > 100000))
{
    mappedEmployees.Add(_employeeMapper.Map(employee));
}

return View(mappedEmployees); 
```

It's not really hard to read, but it's not really easy either. It might take you an extra second or two to figure out what's going on when you first look at (even if you wrote it a few months ago), but multiply that by how many places you see code like this and how often you go back in to modify it (for new features, bugs, whatever). It adds up, quick. Written more explicitly, it might look something like this:

```csharp
var mappedEmployees = new List();
var nonRetiredHighEarningEmployees = _employeeRepository.All().Where(x => x.IsRetired == false && x.Salary > 100000);

foreach (var nonRetiredHighEarningEmployee in nonRetiredHighEarningEmployees)
{
    var mappedEmployee = _employeeMapper.Map(nonRetiredHighEarningEmployee);
    mappedEmployees.Add(mappedEmployee);
}

return View(mappedEmployees); 
```

You might call it verbose, but I'd say it's a net gain. Each line is doing one thing. Yon can step through and read it without mentally pulling pieces apart. None of this "OK, that's the mapped object call there, and its return is going into the collection there, and the whole thing is looping through that query there". Things are given names and methods aren't nested inside each other.

Always be on the lookout for "clever" areas in your code. Be explicit. Try to stick to each line doing one thing so there's no hidden surprises.
