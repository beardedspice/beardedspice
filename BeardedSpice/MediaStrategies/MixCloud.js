//
//  MixCloud.plist
//  BeardedSpice
//
//  Created by Tyler Rhodes on 2/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"MixCloud",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*mixcloud.com*'",
    args: ["URL"]
  },
  pause: function () { document.querySelector('.pause-state').click() },
  toggle: function () { document.querySelector('.player-control').click(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('.player-cloudcast-title').text,
      'artist': document.querySelector('.player-cloudcast-author-link').text,
    }
  }
}
