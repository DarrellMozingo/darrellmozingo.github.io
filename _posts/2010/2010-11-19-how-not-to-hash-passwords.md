---
title: "How *not* to hash passwords"
date: "2010-11-19"
---

We were stupid back in the day (OK, a year or two, but who's counting?). When we started our latest project it was a given that we'd be hashing passwords for storage. The most obvious and easiest way to do it was the good 'ol `(password + hash).GetHashCode()`. Done and done. We moved on to the next feature and never gave it a second thought.

As it turns out though, using `GetHashCode()` for password hashing purposes is, well, [pretty stupid and irresponsible](http://blogs.msdn.com/b/ericlippert/archive/2005/10/24/do-not-use-string-hashes-for-security-purposes.aspx). `GetHashCode()` was never intended to be stable across .NET versions or even architectures (x86 vs x64), and apparently the framework spec documents call this out. In fact, its results have changed slightly between .NET 3.5 and 4.0, which is what we were just upgrading to when I noticed this. Similar changes aparently occurred between 1.1 and 2.0 too.

For example, the `GetHashCode()` hash of the string "password" from .NET 3.5 is **\-733234769**, while the hash from that exact same string in .NET 4.0 is **\-231203086**. Scary, huh?

In light of that, we switched to using the `SHA512Managed` class to generate our hashes. Switching our code over wasn't an issue ([DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself) for the win!), but having to email our customers to enter new passwords and security questions, which we also hashed the same way, wasn't exactly fun. Not knowing their passwords apparently does have a downside! Here's how we're generating our hash codes now:

```csharp
private const string _passwordSalt = "some_long_random_string";

public static string CalculateSaltedHash(string text)
{
    var inputBytes = Encoding.UTF8.GetBytes(text + _passwordSalt);
    var hash = new SHA512Managed().ComputeHash(inputBytes);

    return Convert.ToBase64String(hash);
}
```

Yay? Nay?
