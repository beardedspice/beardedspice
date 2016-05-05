//
//  AmazonMusic.plist
//  BeardedSpice
//
//  Created by Brandon P Smith on 7/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Amazon Music",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*amazon.com/gp/dmusic/cloudplayer/*'",
    args:"url"
  },
  isPlaying: function isPlaying () {return window.amznMusic.widgets.player.isPlaying();},
  toggle: function toggle () {return window.amznMusic.widgets.player.playHash('togglePlay')},
  next: function next () {return window.amznMusic.widgets.player.playHash('next')},
  previous: function previous () {return window.amznMusic.widgets.player.playHash('previous')},
  pause: function pause () {window.amznMusic.widgets.player.pause();},
  trackInfo: function trackInfo () {
    var data = window.amznMusic.widgets.player.getCurrent()['metadata'];
    return {
        'track': data['title'],
        'artist': data['albumName'],
        'album': data['artistName'],
        'image': data['albumCoverImageSmall']
    }
  }
}
