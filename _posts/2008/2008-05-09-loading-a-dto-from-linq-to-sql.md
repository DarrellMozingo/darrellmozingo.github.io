---
title: "Loading a DTO from LINQ To SQL"
date: "2008-05-09"
---

## The background

A **D**ata **T**ransfer **O**bject (DTO) is a plain old CLR object (POCO) mainly used to pass data between tiers and remote calls. They're basically classes with getters, setters, and perhaps a constructor or two, but _no_ methods. They're dumb objects that simply hold data.

So why would you use these? A few reasons:

1. They flatten your data. DTO's can contain information from a multitude of sources (database, XML, web service, etc) all neatly packaged together, including any large hierarchies of data from your relational (SQL) store.
2. They more easily allow parameters to be passed into and out of methods, especially expensive ones like web services. You're not forced to break a web service's signature if you need to add/remove parameters if you pass in a DTO. The DTO can change and clients aren't forced to immediately update. They also help keep method signatures nice and tidy.
3. They help decouple your layers by remaining technology and location agnostic. If your relational data moves around, you simply have to modify your data layer (or your business layer if you're passing DTO's back for presentation reasons) to get the needed information. The consuming layer won't care that the data is coming from somewhere else, they're just looking at the DTO's copy.

## The setup

Let's look at a simple scenario. We're loading a business object and calling out to our data layer for the information, which we'll get from SQL using LINQ to SQL. The following DTO will be passed back:

public class PersonDTO
{
	public string FirstName { get; set; }
	public string LastName { get; set; }
	public int Age { get; set; }
	public decimal HourlyWage { get; set; }
}

## The code

Let's look at the GetPerson method from the data layer, which uses LINQ to SQL to retrieve the needed information from SQL:

public PersonDTO GetPerson(int personID)
{
	using(DatabaseDataContext db = new DatabaseDataContext())
	{
		return (from p in db.Peoples
			    join pw in db.PeopleWages on p.PersonID equals pw.PersonID
			    where p.PersonID == personID
			    select new PersonDTO
			    {
					FirstName = p.FirstName,
					LastName = p.LastName,
					Age = p.Age,
					HourlyWage = pw.HourlyWage
			    }
			   ).SingleOrDefault();
	}
}

The key bit is the `select new PersonDTO` and its four accompanying lines. It might look a bit odd, but it's the new [object initializer](http://weblogs.asp.net/scottgu/archive/2007/03/08/new-c-orcas-language-features-automatic-properties-object-initializers-and-collection-initializers.aspx) syntax added to C# 3.0. The compiler is basically creating a constructor in the background, taking in the specified parameters, and setting their respective property values.

This keeps your simple select methods such as this visually clean. No need to return a LINQ object and set each property in a separate call. OK, not a huge positive, but hey, it's the small things that count. I personally love clean, slick, code.

Also note the `SingleOrDefault()` call at the end, which will return a single object from the LINQ statement (which in this case is of type `PersonDTO`) or a default value for that object if one isn't found (and since we're selecting a reference type, it'd return `null`). `SingleOrDefault()` will throw an exception if more than one record is returned from SQL, but since we're looking for a primary key here, it shouldn't be a problem.

As a side note, one of the neat features of Visual Studio 2008 is the IntelliSense's ability to filter the already assigned properties within the object initializer portion of the LINQ statement. For instance, notice how it's hiding the `FirstName` property in the pop-up since I assigned it in the line above:

![IntelliSense filtering the available properites](/assets/2008/dto-linq-to-sql-1.png)

To wrap up, here's the `CreatePerson` method, on the Person object in the business layer, that would consume the above `GetPerson` method:

public Person CreatePerson(int personID)
{
	using(PersonDTO personDTO = DataLayer.GetPerson(personID))
	{
		return new Person
		{
			FirstName = personDTO.FirstName,
			LastName = personDTO.LastName,
			Age = personDTO.Age,
			HourlyWage = personDTO.HourlyWage
		};
	}
}

Notice how it too is making use of the new object initializer feature.
