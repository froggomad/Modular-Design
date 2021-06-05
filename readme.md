[![Build Status](https://travis-ci.com/froggomad/Modular-Design.svg?branch=main)](https://travis-ci.com/froggomad/Modular-Design)
# Native iOS Modular App Design

By building the app using modules (frameworks) we can better ensure separation of concerns and make our design more scalable. Additionally, in iOS Unit Testing, we rely on the simulator which takes a significant amount of time to boot up. If we create our non-UI modules as macOS frameworks, we can dramatically speed up our Unit Testing time as well.

## Modules

### EssentialFeed
<i>The main "Feed"</i>

#### User Story
As an online customer, I want the app to automatically load my latest image feed so I can always enjoy the newest images of my friends

![Feed Architecture](https://user-images.githubusercontent.com/28037692/120128945-ef00ad00-c177-11eb-95f4-02eb7fa0adbb.png)

[Implementing the Feed](https://github.com/essentialdevelopercom/ios-lead-essentials-feed-api-challenge/pull/237/commits/91b2e076e1a35982e39daad983dc854f38135801)

