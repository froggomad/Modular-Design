# Native iOS Modular App Design

By building the app using modules (frameworks) we can better ensure separation of concerns and make our design more scalable. Additionally, in iOS Unit Testing, we rely on the simulator which takes a significant amount of time to boot up. If we create our non-UI modules as macOS frameworks, we can dramatically speed up our Unit Testing time as well.

## Modules

### EssentialFeed
<i>The main "Feed"</i>

![Feed Architecture](https://user-images.githubusercontent.com/28037692/120092622-16e50780-c0c9-11eb-9aa6-aecadb6a4789.png)

As an online customer, I want the app to automatically load my latest image feed so I can always enjoy the newest images of my friends


