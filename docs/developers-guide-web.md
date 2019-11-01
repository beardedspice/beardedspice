
# Developers' Guide for Website Strategies

## Dependencies

We use [CocoaPods](https://cocoapods.org/) to manage all obj-c/cocoa dependences. cd to the directory containing the workspace, then install them locally using:
```bash
sudo gem install cocoapods
pod setup
pod install
```

*Always* use `BeardedSpice.xcworkspace` for development, *NOT* `BeardedSpice.xcodeproject`

BeardedSpice is built with [SPMediaKeyTap](https://github.com/nevyn/SPMediaKeyTap) and works well with other applications listening to media key events.


## Writing a *Media Strategy*

Media controllers are written as [strategies](https://github.com/beardedspice/beardedspice/blob/master/template-explained.js). Each strategy defines a collection of Javascript functions to be executed on particular webpages.

```javascript
//
//  NewStrategyName.js
//  BeardedSpice
//
//  Created by You on Today's Date.
//  Copyright (c) 2015-2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the file to retain consistent syntax coloring.

// Use a syntax checker to ensure validity. One is provided by nodejs (`node -c filename.js`)
// Normal formatting is supported (can copy/paste with newlines and indentations)

BSStrategy = {
  version: 1,
  displayName: "Strategy Name",
  accepts: {
    method: "predicateOnTab" /* OR "script" */,
    /* Use these if "predicateOnTab" */
    format: "%K LIKE[c] '*[YOUR-URL-DOMAIN-OR-TITLE-HERE]*'",
    args: ["URL" /* OR "title" */]
    /* Use "script" if method is "script" */
    /* [ex] script: "some javascript here that returns a boolean value" */
  },

  /*
  Elements marked as //OPTIONAL 
  'MUST' be removed if website does not support corresponding action 
  */
  pause:     function () { /* pause site playing */ },
  isPlaying: function () { /* javascript that returns a boolean */ }, //OPTIONAL
  toggle:    function () { /* toggle site playing */ },               //OPTIONAL
  previous:  function () { /* switch to previous track if any */ },   //OPTIONAL
  next:      function () { /* switch to next track if any */ },       //OPTIONAL
  favorite:  function () { /* toggles favorite on/off */},            //OPTIONAL
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.

  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {                                            //OPTIONAL
    return {
        'track': 'the name of the track',
        'album': 'the name of the current album',
        'artist': 'the name of the current artist',
        'image': 'http://www.example.com/some/album/artwork.png',
        'favorited': 'true/false if the track has been favorited',
    };
  }
}
// The file must have an empty line at the end.

```

- `accepts` - takes a `Tab` object and returns `YES` if the strategy can control the given tab.

- `displayName` - must return a unique string describing the controller and will be used as the name shown in the Preferences panel. Some other functions return a Javascript function for the particular action.

- `pause` - a special case used when changing the active tab.

- `trackInfo` - [Optional] returns a `BSTrack` object based on the currently accepted 5 keys (see trackInfo in the above xml), which used in notifications for the user.


Update the [`versions.plist`](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategies/versions.plist) to include an instance of your new strategy:

```xml
    <key>AmazonMusic</key>
    <integer>1</integer>
```

Finally, add it to the list in [`README.md`](https://github.com/beardedspice/beardedspice/blob/master/README.md) in alphabetical order:
```markdown
- [Amazon Music](https://www.amazon.com/gp/dmusic/cloudplayer/player)
```

## Updating a *Media Strategy*

In the case that a strategy template no longer works with a service, or is missing functionality: All logic for controlling a service should be written in javascript and stored in the appropriate .js file. For example, the [Youtube strategy](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategies/Youtube.js) has javascript for all five functions as well as partial trackInfo retrieval.

After updating a strategy, update it's version in the `ServiceName.js` you've created, as well as the ServiceName entry in the [`versions.plist`](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategies/versions.plist) file. Updating a version means incrementing the number by 1. All references to the service should have the same version when creating a PR.

```xml
    <!-- versions.plist -->
    <key>AmazonMusic</key>
    <integer>1</integer>
```
```js
    // AmazonMusic.js
    BSStrategy = {
      version: 1,
      ...
    }
```

becomes

```
    <!-- versions.plist -->
    <key>AmazonMusic</key>
    <integer>2</integer>
```
```js
    // AmazonMusic.js
    BSStrategy = {
      version: 2,
      ...
    }
```

If you find that javascript alone cannot properly control a service, please [create an issue](https://github.com/beardedspice/beardedspice/issues/new?label=%5BApp%20Support%5D) specifying your work branch (as a link), the service in question, and your difficulty as precisely as possible.


# About pull requests
Any progressive improvement is welcome. Also if you are implementing a new strategy, take the trouble to implement all methods with the most modern API for the service, please. PR with a strategy that is not fully implemented for no reason will be rejected.
