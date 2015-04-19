
# About

[![BeardedSpice](images/bs.jpg)](images/bs.jpg)

BeardedSpice is a menubar application for Mac OSX that allows you to control web based media players with the media keys found on Mac keyboards. It is an extensible application that works with Chrome and Safari, and can control any tab with an applicable media player. BeardedSpice currently supports:

- [8Tracks](http://8tracks.com)
- [22Tracks](http://22tracks.com)
- [Amazon Music](https://amazon.com/gp/dmusic/cloudplayer/player)
- [AudioMack](http://www.audiomack.com/)
- [BandCamp](http://bandcamp.com)
- [BeatsMusic](http://listen.beatsmusic.com)
- [Bop.fm](http://bop.fm)
- [Chorus](http://wiki.xbmc.org/index.php?title=Add-on:Chorus)
- [Deezer](http://deezer.com)
- [Digitally Imported](http://www.di.fm/)
- [focus@will](https://www.focusatwill.com)
- [Google Music](https://play.google.com/music/)
- [GrooveShark](http://grooveshark.com)
- [HypeMachine](http://hypem.com)
- [Last.fm](http://last.fm)
- [Mixcloud](http://mixcloud.com)
- [Music Unlimited](https://music.sonyentertainmentnetwork.com)
- [NoAdRadio.com](http://noadradio.com)
- [Overcast.fm](https://overcast.fm)
- [Pandora](http://pandora.com)
- [Pocket Casts](https://play.pocketcasts.com/)
- [Rdio](http://rdio.com)
- [Shuffler.fm](http://shuffler.fm/tracks)
- [Slacker](http://slacker.com)
- [SomaFM](http://somafm.com)
- [Songza](http://songza.com)
- [SoundCloud](https://soundcloud.com)
- [Spotify (Web)](https://play.spotify.com)
- [STITCHER](http://www.stitcher.com)
- [Synology](http://synology.com)
- [TIDAL](http://listen.tidalhifi.com/)
- [Vimeo](http://vimeo.com)
- [VK ("My Music" from vk.com)](http://vk.com)
- [XboxMusic](http://music.xbox.com)
- [Yandex Music](http://music.yandex.ru)
- [YouTube](http://youtube.com)

If you want another supported app supported, simply open an issue with the tag 'app support'. Or, if you are feeling extra feisty, implement the handler yourself!

BeardedSpice is built with [SPMediaKeyTap](https://github.com/nevyn/SPMediaKeyTap) and works well with other applications listening to media key events.

# Download

Download the [latest release (1.0)](https://raw.github.com/beardedspice/beardedspice/distr/publish/releases/BeardedSpice-latest.zip), or find previous released binaries [here](https://github.com/beardedspice/beardedspice/tree/distr/publish/releases).

Also you can find older releases [here](https://github.com/beardedspice/beardedspice/tree/releases).

Mac OS X 10.8 or greater required.

## Dependencies

We use [CocoaPods](http://cocoapods.org/) to manage all obj-c/cocoa dependences. Install them locally using:
```bash
sudo gem install cocoapods
pod setup
pod install
```

*Always* use BeardedSpice.xcworkspace for development, *not* BeardedSpice.xcodeproject

## Features

### Setting an active tab
Tell BeardedSpice to control a tab by either clicking the menubar icon and selecting a tab from the dropdown, or by pressing the 'Set Active Tab' shortcut when a browser window is active. The shortcut defaults to ⌘+F8, and is configurable in the preferences panel. Switching active tabs will pause the currently active tab (if there is one).

In Chrome you must reset your active tab if you move your tab to a new window. With Safari, reset your active tab when changing the order of your active tab or moving it to a new window.

### Disabling certain handlers
From the preferences menu, uncheck any types of webpages that you don't want BeardedSpice to have control over. By default, all implemented handlers are enabled.

## Writing a Handler

Media controllers are written as [strategies](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategy.h). Each strategy defines a collection of Javascript functions to be excecuted on particular webpages.

```Objective-C
@interface MediaStrategy : NSObject
/**
Returns name of that media stratery. 
*/
-(NSString *) displayName; // Required override in subclass.

/**
Checks tab that it is accepted this strategy.
*/
-(BOOL) accepts:(TabAdapter *)tab; // Required override in subclass.

/**
Checks tab that it is in the playback state.
*/
- (BOOL)isPlaying:(TabAdapter *)tab;

/**
Returns track information object from tab.
*/
- (Track *)trackInfo:(TabAdapter *)tab;

/**
Returns javascript code of the play/pause toggle.
*/
-(NSString *) toggle; // Required override in subclass.

/**
Returns javascript code of the previous track action.
*/
-(NSString *) previous;

/**
Returns javascript code of the next track action.
*/
-(NSString *) next;

/**
Returns javascript code of the pausing action.
Used mainly for pausing before switching active tabs.
*/
-(NSString *) pause; // Required override in subclass.

/**
Returns javascript code of the "favorite" toggle.
*/
-(NSString *) favorite;

/**
Helper method for obtaining album artwork from url string
*/
- (NSImage *)imageByUrlString:(NSString *)urlString;

@end
```

The `accepts` method takes a `Tab` object and returns `YES` if the strategy can control the given tab. `displayName` must return a unique string describing the controller and will be used as the name shown in the Preferences panel. Some other functions return a Javascript function for the particular action. `pause` is a special case and is used when changing the active tab. Optional but useful methods `isPlaying` and `trackInfo`. If you will define `isPlaying` method, media strategy will be used in autoselect mechanism, description of it you may see in issue #67. `trackInfo` method returns `Track` object, which used in notifications for user.

Define these properties of the `Track` object:
```Objective-C
@property NSString *track;
@property NSString *album;
@property NSString *artist;
@property NSImage *image;
@property NSNumber *favorited;
```

A sample strategy for YandexMusic:

```Objective-C
@implementation YandexMusicStrategy

-(id) init
{
self = [super init];
if (self) {
predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.yandex.*'"];
}
return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{

NSNumber *value = [tab executeJavascript:@"(function(){return JSON.parse($('body').attr('data-unity-state')).playing;})()"];

return [value boolValue];
}

-(NSString *) toggle
{
return @"(function(){document.querySelector('div.b-jambox__play, .player-controls__btn_play').click()})()";
}

-(NSString *) previous
{
return @"(function(){document.querySelector('div.b-jambox__prev, .player-controls__btn_prev').click()})()";
}

-(NSString *) next
{
return @"(function(){document.querySelector('div.b-jambox__next, .player-controls__btn_next').click()})()";
}

-(NSString *) pause
{
return @"(function(){\
var e=document.querySelector('.player-controls__btn_play');\
if(e!=null){\
if(e.classList.contains('player-controls__btn_pause')){e.click()}\
}else{\
var e=document.querySelector('div.b-jambox__play');\
if(e.classList.contains('b-jambox__playing')){e.click()}\
}\
})()";
}

-(NSString *) displayName
{
return @"YandexMusic";
}

- (NSString *)favorite{

return @"(function(){$('.player-controls .like.player-controls__btn').click();})()";
}

- (Track *)trackInfo:(TabAdapter *)tab{

NSDictionary *info = [tab executeJavascript:@"(function(){return $.extend(JSON.parse($('body').attr('data-unity-state')), ({'favorited': ($('.player-controls .like.like_on.player-controls__btn').length)}))})()"];

Track *track = [Track new];

track.track = info[@"title"];
track.artist = info[@"artist"];
track.image = [self imageByUrlString:info[@"albumArt"]];
track.favorited = info[@"favorited"];

return track;
}

@end
```

Update the [`MediaStrategyRegistry`](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/MediaStrategyRegistry.m) to include an instance of your new strategy:

```Objective-C
+(NSArray *) getDefaultMediaStrategies
{
        DefaultMediaStrategies = [NSArray arrayWithObjects:
                                  // ...
                                  [GoogleMusicStrategy new],
                                  [RdioStrategy new],
                                  // add your new strategy!
                                  [YandexMusicStrategy new],
                                  nil];
}
```

Finally, update the [default preferences plist](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/BeardedSpiceUserDefaults.plist) to include your strategy.

[![travis-ci](https://travis-ci.org/beardedspice/beardedspice.png)](https://travis-ci.org/beardedspice/beardedspice)

# Contact

- [@chedkid](https://twitter.com/chedkid)
- [@trhodeos](https://twitter.com/trhodeos)
