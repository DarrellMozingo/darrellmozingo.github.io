---
title: "Crisis as Opportunity"
date: "2009-07-18"
categories: 
  - "musings"
tags: 
  - "musings"
---

I'm currently reading through Eric Evan's [Domain Driven Design](http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215). It's quite a good read - a bit thick at times, but still very much grounded in pragmatism and real life. One smaller section really stood out at me recently, titled "Crisis as Opportunity", and begins on page 325. Here's a few of the more meaningful portions from that section:

> "A period of steady refinement of a model can suddenly bring you to an insight that shakes up everything...Such a situation often does not look like an opportunity; it seems more like a crisis. Suddenly there is some obvious inadequacy in the model...Maybe it makes statements that are just wrong. This means the team has reached a new level of understanding. From their now-elevated viewpoint, the old model looks poor. From that viewpoint, they can conceive a far better one."

Its something that's happened to my team a few times on our current project so far - seeming like we hit a brick wall on an issue. Certain parts of the code base were having to be bended and twisted all sorts of ways to meet new requirements, producing far uglier code than when we first wrote it. These areas seemed to dragging us down, but the constant onslaught of requirements pretty much forced us to push through and find a better way.

Taking a step back from the situation provided a great view that allowed us to use some new understanding of the domain, our current code base, and where we knew it was heading in the not too distant future, to refactor for "deeper insight", as Evans calls it. Introducing elements that were implicitly in the design as explicit objects and methods was exactly what we needed. The former problems areas were then much easier to work with, allowing new requirements to be added at a much faster pace.

I now almost look forward to hitting a brick wall when trying to add new requirements to our domain. It means our domain needs work and we could be on the cusp of a nice big 'ol refactoring to gain more insight, and I love my insight.
