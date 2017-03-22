[![travis-ci](https://travis-ci.org/beardedspice/beardedspice.png)](https://travis-ci.org/beardedspice/beardedspice)

# Common Issues

It's asked that anyone with an issue check the [Wiki Section](https://github.com/beardedspice/beardedspice/wiki) before posting a new issue.

# Users Guide

[![BeardedSpice](images/bs.jpg)](images/bs.jpg)

## What?
BeardedSpice allows you to control web based media players (Like *SoundCloud*, and *YouTube* ... [List of supported sites to date](#supported-sites)) and some native apps with the media keys found on Mac keyboards.

## How?
All you need to do is just open your favorite [supported media site](#supported-sites) in either Chrome or Safari, then click on BeardedSpice's Menubar icon <img src="images/icon20x19.png" /> and select the website you want to control using your media keys.

#### Interested in doing it with a keyboard-shortcut?
We've got you covered, give the [Shortcuts section](#keyboard-shortcuts) a look below!

## Download

Ready to give BeardedSpice a spin? You can download the [latest release here](https://raw.github.com/beardedspice/beardedspice/distr/publish/releases/BeardedSpice-latest.zip)*, or find a full list of all our [previously released binaries here](https://github.com/beardedspice/beardedspice/releases).

*Mac OS X 10.9 or greater required.

## Features

### *Smart* Mode
> This feature is a **work-in-progress**, we are currently working on bringing it to all our supported sites!

BeardedSpice tries to automatically guess which tab it should control for you. When you press any media key or BeardedSpice shortcut with BeardedSpice open, it will automatically control the site currently playing media, if you have no playing sites, it will try to control the currently focused tab (if it is one of our supported sites) if BeardedSpice failed to do either, it will automatically control the first.

### Automatic Updates
No more checking for new releases on our website, BeardedSpice will automatically notify you when a new release is available.

### Up to Date Media Strategies
First, what is a Media Strategy? This is what we call a [template](https://github.com/beardedspice/beardedspice/blob/master/template-explained.js) with custom javascript aimed at a specific website, allowing the BeardedSpice program to control it with the media keys.

Second, the Compatibility Updates option allows you to check for added or changed Media Strategies that were contributed since the last official release.

### Keyboard Shortcuts
BeardedSpice comes with a handy list of Keyboard Shortcuts that can be configured under the `Shortcuts` tab of BeardedSpice Preferences (available through the menubar icon). Here is a table of Default Keyboard Shortcuts:

Default Shortcut | Action
:---------------:|:------:
`⌘` + `F8` |  Set Focused Browser tab as *Active Player* (effectively directing your commands to that tab)
`⌘` + `F6` | Focus *Active Player* (Shows the tab currently controlled by BeardedSpice)
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
- [Downcast](http://downcast.fm/)
- [Vivaldi](https://vivaldi.com)

### Supported Sites
- [8Tracks](http://8tracks.com)
- [22Tracks](http://22tracks.com)
- [Amazon Music](https://www.amazon.com/gp/dmusic/cloudplayer/player)
- [Apple Developer](https://developer.apple.com/videos/)
- [Audible](http://www.audible.com/)
- [AudioMack](http://www.audiomack.com/)
- [BandCamp](http://bandcamp.com)
- [BBC Radio](http://www.bbc.co.uk/radio)
- [Beatguide](https://beatguide.me/)
- [Beatport](https://beatport.com)
- [Blitzr](http://blitzr.com)
- [Bop.fm](http://bop.fm)
- [Brain.fm](https://brain.fm/)
- [BugsMusic](http://www.bugs.co.kr)
- [Chorus](http://wiki.xbmc.org/index.php?title=Add-on:Chorus)
- [Coursera](https://www.coursera.org)
- [Composed](https://www.composed.com/)
- [Cozy Cloud](https://cozy.io/en/) ([cozy-music](https://github.com/cozy-labs/cozy-music) application)
- [Dailymotion](https://www.dailymotion.com)
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
- [ListenOnRepeat](http://listenonrepeat.com/)
- [Logitech Media Server](http://www.mysqueezebox.com/) (`Default` web interface only)
- [Mixcloud](https://www.mixcloud.com/)
- [Music For Programming](http://musicforprogramming.net/)
- [Music Unlimited](https://music.sonyentertainmentnetwork.com)
- [Napster](https://www.napster.com/)
- [Netflix](http://www.netflix.com)
- [NoAdRadio.com](http://www.noadradio.com/)
- [NoonPacific.com](http://noonpacific.com)
- [NPR One](http://one.npr.org/)
- [NRK Radio](https://radio.nrk.no/)
- [Odnoklassniki](http://ok.ru)
- [Overcast.fm](https://overcast.fm)
- [Pakartot](http://www.pakartot.lt)
- [Pandora](http://www.pandora.com)
- [Phish.in](http://phish.in)
- [PhishTracks](http://PhishTracks.com)
- [Plex Web](https://app.plex.tv)
- [Pocket Casts](https://play.pocketcasts.com/)
- [ProductHunt](https://www.producthunt.com/podcasts/)
- [Qobuz](http://player.qobuz.com/)
- [Radio Swiss Jazz](http://www.radioswissjazz.ch/)
- [Rdio](http://rdio.com)
- [Saavn](http://www.saavn.com/)
- [Shuffler.fm](http://shuffler.fm/)
- [Slacker](http://www.slacker.com/)
- [SomaFM](http://somafm.com)
- [SoundCloud](https://soundcloud.com)
- [Spotify (Web)](https://play.spotify.com)
- [Stingray](https://webplayer.stingray.com)
- [STITCHER](http://www.stitcher.com/)
- [Style Jukebox] (http://play.stylejukebox.com/)
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
- [Xiami](http://www.xiami.com)
- [Yandex Music](https://music.yandex.ru/)
- [Yandex Radio](https://radio.yandex.ru/)
- [YouTube](https://www.youtube.com/)
- [Zing MP3](https://mp3.zing.vn)
- [Zvooq](http://zvooq.com)

#### Don't see your favorite site in the list ?
No Problem, Just [submit an issue](https://github.com/beardedspice/beardedspice/issues/new?title=[App%20Support]).

#### Want to Contribute?
Please do! Contributions are the lifeblood of the project, and yours helps keep us moving forward.

If you just want to add a new website to the list above, checkout the [app support request list](https://github.com/beardedspice/beardedspice/labels/app%20support). The **[Developer How-To Guide](docs/developers-guide-web.md)** has the information needed to get started (and don't be afraid to ask questions!).
Websites only need some (easily learned) knowledge of javascript and maybe [webpage delving with devtool](https://zapier.com/blog/inspect-element-tutorial/) (also [Chrome's official documentation](https://developers.google.com/web/tools/chrome-devtools/)). 

Integrating a new native app (aka Chrome, Firefox, Spotify) in BeardedSpice is a little more complicated and requires **NO objective-c experience**. Many [good](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/Tabs/SpotifyTabAdapter.m) [examples](https://github.com/beardedspice/beardedspice/blob/master/BeardedSpice/Tabs/iTunesTabAdapter.m) exist. However, some apps simply aren't compatible at this time.
