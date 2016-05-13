//
//  HypeMachine.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"HypeMachine",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*hypem.com*'",
    args: ["URL"]
  },
  toggle: function () {return window.togglePlay()},
  next: function () {return window.nextTrack()},
  previous: function () {return window.prevTrack()},
  favorite: function (){return window.toggleFavoriteItem()},
  pause: function () {return window.currentPlayerObj[0].pause()},
  trackInfo: function () {
    return {
      'artist': now_playing[0].text,
      'track': now_playing[2].text
    }
  }
}
