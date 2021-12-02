---
title: "Generic NHibernate User Type Base Class"
date: "2009-02-10"
---

NHibernate allows you to create custom types for situations where you need more than what's provided by default (int, string, decimal, etc). For example, we have a custom Money, Percent, and Hour value types in our domain which are, for the most part, immutable generic wrappers around a decimal. We wanted to store these types as decimals in the database, but using the provided decimal type just wouldn't work.

Reading [Jakob Andersen's](http://intellect.dk/) nice short article on [creating custom NHibernate user types](http://intellect.dk/post/Implementing-custom-types-in-nHibernate.aspx) gave us the solution we needed, and after creating user types for those three values types, I quickly began getting bored with the repetitiveness of it all.

I figured we'd have a few more user types for the project, so I decided to refactor out as much as I could from the user types themselves. The result is a generic base class that handles all the mundane details of implementing an NHibernate user type:

public abstract class BaseImmutableUserType : IUserType
{
	public abstract object NullSafeGet(IDataReader rs, string\[\] names, object owner);
	public abstract void NullSafeSet(IDbCommand cmd, object value, int index);
	public abstract SqlType\[\] SqlTypes { get; }

	public new bool Equals(object x, object y)
	{
		if(ReferenceEquals(x, y))
		{
			return true;
		}

		if(x == null || y == null)
		{
			return false;
		}

		return x.Equals(y);
	}

	public int GetHashCode(object x)
	{
		return x.GetHashCode();
	}

	public object DeepCopy(object value)
	{
		return value;
	}

	public object Replace(object original, object target, object owner)
	{
		return original;
	}

	public object Assemble(object cached, object owner)
	{
		return DeepCopy(cached);
	}

	public object Disassemble(object value)
	{
		return DeepCopy(value);
	}

	public Type ReturnedType
	{
		get { return typeof(T); }
	}

	public bool IsMutable
	{
		get { return false; }
	}
} 

Pretty much boiler plate code. This allows us to specify just what we need in each user type's implementation, such as this one for our Money value type:

public class MoneyUserType : BaseImmutableUserType {
	public override object NullSafeGet(IDataReader rs, string\[\] names, object owner)
	{
		var amount = NHibernateUtil.Decimal.NullSafeGet(rs, names\[0\]).To();
		return amount.ToMoney();
	}

	public override void NullSafeSet(IDbCommand cmd, object value, int index)
	{
		var moneyObject = value as Money;
		object valueToSet;

		if (moneyObject != null)
		{
			valueToSet = moneyObject.Amount;
		}
		else
		{
			valueToSet = DBNull.Value;
		}

		NHibernateUtil.Decimal.NullSafeSet(cmd, valueToSet, index);
	}

	public override SqlType\[\] SqlTypes
	{
		get
		{
			return new\[\]
			       	{
			       		SqlTypeFactory.Decimal
			       	};
		}
	}
} 

Refactoring out all the unneeded junk, as simple as it might have been, allows other developers to get a quicker grasp of the system and small pieces in it. I know I hate having to break down a large class with lots of unneeded code in it, and this base class allows us to reduce the actual user type down enough to view on a single screen.

This also allowed us to reduce the tests we were doing on each user type to three: one for the get and set methods, and one for the SqlTypes property. All the base class' functionality can be tested separately, and only once. Less tests (while still maintaining adequate coverage) = easier comprehension = lower maintenance costs.

In a future post I'll show a test fixture base class we use to easily test each user type.
