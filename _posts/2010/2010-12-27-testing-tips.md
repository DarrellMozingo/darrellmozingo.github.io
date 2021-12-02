---
title: "Testing tips"
date: "2010-12-27"
---

Just some quick testing tips I've found helpful over the last few years.

## Naming

Don't name variables `company1` or `company2`. There's a reason you're creating two of them - why? Names like `companyMatchingCriteria` or `companyWithCorrectAddressAndWrongPhoneNumber` make a lot more sense when reading the tests later. When it comes to testing, readability is paramount, even more so than perhaps the production code.

Unreadable tests lead to developers ignoring them, which leads to false positives, which leads to deleting the tests, which leads to, um, purgatory, I suppose. An alternative is the good hearted developer that spends a disproportionate amount of time understanding and fixing a handful of tests when they only changed a few lines of production code. Either option isn't appealing, and goes against one of the reasons for testing in the first place.

## Intent

When naming tests, either the test names themselves, variable names, or whatever - always go after the business intent rather than the technical reasons. So rather than `Should_break_out_of_the_loop_when_an_employee_address_is_null`, for example, try something like `Should_not_process_employees_that_have_not_entered_their_address`. You can picture how these would mean the same thing in the production code (probably a simple null check), but one talks about breaking out of loops and null values (technical), while the other talks about not processing and non-entered values (businesses). The differences often aren't this obvious either, and I know we developers love talking technical, so it's pretty easy to let that creep into our testing language.

This helps in a few ways:

1. Writing the code - if you can't pin a business reason to a certain bit of code to exist, it probably shouldn't. I know it's always tempting to throw extra checks in here and there, but if the businesses doesn't need it for a certain reason, it shouldn't exist (exceptions obviously exist). Maybe you're checking for null employee addresses, but when talking to the business folks, they want the user to enter an addresses when they create the employee. This leads to the employee never existing without an address, and negates the need for the check in the first place. If you were just checking for a null, you'd never think to ask this and it'd always be there.
2. Maintaining the code - I hate reading code that does a bunch of checks (null, certain values, empty strings, etc), and you come to figure out after working with it for a while that the checks aren't even needed because of invariants in the system (i.e. those values can never fall into that state). It's just extra code to read, mentally parse, consider in different situations, and perpetuate - "well, that method checks this for null, so I should too".
3. Talking with the business folks - when they come to you and ask what happens if the employee hasn't entered an address yet, you can look through the tests and see they're not processed this this location or that for whatever reason. This saves you from having to look for null checks in the testing names and figuring out what it means in different situations. This is a bit of a contrived example for this point, but you get the idea. The tests correspond to how the business people think about things.

So, business intent in test naming = good, technical jargon = bad. Again, exceptions do exist, so this isn't set in stone all the time.

See a theme with all my recent tips? Naming. That's why [Phil Karlton](http://people.famouswhy.com/phil_karlton/) famously said:

"There are only two hard things in Computer Science: cache invalidation and naming things"

Very true.
