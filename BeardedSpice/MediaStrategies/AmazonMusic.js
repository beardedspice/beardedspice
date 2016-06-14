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
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.amazon.*'",
    args: ["URL"]
  },
  isPlaying: function () {return window.amznMusic.widgets.player.isPlaying();},
  toggle: function () {return window.amznMusic.widgets.player.playHash('togglePlay')},
  next: function () {return window.amznMusic.widgets.player.playHash('next')},
  previous: function () {return window.amznMusic.widgets.player.playHash('previous')},
  pause: function () {window.amznMusic.widgets.player.pause();},
  trackInfo: function () {
    var data = window.amznMusic.widgets.player.getCurrent()['metadata'];
    return {
        'track': data['title'],
        'artist': data['albumName'],
        'album': data['artistName'],
        'image': data['albumCoverImageSmall']
    }
  }
}
