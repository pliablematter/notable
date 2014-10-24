# Notable

Notable is a framework for presenting on-demand, rich notifications inside your iOS applications. By on-demand, we mean that you can publish them at any time without having to submit an app update for review / approval. By rich notifications, we mean HTML-based content containing images, text, video, etc. that the user can interact with.

Some examples of when you would use Notable notifications are:
* When you’ve released an app update and you want to make users aware of it
* When you’ve released a new app that you want to tell users about
* As a very basic advertising system

Notable is different than standard push notifications in that it only displays available  notifications when the user starts the app, and certain conditions are met. For example, the device is currently on wifi, the iOS version is less than 7.0.1, the notification has not been previously displayed, etc. When all of the conditions are met the notification will be displayed.

The notification will be a small (banner sized), view that will slide up from the bottom or slide down from the top of the screen. You’ll design the banner using HTML and you can add images, buttons, links, etc. Inside the notification, you can use the Notable JavaScript API to transition to a different view, close the notification, show it again in X days, etc.

## Calling

To call notable, just copy the files into your project, import "PMNotable.h" in your AppDelegate, then add the following to your AppDelegate's applicationDidBecomeActive function. Replace the sample control file URL with your own URL.

```
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[PMNotable sharedInstance] updateWithControlFile: @"http://mycontrolfile.com/control.json"];
}

```

## Control File

The control file is a JSON document stored on a standard web server. It defines one or more notifications and the conditions for displaying those notifications.

An example control file can be seen at: 

http://s3.amazonaws.com/notable/control.json

The top level entries of the control files are notifications names. This example contains only one notification named "sample", but others could be supported by creating additional entries.

Each property of an entry is described below.

### entry (required)

This is a string defining the first view that will be displayed if the conditions are met.

### conditions (optional)

This property defines the conditions that must be met for the banner to be displayed. It contains 2 subgroups - *any* and *all*. The banner will be triggered only when **at least one of the any conditions is true and every all condition is true**

Condition Subgroups:
* any - A map of conditions. If any of them evaluate to true then the entire subgroup will evaluate to true.
* all - A map of conditions. If all of them are true then the entire subgroup will evaluate to true.

Condition Types:
* onWifi (boolean) - display only when on wifi (or not on wifi)
* neverDisplayed (boolean) - display only if this notification has never been * displayed (identified by id)
* lastDisplayMinimumSeconds (int) - display only if last display was greater * than this number of seconds
* lastDisplayMinimumLaunches (int) - display only if last display was greater than this number of app launches
* flagNotSet (string) - display only if a flag isn’t set
* iOSVersionLessThan (string) - displays only if the iOS version is less than the number specified.
* appVersionLessThan (string) - displays only if the app version is less than the version specified. Version numbers must be in the 3.2.1 format.

iOS and App version comparisons use the logic described at: https://gist.github.com/alex-cellcity/998472

### views

The property defines one of more views. The key is the view id, which can be referenced in the banner property or by the display(...) function. The values of a view definition are:

* file (required) - An absolute URL for the HTML file associated with the view
* height (optional) - The height that the view will be restricted to. If omitted, the view will fill the height of the screen.
* origin (option) - (top or bottom) where on the screen the notification should appear. The default is 'bottom'.

## JavaScript API

* close() - close the notification
* display(‘viewId’) - display a different view
* setFlag(‘name’, value) - set a flag
* openUrl(‘url’) - open and internal or external url
* width() - provides the width of the current view
* height() - provides the height of the current view

Notable calls Obj-C from JavaScript using the techniques described here: http://stackoverflow.com/questions/21626137/how-to-trigger-objective-c-method-from-javascript-using-javascriptcore-in-ios-7

## Sample Workflows

### Download Update Example

This can be used to notify users of a newer version when the version they're running is out of date.

1. App makes a request for the control file at startup
2. The version they're running is 2.2.2 and the conditions include 'appVersionLessThan: 2.4.0', so the banner is displayed
3. The user taps a "Download Update" button on the banner.
4. The banner calls the JavaScript functions close() and openUrl('https://itunes.apple.com/us/app/nyc-bike-share/id534506272') to send the user to the download page

### Full Screen Example

This can be used to display a small initial banner, followed by a full screen banner if the user requests more detailed information.

1. App makes a request for control file on startup
2. Conditions and evaluated, and trigger a notification to be displayed
3. A small banner notification is displayed
4. The user taps a "More Info" button
5. The banner calls the JavaScript function display('fullscreen') to transition to the fullscreen view defined in the control file.
6. The fullscreen view definition does not include a height, so it fill the vertical space on the screen
7. The user taps a "Close" button on the fullscreen view, which calls the JavaScript close() function and returns them to the app.

### Never Show Again Example

This can be used for something like asking for a review where you want to provide the option to never show the banner again.

1. App makes a request for control file on startup
2. Conditions and evaluated, and trigger a notification to be displayed
3. The notification is displayed
4. The user taps the "Never Show Again" button
5. A JavaScript call inside the banner uses the setFlag('hideSample', true) to set a flag
6. A JavaScript call inside the banner hides the banner with close()
7. The banner is never displayed again since it includes the condition 'flagNotSet: hideSample'

## FAQs

#### What's the minimum iOS version supported?
iOS 7.0

#### Are there third party library requirements?
No, Notable doesn't use any third party libraries

#### How does Notable minimize bandwidth usage?
Notable stores the last modification date for the control file, and makes requests using the If-Modified-Since header to prevent unnecessary / repetitive content download.

#### What happens if there's no network connection when the app starts?
If there's no network connection that all Notable processing will be skipped.

#### Can I add more than one notification to the control file?
Yes, each top-level entry in the control file represents one notification.

#### What happens if the conditions for more than one notification evaluate to true?
Notable will only display one notification at a time. The first one that evaluates to true will be displayed. State is stored per notification id, so if any of the 'lastDisplay..' conditions are used, a different banner would be displayed on the next launch.

#### How does Notable store data?
Notable stores its state using the NSUserDefaults system. If a user delete / reinstalls the app, the state will be lost.

## License

Notable is offered under the [MIT License](https://github.com/pliablematter/notable/blob/master/LICENSE)






