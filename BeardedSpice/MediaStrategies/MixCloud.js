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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*mixcloud.com*'",
    args:"url"
  },
  pause: function pause () { document.querySelector('.pause-state').click() },
  toggle: function toggle () { document.querySelector('.player-control').click(); },
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelector('.player-cloudcast-title').text,
      'artist': document.querySelector('.player-cloudcast-author-link').text,
    }
  }
}
