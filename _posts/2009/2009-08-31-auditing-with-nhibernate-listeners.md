---
title: "Auditing with NHibernate Listeners"
date: "2009-08-31"
categories: 
  - "nhibernate"
tags: 
  - "nhibernate"
---

We recently had a requirement to do auditing in our application, complete with storing the old and new values. Previous applications had used a method that took all that information in an wrote it to the database, giving us a lot of control of what we logged and when, but it required us to call it in every needed situation or we'd lose the capability, not to mention it made reading the code horrid.

Thankfully, we're using NHibernate for this application. I'd read here and there over the past year about how simple auditing was with NHibernate and I'd bookmarked them, knowing this requirement was working its way down the pipeline. Unfortunately, pretty much every example I could find out there was simple using simple created time stamp, modified time stamp, and user making the update fields. For our application we needed to track the old and new values in addition to these fields, along with a few other requirements that are pretty specific to our application (so I'll leave them out here).

We'll store these audit entries in a separate table with a primary key reference back to the entity they modified. Let's start by defining a domain object to represent a single audit entry:

public class AuditLogEntry
{
	public virtual int Id { get; set; }
	public virtual string Username { get; set; }
	public virtual string AuditEntryType { get; set; }
	public virtual string EntityFullName { get; set; }
	public virtual string EntityShortName { get; set; }
	public virtual int EntityId { get; set; }
	public virtual string FieldName { get; set; }
	public virtual string OldValue { get; set; }
	public virtual string NewValue { get; set; }
	public virtual DateTime Timestamp { get; set; }
}

Pretty self explanatory - it'll store details related to the update, including what field was updated, the object full/short name, id of the entity, the old/new values, username that made the update, and a time stamp.

We'll also need a simple entity to use as our test subject:

public class Employee
{
	public virtual int Id { get; set; }
	public virtual string Name { get; set; }
	public virtual int Age { get; set; }
}

Again, nothing fancy (though note this will scale up - we're using fairly complex objects in our domain, and while the auditing code I'll post here isn't the exact same, it's not too far off, and we haven't had a problem yet). I'll stick with Fluent NHibernate's [auto mapping](http://wiki.fluentnhibernate.org/Auto_mapping) to produce the basic mappings we'll need. There's nothing special required there.

Now for the actual auditing code. We'll use the newer Listener (Pre/Post Update/Insert/Delete/etc) interfaces, which replaced the generic `IInterceptor`. Basically, each seperate entity that's saved will get passed into our class, allowing us to do whatever we need with it. We'll be collecting auditing data:

public class AuditUpdateListener : IPostUpdateEventListener
{
	private const string \_noValueString = "\*No Value\*";

	private static string getStringValueFromStateArray(object\[\] stateArray, int position)
	{
		var value = stateArray\[position\];

		return value == null || value.ToString() == string.Empty
		       	? \_noValueString
		       	: value.ToString();
	}

	public void OnPostUpdate(PostUpdateEvent @event)
	{
		if (@event.Entity is AuditLogEntry)
		{
			return;
		}

		var entityFullName = @event.Entity.GetType().FullName;

		if (@event.OldState == null)
		{
			throw new ArgumentNullException("No old state available for entity type '" + entityFullName +
			                                "'. Make sure you're loading it into Session before modifying and saving it.");
		}

		var dirtyFieldIndexes = @event.Persister.FindDirty(@event.State, @event.OldState, @event.Entity, @event.Session);

		var session = @event.Session.GetSession(EntityMode.Poco);

		foreach (var dirtyFieldIndex in dirtyFieldIndexes)
		{
			var oldValue = getStringValueFromStateArray(@event.OldState, dirtyFieldIndex);
			var newValue = getStringValueFromStateArray(@event.State, dirtyFieldIndex);

			if (oldValue == newValue)
			{
				continue;
			}

			session.Save(new AuditLogEntry
			             	{
			             		EntityShortName = @event.Entity.GetType().Name,
			             		FieldName = @event.Persister.PropertyNames\[dirtyFieldIndex\],
			             		EntityFullName = entityFullName,
			             		OldValue = oldValue,
			             		NewValue = newValue,
			             		Username = Environment.UserName,
			             		EntityId = (int)@event.Id,
			             		AuditEntryType = "Update",
			             		Timestamp = DateTime.Now
			             	});
		}

		session.Flush();
	}
}

First we inherit from `IPostUpdateEventListener`, which has a single `OnPostUpdate` method defined. We check to make sure we're not auditing another audit entity (infinite loop, anyone?), then make sure we have the old values available, throwing if we don't. For this system to work/be effective, you **must** load the entity into session, modify it, then save. In a few places, we had everything we already needed from the form (we're working in a web environment), so we'd just set all the properties, including the entity's id. The problem there is NHibernate's session has no idea what the old values are, so we've now made it a policy to always load the entity before saving it.

On line 29, we're delegating to NHibernate to tell us which properties in the entity are dirty, or have changed. We then loop through those properties, collect the needed values for our `AuditLogEntry` entity, and save it off.

As I've mentioned, this works just fine for most applications. The first issue we ran into was Components (in the NHibernate sense). They're represented as a single property changed on the entity, so all you get is the `ToString` on the object. Fortunately there's an easy way to see if the property is a Component (hint: `@event.Persister.PropertyTypes[dirtyFieldIndex] is ComponentType` before line 43), so we use reflection to loop through the properties by hand and compare them for dirtiness.

There you go, damn near complete old & new value auditing, just like mom would have always wanted. Not perfect, I'm sure, but we've been using a modified version of this for a while and haven't had any problems.
