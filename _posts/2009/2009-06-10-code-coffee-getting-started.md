---
title: "Code & Coffee - Getting Started"
date: "2009-06-10"
categories: 
  - "events"
tags: 
  - "events"
---

We had a couple of new guys join us for last week's [Code & Coffee](http://darrell.mozingo.net/2009/05/08/code-and-coffee/), and during the 15 minutes or so we spent helping get them up to speed I realized a quick "getting started" post might be in order to help future attendees.

For starters, download the [Ruby 1.8.6 one-click installer](http://rubyforge.org/frs/download.php/47082/ruby186-27_rc2.exe) (from the [main Ruby site](http://www.ruby-lang.org/en/downloads/)). It may or may not require a reboot to get the standard C:\\ruby install directory into your PATH variable. Open a command prompt and type `ruby --version` to make sure it's working correctly.

We're working our way through [Edge Case's Ruby Koans](http://github.com/edgecase/ruby_koans/tree/master) right now, which are basically a whole suite of failing unit tests that teach you more about the language as you get them passing. There's a download link in the middle of the upper portion of their GitHub page. Once you download and extract it somewhere, open up a command prompt in the root directory and run the `rake` command. It will use the **Rakefile** in that directory by default and it should tell you the first test failed. Open the respective file in the koans directory, try getting it to pass, and re-run rake. Keep going through that process, test by test. Some are blatantly obvious, while others require some research. It's best if you think about what you're actually doing too, besides just trying to make the test pass. We're currently somewhere in the **about\_hashes.rb** file.

The idea is to get through these, soaking up as much as we can, then probably jump into an intro [Rails](http://rubyonrails.org/) application, eventually working on some sort of blog for the Code & Coffee. Should be fun. I'd also like to get into either [RSpec](http://rspec.info/) or [Cucumber](http://cukes.info/) along the way, and see what TDD/BDD in Ruby is like as I've always heard how great it is.

Our next get together will be Friday, June 19th @ 7am. Hope to see you there, and let me know if you have any problems with getting this stuff setup.
