---
title: "C# 3.0 Automatic Property Gotcha"
date: "2008-05-27"
---

One of the neat new features of C# 3.0 is the [automatic properties](http://weblogs.asp.net/scottgu/archive/2007/03/08/new-c-orcas-language-features-automatic-properties-object-initializers-and-collection-initializers.aspx) syntax. It's basically a quicker and simpler way to declare properties, as you don't need to create a private backing object for each one as you've always had to. Here's an example:

```csharp
public class Person
{
    // Original way:
    private string \_name;
    public string Name
    {
        get { return \_name; }
        set { \_name = value; }
    }

    // New, automatic property, way:
    public int Age { get; set; }
}
```

Using the second example, the compiler will basically create a private `Age` member in the background and use in the generated getter/setter of the new property. If it's a numeric type, as `Age` is, it will default to 0. If it's a reference type, such as another class or a Nullable type (i.e. `int?`), it'll default to null.

Now for the semi-gotcha: strings are reference types, so **they'll default to null**. This may not be a problem in your situation, but I personally like to default all of my string to `string.Empty` (unless the situation calls for a null, which I find isn't very often). I just don't like the hassle of dealing with null strings, though the `string.IsNullOrEmpty()` method helps mitigate that.

So there ya go. Take it for what it's worth - something to keep in mind when using the new automatic property feature.
