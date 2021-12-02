---
title: "On Throwing Exceptions"
date: "2008-08-15"
---

Don't catch exceptions unless you're prepared to do something meaningful about it, or add more useful information to the exception message/object. There's nothing more annoying than seeing:

try
{
	SomeOperationThatThrowsAnException();
}
catch(Exception ex)
{
	throw;
}

Or:

try
{
	SomeOperationThatThrowsAnException();
}
catch(Exception ex)
{
	throw new Exception("Some Operation threw an exception");
}

Or anything else along those lines. They add nothing meaningful to the situation, and only aid to obfuscate the call stack when debugging. The only reasonable time you should catch an exception, in my opinion, is to somehow recover the operation, or add meaning and context to it. For example:

int userID = 20;   // Already a class member or passed in as a parameter.

try
{
	SomeOperationThatThrowsAnException(userID);
}
catch(Exception ex)
{
	throw new Exception("Couldn't do an operation on userID \\"" + userID + "\\".", ex);
}

Granted, there should probably be a logging facility setup to handle this type of stuff, or a more robust exception framework that will dump all needed local variables, but you get the idea. The exception is essentially being rethrown, but with more context to help debug the problem later on.

Also, remember that you can have a try/finally block with no catch. There's no need to throw a catch block in there and rethrow just to get the benefits of cleaning up your resources. This is perfectly legal:

try
{
	SomeOperationThatThrowsAnException();
}
finally
{
	// Cleanup resources.
}
