---
title: "Juggling Git with multiple accounts"
date: "2010-03-05"
---

We're finally getting a Git server setup at work. Since I also happen to do a bit of open source contributing at work (usually via submitting patches for issues that effect us) and virtually every open source project and its brother is moving to [Github](https://github.com/) lately, I could already see juggling these two systems would be an issue. I can't use the same SSH key for both our internal Git server and Github for various reasons, and I wouldn't I want to, really. Fortunately, it turns out managing multiple accounts with Git, and SSH in general, isn't too bad.

I'll walk you through doing this, assuming you don't already have an SSH key or Github account (if you do, though, it's no biggie, just make sure to back everything up and swap out a few obvious steps below).

1. Sign up with [Github](http://github.com).
2. Download & install [msysgit](http://code.google.com/p/msysgit/) (chose to use the OpenSSH instead of Tortoise/Putty's PLink when prompted).
3. Open a Git Bash prompt (an icon is placed in the Start menu during msysgit's installation).
4. Create your SSH key pairs, doing the following steps once for each email/account (internal work & external public ones, for instance):
    1. `ssh-keygen -t rsa -C "public_or_private@email.com"`
    2. When it asks for the file to save to, specify the same folder it's suggesting for the default one (i.e. `/c/Users/dmozingo/.ssh/`) but name the file something different, based on whether it's for the public or private key (maybe something like `id_rsa_github` and `id_rsa_work`).
    3. Enter a passphrase. I usually leave it blank as other guides suggest, trusting (perhaps mistakingly?) Window's folder security to keep it safe for me.
5. Navigate to the folder where you just created your SSH key pairs, and create a file named `config`.
6. Open the file in notepad and enter the following:

```
Host github.com
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile /Users/dmozingo/.ssh/id\_rsa\_github

Host work
    HostName workGitServername
    User dmozingo
    IdentityFile /Users/dmozingo/.ssh/id\_rsa\_work
```

    You'll have to do a few substitutions in the file, mainly for the work `HostName` and both section's `IdentityFile`'s, if they're different for your setup. The first line of each section specified the name you'll use in "addressing" your Git commands later. By keeping the first one github.com, you won't have to change anything when you follow along with other guides online.
7. Now give GitHub the contents of your public/GitHub SSH key file (the id\_rsa\_github.pub from my example). You can do this on your account settings page.
8. Still at the Git Bash prompt, enter `ssh-agent.exe bash` to start the key manager. **You'll have to do this each time you use Git**, unless someone (please?) can tell me a better way.
9. Enter `ssh-add.exe ~/.ssh/id_rsa_github`, where the tilday (~) represents your home directory (C:\\Users\\username for Vista/7, C:\\Documents and Settings\\username for XP). This should point to the public SSH key file you made earlier. **You'll also have to do this each tiem you use Git**, again, unless someone can set me straight here.

That should be it! Test it out by entering `ssh git@github.com`. You should see something like this:

![Github SSH success](/assets/2010/github_ssh_success.png)

So while it's definitely harder than not having to juggling multiple accounts, it's not as bad as it sounds. Know a better way to do this? Please let me know!
