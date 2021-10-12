---
title: "DevOps Days London 2013"
date: "2013-03-18"
categories: 
  - "events"
tags: 
  - "events"
---

![DevOpsDays](images/bridge-the-gap-300x225.png) I spent this past Friday & Saturday at [DevOpsDays London](http://www.devopsdays.org/events/2013-london/). There's been a few reviews written already about various bits (and a nice collection of resources by my co-worker [Anna](http://annaken.blogspot.co.uk/2013/03/devops-community-resources.html)), and I wanted to throw my thoughts out there too. The talks each morning were all very good and well presented, but for me the real meat of the event for me was the 3 tracks of Open Spaces each afternoon, along with various break time and hallway discussions. I didn't take as detailed notes as others did, but here's the bits I took away from each Open Space:

- **Monitoring:** - Discussed using Zabbix, continuous monitoring, and some companies trying out self-healing techniques with limited success (be careful with services flapping off and on)
- **Logstash:** - Windows client support (not as good as it sounds), architecture (Zeromq everything to one or two servers, then to Elastic search), what to log (everything!)
- **Configuration Management 101 (w/Puppet & Chef):** It was great having the guys from PuppetLabs and Opscode here to give views on both products (and trade some friendly jabs!). Good discussion about Window support, including a daily growing community with package support and the real possibility of actually doing config management on Windows. We're using CFEngine, and while I got crickets after bringing it up, a few people were able to offer some good advise and compare with Puppet & Chef (stops on error like Chef, good for legacy support, promise support is nice, etc).
- **Op to dev feedback cycle:** Besides the usual "put devs on call" idea (which I still feel is a bad idea), there was discussion about getting bugs like memory leaks prioritised above features. One of the better suggestions to me was simply going and talking to the devs, putting faces to names and getting to know one another. Suggestions were also made for ops to just patch the code themselves, which throws up a lot alarms to me (going through back channels, perhaps not properly tested, etc). I say make a pull request.
- **Deployment orchestration:** Bittorrent for massive deploys (Twitter's Murder), Jenkins/TeamCity/et al are still best for kicking off deploys, and MCollective for orchestration.
- **Ops user stories:** Creating user stories for op project prioritisation is hard, as is fitting the work in for sprints. Ended up coming down to standard estimation difficulties - more work popping up, unknown unknowns, etc. Left a bit before the end to pop into a Biz & DevOps Open Space, but didn't get much from it before it ended,

Overall it was a great conference. Well planned, good food, and great discussions. Nothing completely ground breaking, but a lot of really good tips & recommendations to dig into.
