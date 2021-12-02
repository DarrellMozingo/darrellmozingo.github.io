---
title: "Production deployment with your build script - Part 4"
date: "2010-12-03"
---

The [first post](http://darrell.mozingo.net/2010/09/24/production-deployment-with-your-build-script-part-1/) gave a quick overview of what our deployment script does and why you'd want one, the [second post](http://darrell.mozingo.net/2010/11/12/production-deployment-with-your-build-script-part-2/) went over pre-deployment steps, and the [third post](http://darrell.mozingo.net/2010/11/24/production-deployment-with-your-build-script-part-3/) in this series covered the actual site's deployment. This post will go over a few of the post-deployment steps we take after publishing our site. Like the last posts, most all of this code will probably be pretty self explanatory.

## Preloading

We make heavy use of StructureMap, NHibernate (w/Fluent NHibernate), and AutoMapper in our system, and those guys have some heavy reflection startup costs. Since it's all done when the app domain starts, we hit each server in our farm to "pre-load" the site for us because that first visit takes a good 30-40 seconds because of those tools.

Since the servers are in a farm, we can't just go to the site's URL as we'd only get one box - even multiple loads aren't guaranteed to move you around to them all. To make sure we're looking at each server, we fiddle with the build server's [hosts file](http://en.wikipedia.org/wiki/Hosts_(file)) and point it at each web server. We don't do parallel builds on our build server, so we thankfully don't have any issues with other build scripts getting tripped up, but you may want to consider that if it's applicable to your situation.

properties {
	$hosts\_file = "C:\\Windows\\System32\\drivers\\etc\\hosts"

	$servers\_production = @( "server1", "server2" )
	$servers\_production\_ip = @{ "server1" = "192.168.1.1"; "server2" = "192.168.1.2" }
}

function setup\_hosts\_file\_for($server, $url)
{
	$server\_ip = $servers\_production\_ip\[$server\]

	echo "Setting hosts file to use $server\_ip ($server) for $url."

	"$server\_ip $url" | Out-File $hosts\_file -Encoding Ascii
}

function remove\_hosts\_file\_entries
{
	echo "Removing all hosts file entries and reverting to a clean file."

	"127.0.0.1 localhost" | Out-File $hosts\_file -Encoding Ascii
}

function make\_sure\_we\_are\_pointing\_at($server, $url)
{
	$expected\_server\_ip = $servers\_production\_ip\[$server\]

	$ping\_output = & ping -n 1 $url
	$ip\_pinged = ($ping\_output | Select-String "\\\[(.\*)\\\]" | Select -ExpandProperty Matches).Groups\[1\].Value

	if ($ip\_pinged -ne $expected\_server\_ip)
	{
		throw "The site's IP is supposed to be $expected\_server\_ip, but it's $ip\_pinged (for $url). Hosts file problem?"
	}

	echo "Correctly pointing at $ip\_pinged for $url."
}

function stop\_dns\_caching
{
	& net stop dnscache
}

function start\_dns\_caching
{
	& net start dnscache
}

The hosts file allows you to point any request for, say, www.asdf.com on your machine to whatever IP you want. So if you wanted to preload www.asdf.com for server1, you can put "192.168.1.1 www.asdf.com" in your hosts file, and you'll always hit that machine. Your load balancing setup might not allow this though. There's also a method that'll ping the given URL to make sure it's going to the proper server, throwing up if it isn't. The last two methods start/stop the [DNS Caching](http://support.microsoft.com/kb/318803) service in Windows, just to help make sure we're looking at the correct IP for a given URL.

With that setup, we can easily manipulate IE through COM to pull up the site:

properties {
	$live\_site\_text\_in\_title = "Our cool site"
	$times\_to\_try\_preloading\_sites = 50
}

function fire\_up\_ie
{
	return New-Object -Com InternetExplorer.Application
}

function preload\_url\_on\_server($server, $url)
{
	setup\_hosts\_file\_for $server $url
	make\_sure\_we\_are\_pointing\_at $server $url

	$current\_attempt\_count = 0
	$3\_seconds = 3

	$ie = fire\_up\_ie
	$ie.navigate($url)

	echo "Pulling up $url in the browser."

	while ($current\_attempt\_count -lt $times\_to\_try\_preloading\_sites)
	{
		pause\_for $3\_seconds

		$document = $ie.document

		if ($document -ne $null -and $document.readyState -eq "Complete" -and $document.title -match $live\_site\_text\_in\_title)
		{
			$time\_taken = ($current\_attempt\_count + 1) \* $3\_seconds
			echo "Preloaded $url on $server in about $time\_taken seconds."

			break
		}

		$current\_attempt\_count++
	}

	$ie.quit()

	if ($current\_attempt\_count -ge $times\_to\_try\_preloading\_sites)
	{
		throw "$url (on $server) couldn't be preloaded after a pretty long ass wait. WTF?"
	}
}

Working with IE's COM interface is pretty painless in PowerShell. Dynamic languages FTW, aye? We just fire up IE, browse to the URL (which should be pointing to the given server only), and keep checking on IE's progress until the page is fully loaded the title contains some piece of text we expected it to. Simple and to the point.

The first snippet in [Part 3](http://darrell.mozingo.net/2010/11/24/production-deployment-with-your-build-script-part-3/) of this series showed how we deployed the site. You can see there where we temporarily stop the DNS Caching service, then pre-load the site on each server are deploying to it, then reset the hosts file and start the DNS Caching service again.

## Testing Error Email Generation

We have some basic code to email exceptions out if our app hits an exception. Nothing fancy. To test our error emails are getting sent OK, I created an obscure URL in the application that'll just generate a `TestErrorEmailException`. When our error handler sees that exception, all it does it send the generated error email to a buildserver@domain.com address rather than the normal one. The build script then logs into it's special GMail accont and checks for the email. This is bar far the chunckiest part of the build script:

properties {
	$email\_url = "mail.ourdomain.com"
	$error\_generation\_path = "/SomeObscurePath/GenerateTestErrorEmail/?subject="
	$max\_email\_check\_attemps = 100
}

function wait\_for\_browser\_to\_finish($ie)
{
	while ($ie.busy -eq $true) {
		pause\_for 1 #second
	}
}

function generate\_test\_error\_emails\_on($server, $base\_url, $error\_email\_subject)
{
	setup\_hosts\_file\_for $server $base\_url
	make\_sure\_we\_are\_pointing\_at $server $base\_url

	$error\_url = $base\_url + $error\_generation\_path
	$full\_error\_url = $error\_url + $error\_email\_subject

	$ie = fire\_up\_ie
	$ie.navigate($full\_error\_url)

	echo "Generating test error email from $full\_error\_url."

	wait\_for\_browser\_to\_finish $ie

	$ie.quit()
}

function ensure\_error\_emails\_are\_working\_on($server, $base\_url)
{
	echo "Ensuring error emails are getting sent out correctly on $server."

	$current\_datetime = Get-Date -Format MM\_dd\_yyyy-hh\_mm\_tt
	$error\_email\_subject = "Error\_" + $server + "\_$current\_datetime"

	generate\_test\_error\_emails\_on $server $base\_url $error\_email\_subject
	check\_email\_was\_sent $error\_email\_subject
}

function check\_email\_was\_sent($expected\_email\_subject)
{
	echo "Pulling up $email\_url in the browser."

	$ie = fire\_up\_ie
	$ie.navigate($email\_url )
	wait\_for\_browser\_to\_finish $ie

	logout\_of\_email $ie

	echo "Logging in to email."

	$ie.document.getElementById("email").value = $security\_user
	$ie.document.getElementById("passwd").value = $security\_password
	$ie.document.getElementById("signin").click()
	wait\_for\_browser\_to\_finish $ie

	echo "Looking for test error email."

	$test\_error\_email = $null

	for ($i = 1; $i -le $max\_email\_check\_attemps; $i++)
	{
		echo "Attempt #$i checking for the test error email."

		$test\_error\_email = get\_link\_containing\_text $ie $expected\_email\_subject

		if ($test\_error\_email -ne $null)
		{
			echo "Found the test error email."
			break
		}

		pause\_for 10 #seconds

		echo "Refreshing the page after a pause."
		click\_link\_with\_text $ie "Refresh"
	}

	if ($test\_error\_email -eq $null)
	{
		$ie.quit()
		throw "Test error email was never received after $max\_email\_check\_attemps attempts. Problem?"
	}
	
	echo "Pulling up the test error email."

	$ie.navigate($test\_error\_email.href)
	wait\_for\_browser\_to\_finish $ie

	echo "Deleting test error email."
	click\_link\_with\_text $ie "Delete"

	logout\_of\_email $ie

	$ie.quit()
}

function logout\_of\_email($ie)
{
	$signout\_link = get\_link\_with\_text $ie "Sign out"

	if ($signout\_link -ne $null)
	{
		echo "Signing out of email."
		$ie.navigate($signout\_link.href)

		wait\_for\_browser\_to\_finish $ie
	}
}

function click\_link\_with\_text($ie, $text)
{
	$link = get\_link\_with\_text $ie $text
	$there\_are\_multiple\_links\_with\_that\_text = ($link.length -gt 1)

	if ($there\_are\_multiple\_links\_with\_that\_text)
	{
		$ie.navigate($link\[0\].href)
	}
	else
	{
		$ie.navigate($link.href)
	}

	wait\_for\_browser\_to\_finish $ie
}

function get\_link\_with\_text($ie, $text)
{
	return $ie.document.getElementsByTagName("a") | where { $\_.innerText -eq $text }
}

function get\_link\_containing\_text($ie, $text)
{
	return $ie.document.getElementsByTagName("a") | where { $\_.innerText -match $text }
}

It seriously looks worse than it really is, and most of it is due to navigating around GMail's interface. So we hit the obscure URL in our app, pass it a subject line for the error email, wait a bit, then log into GMail and check for an email with that same subject line. If we don't find the email after a waiting period, we blow up the script. Simple as that.

If you know an easier way to do this, I'm all ears!

## Conclusion

The two biggest things we do after deploying our site is, for each individual server in the farm, load it up so all the first time reflection stuff can get taken care of and make sure any errors on the site are getting emailed out correctly. While controlling IE through its COM interface is a lot cleaner and easier with PowerShell, there's still some code for navigating around GMail's site. Obviously if you use a different setup for your email, you'll either have to control a different app or access the SMTP server directly.

Unfortunately, the biggest piece for both of these things being helpful is if you can navigate to each server in the farm. If your network setup prevents that, it's not going to do you much good unless you keep clearing your cookies and revisiting the site a bunch of times in hopes you'll get each server, or something crazy like that.

So while most of this code is straight forward, I hope it'll give you a starting point for your deployment script. Like I said in the beginning: it's a bit painful to initially setup (both creating it and testing it), but we've found huge value from having it in place. It's obviously not as easy as [Capistrano](http://en.wikipedia.org/wiki/Capistrano), but, meh, it works. Another option for .NET is [Web Deploy](http://www.iis.net/download/webdeploy), a relatively new tool from Microsoft. I haven't had time to get too deep into it, but it may help for your situation.

Good luck!
