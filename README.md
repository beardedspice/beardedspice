
# Users Guide

[![BeardedSpice](images/bs.jpg)](images/bs.jpg)

## What?
BeardedSpice allows you to control web based media players (Like *SoundCloud*, and *YouTube* ... [List of supported sites to date](#supported-sites)) and some native apps with the media keys found on Mac keyboards.

## How?
All you need to do is just open your favorite [supported media site](#supported-sites) in either Chrome or Safari, then click on BeardedSpice's Menubar icon ![BeardedSpice](BeardedSpice/beard.png) and select the website you want to control using your media keys.

#### Interested in doing it with a keyboard-shortcut?
We've got you covered, give the [Shortcuts section](#keyboard-shortcuts) a look below!

## Download

Ready to give BeardedSpice a spin? You can download the [latest release here](https://raw.github.com/beardedspice/beardedspice/distr/publish/releases/BeardedSpice-latest.zip)*, or find a full list of all our [previously released binaries here](https://github.com/beardedspice/beardedspice/releases).

*Mac OS X 10.8 or greater required.

## Features

### *Smart* Mode
> This feature is a **work-in-progress**, we are currently working on bringing it to all our supported sites!

BeardedSpice tries to automatically guess which tab it should control for you. When you press any media key or BeardedSpice shortcut with BeardedSpice open, it will automatically control the site currently playing media, if you have no playing sites, it will try to control the currently focused tab (if it is one of our supported sites) if BeardedSpice failed to do either, it will automatically control the first.

### Automatic Updates
No more checking for new releases on our website, BeardedSpice will automatically notify you when a new release is available.

### Keyboard Shortcuts
BeardedSpice comes with a handy list of Keyboard Shortcuts that can be configured under the `Shortcuts` tab of BeardedSpice Prefrences (available through the menubar icon). Here is a table of Default Keyboard Shortcuts:

Default Shortcut | Action
:---------------:|:------:
`⌘` + `F8` |  Set Focused Browser tab as *Active Player* (effectively directing your commands to that tab)
`⌘` + `F6` | Focus *Active Player* (Shows the tab currently controled by BeardedSpice)
`⌘` + `F10` | Toggle Favorite (Add currently playing track to your favorites on it's site)
`⌘` + `F11` | Show Track information (shows a notification with info about the currently playing tab)

### Multimedia keys of non-Apple keyboards
Using a 3rd-party keyboard? Or even a keyboard with no multimedia keys? No problems, BeardedSpice allows you to set your multimedia keys under the shortcuts tab, so you can use any key (or key combination) of your liking.

### Disabling certain handlers
From the preferences tab, uncheck any types of webpages that you don't want BeardedSpice to have control over. By default, all implemented handlers are enabled.

### Supported Mac OS X applications
- [iTunes](http://www.apple.com/itunes/)
- [Spotify](https://www.spotify.com/)
- [VLC](http://www.videolan.org/vlc/)
- [VOX](http://coppertino.com/)

### Supported Sites
- [8Tracks](http://8tracks.com)
- [22Tracks](http://22tracks.com)
- [Amazon Music](https://www.amazon.com/gp/dmusic/cloudplayer/player)
- [Audible](http://www.audible.com/)
- [AudioMack](http://www.audiomack.com/)
- [BandCamp](http://bandcamp.com)
- [BBC Radio](http://www.bbc.co.uk/radio)
- [Beatguide](https://beatguide.me/)
- [BeatsMusic](http://listen.beatsmusic.com)
- [Blitzr](http://blitzr.com)
- [Bop.fm](http://bop.fm)
- [Brain.fm](https://brain.fm/)
- [BugsMusic](http://www.bugs.co.kr)
- [Chorus](http://wiki.xbmc.org/index.php?title=Add-on:Chorus)
- [Coursera](https://www.coursera.org)
- [Composed](https://www.composed.com/)
- [Deezer](http://deezer.com)
- [Digitally Imported](http://www.di.fm/)
- [focus@will](https://www.focusatwill.com)
- [Google Music](https://play.google.com/music/)
- [GrooveShark](http://grooveshark.com)
- [HotNewHipHop Mixtapes](http://www.hotnewhiphop.com/mixtapes/)
- [HypeMachine](http://hypem.com)
- [iHeart Radio](http://www.iheart.com/)
- [IndieShuffle](http://www.indieshuffle.com)
- [Jango](http://www.jango.com/)
- [Kollekt.FM](https://kollekt.fm/)
- [Last.fm](http://www.last.fm/)
- [Le Tournedisque](http://www.letournedisque.com/)
- [Logitech Media Server](http://www.mysqueezebox.com/) (`Default` web interface only)
- [Mixcloud](https://www.mixcloud.com/)
- [Music For Programming](http://musicforprogramming.net/)
- [Music Unlimited](https://music.sonyentertainmentnetwork.com)
- [Netflix](http://www.netflix.com)
- [NoAdRadio.com](http://www.noadradio.com/)
- [NoonPacific.com](http://noonpacific.com)
- [NRK Radio](https://radio.nrk.no/)
- [Odnoklassniki](http://ok.ru)
- [Overcast.fm](https://overcast.fm)
- [Pandora](http://www.pandora.com)
- [Plex Web](https://app.plex.tv)
- [Pocket Casts](https://play.pocketcasts.com/)
- [Radio Swiss Jazz](http://www.radioswissjazz.ch/)
- [Rdio](http://rdio.com)
- [Rhapsody](http://www.rhapsody.com/)
- [Saavn](http://www.saavn.com/)
- [Shuffler.fm](http://shuffler.fm/)
- [Slacker](http://www.slacker.com/)
- [SomaFM](http://somafm.com)
- [SoundCloud](https://soundcloud.com)
- [Spotify (Web)](https://play.spotify.com)
- [STITCHER](http://www.stitcher.com)
- [Subsonic (personal media streamer)](http://www.subsonic.org/)
- [Synology](http://synology.com)
- [TIDAL (Web)](http://listen.tidal.com/)
- [TuneIn](http://tunein.com/)
- [Twitch TV](http://www.twitch.tv/)
- [Udemy](https://www.udemy.com/)
- [Vimeo](https://vimeo.com/)
- [Vessel](https://www.vessel.com/)
- [VK ("My Music" from vk.com)](http://vk.com/)
- [Watcha Play](https://play.watcha.net/)
- [Wonder FM](http://wonder.fm/)
- [XboxMusic](http://music.xbox.com)
- [Yandex Music](https://music.yandex.ru/)
- [Yandex Radio](https://radio.yandex.ru/)
- [YouTube](https://www.youtube.com/)


#### Don't see your favorite site in the list ?
No Problem, Just [submit an issue](https://github.com/beardedspice/beardedspice/issues/new?title=[App%20Support]). Or, if you're in the mood to try something new, just follow the [Developers' Guide](#developers-guide) below and write your own *media strategy*, integrating a new app in BeardedSpice is really easy and requires minimal objective-c experience and a little of JavaScript basics.


---

#Developers' Guide

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

Media controllers are written as [strategies](https://github.com/beardedspice/beardedspice/blob/master/template-explained.plist). Each strategy defines a collection of Javascript functions to be executed on particular webpages.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<!--
//
//  NewStrategyName.plist
//  BeardedSpice
//
//  Created by You on Today's Date.
//  Copyright (c) 2015 Bearded Spice. All rights reserved.
// OR
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the plist to retain consistent syntax coloring.
-->
<dict>
    <!-- NOTE: This file MUST be viewable in xcode or validated by the plutil utility. -->
    <!-- metadata -->
    <key>version</key>
    <integer>1</integer>
    <key>displayName</key>
    <string>Amazon Music</string>

    <key>accepts</key>
    <dict>
        <key>predicate</key>
        <string>SELF LIKE[c] '*[YOUR-URL-DOMAIN-HERE]*'</string>
        <key>tabValue</key>
        <string>url</string> <!-- current 'url' or 'title' -->
        <!--
        OR
        <key>predicate</key>
        <string>SELF LIKE[c] '[YOUR-TARGET-TITLE-HERE]'</string>
        <key>tabValue</key>
        <string>title</string>
        OR
        <key>script</key>
        <string>some javascript here that returns a boolean value</string>
        -->
    </dict>

    <!-- Relevant javascripts go here.
    - Normal formatting is supported (can copy/paste with newlines and indentations)
    - &amp; is used to escape '&' so the file is readable.
    -->
    <key>isPlaying</key>
    <string></string>

    <key>toggle</key>
    <string></string>

    <key>previous</key>
    <string></string>

    <key>next</key>
    <string></string>

    <key>pause</key>
    <string></string>

    <key>favorite</key>
    <string></string>

    <!-- Generate dictionary of namespaced key/values here. All manipulation should be supported in javascript.
    - Namespaced keys currently supported include: track, album, artist, favorited, image
    -->
    <key>trackInfo</key>
    <string>(function() {
      return {
        'track': 'the name of the track',
        'album': 'the name of the current album',
        'artist': 'the name of the current artist',
        'image': 'the URL to the image associated with the track',
        'favorited': 'true/false if the track has been favorited',
      };
    })();</string>
</dict>
</plist>
```

- `accepts` - takes a `Tab` object and returns `YES` if the strategy can control the given tab.

- `displayName` - must return a unique string describing the controller and will be used as the name shown in the Preferences panel. Some other functions return a Javascript function for the particular action.

- `pause` - a special case used when changing the active tab.

- `isPlaying` - [Optional] If you define the `isPlaying` method, the media strategy will be used in autoselect mechanism, a description of which you may find in [issue #67](https://github.com/beardedspice/beardedspice/issues/67).

- `trackInfo` - [Optional] returns a `BSTrack` object based on the currently accepted 5 keys (see trackInfo in the above xml), which used in notifications for the user.


Update the [`versions.plist`](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategies/versions.plist) to include an instance of your new strategy:

```xml
    <key>AmazonMusic</key>
    <integer>1</integer>
```

Finally, update the [default preferences plist](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/BeardedSpiceUserDefaults.plist) to include your strategy.

## Updating a *Media Strategy*

In the case that a strategy template no longer works with a service, or is missing functionality: All logic for controlling a service should be written in javascript and stored in the appropriate plist file. For example, the [Youtube strategy](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategies/Youtube.plist) has javascript for all five functions as well as partial trackInfo retrieval.

After updating a strategy, update it's version in the ServiceName.plist you've created, as well as the ServiceName entry in the [`versions.plist`](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategies/versions.plist) file. Updating a version means incrementing the number by 1. All references to the service should have the same version when creating a PR.

```xml
    <!-- versions.plist -->
    <key>AmazonMusic</key>
    <integer>1</integer>

    <!-- AmazonMusic.plist -->
    <key>version</key>
    <integer>1</integer>
```

becomes

```xml
    <!-- versions.plist -->
    <key>AmazonMusic</key>
    <integer>2</integer>

    <!-- AmazonMusic.plist -->
    <key>version</key>
    <integer>2</integer>
```

If you find that javascript alone cannot properly control a service, please [create an issue](https://github.com/beardedspice/beardedspice/issues/new?title=%5BDevelopment%20Support%5D) specifying your work branch (as a link), the service in question, and your difficulty as precisely as possible.


# About pull requests
Any progressive improvement is welcome. Also if you are implementing a new strategy, take the trouble to implement all methods with the most modern API for the service, please. PR with a strategy that is not fully implemented for no reason will be rejected.

[![travis-ci](https://travis-ci.org/beardedspice/beardedspice.png)](https://travis-ci.org/beardedspice/beardedspice)

# Contact

- [@chedkid](https://twitter.com/chedkid)
- [@trhodeos](https://twitter.com/trhodeos)
