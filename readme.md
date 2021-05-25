# Native iOS Modular App Design

By building the app using modules (frameworks) we can better ensure separation of concerns and make our design more scalable. Additionally, in iOS Unit Testing, we rely on the simulator which takes a significant amount of time to boot up. If we create our non-UI modules as macOS frameworks, we can dramatically speed up our Unit Testing time as well.

## Modules

### EssentialFeed
<i>The main "Feed"</i>

As an online customer, I want the app to automatically load my latest image feed so I can always enjoy the newest images of my friends
