---
title: "Painfully slow clone speeds with msysgit & GitExtensions"
date: "2011-09-29"
categories: 
  - "quickie"
tags: 
  - "quickie"
---

**UPDATE:** See Paul's comment below - sounds like the latest cygwin upgrade process isn't as easy as it used to be.

If you install [GitExtensions](http://code.google.com/p/gitextensions/), up through the current 2.24 version (which comes bundled with the latest [msysgit](http://code.google.com/p/msysgit/) version 1.7.6-preview20110708), and use OpenSSH for your authentication (as opposed to Plink), you'll likely notice some painfully slow cloning speeds. Like 1MB/sec on a 100Mb network kinda slow.

Thankfully, it's a pretty easy fix. Apparently msysgit still comes bundled with [an ancient version of OpenSSH](http://groups.google.com/group/msysgit/browse_thread/thread/c47054f2d14d0981):

$ ssh -V
OpenSSH\_4.6p1, OpenSSL 0.9.8e 23 Feb 2007

Until they get it updated, it's easy to do yourself. Simply install the latest version of [Cygwin](http://cygwin.com/setup.exe), and make sure to search for and install OpenSSH on the package screen. Then go into the `/bin` directory of where you installed Cygwin, and copy the following files into `C:\Program Files\Git\bin` (or `Program Files (x86)` if you're on 64-bit):

- cygcrypto-0.9.8.dll
- cyggcc\_s-1.dll
- cygssp-0.dll
- cygwin1.dll
- cygz.dll
- ssh.exe
- ssh-add.exe
- ssh-agent.exe
- ssh-keygen.exe
- ssh-keyscan.exe

Checking the OpenSSH version should yield something a bit higher now:

$ ssh -V
OpenSSH\_5.8p1, OpenSSL 0.9.8r 8 Feb 2011

Your clone speeds should be faster too. This upgrade bumped ours from literally around 1MB/sec to a bit over 10MB/sec. Nice.
