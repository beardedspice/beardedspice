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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*hypem.com*'",
    args:"url"
  },
  toggle: function toggle () {return window.togglePlay()},
  next: function next () {return window.nextTrack()},
  previous: function previous () {return window.prevTrack()},
  favorite: function favorite (){return window.toggleFavoriteItem()},
  pause: function pause () {return window.currentPlayerObj[0].pause()},
  trackInfo: function trackInfo () {
    return {
      'artist': now_playing[0].text,
      'track': now_playing[2].text
    }
  }
}
