//
//  HypeMachine.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Updated to v2 by nVitius on 05/25/17.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version: 2,
  displayName: "HypeMachine",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*hypem.com*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('#playerPlay.pause') !== null; },
  toggle: function () { document.querySelector('#playerPlay').click(); },
  next: function () { document.querySelector('#playerNext').click(); },
  previous: function () { document.querySelector('#playerPrev').click(); },
  favorite: function (){ document.querySelector('#playerFav').click(); },
  pause: function () { document.querySelector('#playerPlay.pause').click(); },
  trackInfo: function () {
    return {
      'artist': now_playing[0].text,
      'track': now_playing[2].text
    }
  }
}
