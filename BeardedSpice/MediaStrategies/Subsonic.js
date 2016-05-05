//
//  Subsonic.plist
//  BeardedSpice
//
//  Created by Michael Alden on 6/16/2015.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Subsonic",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*Subsonic*'",
    args:"url"
  },
  isPlaying: function isPlaying () { return window.frames['playQueue'].jwplayer().getState() === 'PLAYING' },
  toggle:function toggle () { window.frames['playQueue'].jwplayer().play() },
  next:function next () { window.frames['playQueue'].onNext() },
  favorite: function () { window.frames['playQueue'].onStar(window.frames['playQueue']).getCurrentSongIndex() },
  previous:function previous () { window.frames['playQueue'].onPrevious() },
  pause:function pause () { window.frames['playQueue'].jwplayer().pause(true) },
  trackInfo: function trackInfo () {
    var index = window.frames['playQueue'].getCurrentSongIndex();
    var playQueue = window.frames['playQueue'].songs[index];
    var ret = playQueue.getCurrentSongIndex();
    return {
        'title': ret.title,
        'album': ret.album,
        'artist': ret.artist,
        'favorited': ret.starred,
        'image': ret.albumUrl.replace('main', 'coverArt').concat('&size=128'),
    };
  }
}
