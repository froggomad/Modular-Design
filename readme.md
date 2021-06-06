[![Build Status](https://travis-ci.com/froggomad/Modular-Design.svg?branch=main)](https://travis-ci.com/froggomad/Modular-Design)
# Native iOS Modular App Design

By building the app using modules (frameworks) we can better ensure separation of concerns and make our design more scalable. Additionally, in iOS Unit Testing, we rely on the simulator which takes a significant amount of time to boot up. If we create our non-UI modules as macOS frameworks, we can dramatically speed up our Unit Testing time as well.

## Modules

### EssentialFeed
<i>The main "Feed"</i>

### Narrative #1

```
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed
```

## Use Cases

### Load Feed From Remote Use Case

#### Data:
- URL
	@@ -56,41 +67,51 @@ Then the app should display an error message
5. System delivers feed items.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

## Architecture
![Feed Loading Feature](https://user-images.githubusercontent.com/28037692/120128945-ef00ad00-c177-11eb-95f4-02eb7fa0adbb.png)

[Implementing the Remote Feed](https://github.com/essentialdevelopercom/ios-lead-essentials-feed-api-challenge/pull/237/commits/91b2e076e1a35982e39daad983dc854f38135801)
<hr>

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is less than seven days old
 When the customer requests to see the feed
 Then the app should display the latest feed saved
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is seven days old or more
 When the customer requests to see the feed
 Then the app should display an error message
Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the feed
 Then the app should display an error message
```
### Load Feed From Cache Use Case

#### Primary course:
1. Execute "Load Feed Items" command with above data.
2. System fetches feed data from cache.
3. System validates cache is less than seven days old.
4. System creates feed items from cached data.
5. System delivers feed items.

#### Error course (sad path):
1. System delivers error.

#### Expired cache course (sad path): 
1. System deletes cache.
2. System delivers no feed items.

#### Empty cache course (sad path): 
1. System delivers no feed items.


### Cache Feed Use Case

#### Data:
- Feed items

#### Primary course (happy path):
1. Execute "Save Feed Items" command with above data.
2. System deletes old cache data.
3. System encodes feed items.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.

## Architecture
![Feed Loading Feature](https://user-images.githubusercontent.com/28037692/120128945-ef00ad00-c177-11eb-95f4-02eb7fa0adbb.png)

## Model Specs
### Feed Item
| Property      | Type                |
|---------------|---------------------|
| `id`          | `UUID`              |
| `description` | `String` (optional) |
| `location`    | `String` (optional) |
| `imageURL`    | `URL`               |

### Payload contract
```
GET *url* (TBD)
200 RESPONSE
{
	"items": [
		{
			"id": "a UUID",
			"description": "a description",
			"location": "a location",
			"image": "https://a-image.url",
		},
		{
			"id": "another UUID",
			"description": "another description",
			"image": "https://another-image.url"
		},
		{
			"id": "even another UUID",
			"location": "even another location",
			"image": "https://even-another-image.url"
		},
		{
			"id": "yet another UUID",
			"image": "https://yet-another-image.url"
		}
		...
	]
}
```
