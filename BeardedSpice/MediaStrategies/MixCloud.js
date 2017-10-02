//
//  MixCloud.plist
//  BeardedSpice
//
//  Created by Tyler Rhodes on 2/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:4,
  displayName:"Mixcloud",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*www.mixcloud.com*'",
    args: ["URL"]
  },
  isPlaying: function() {return (document.querySelector('.player-control.pause-state') != null)},
  pause: function () { var aButton = document.querySelector('.player-control.pause-state'); if(aButton) aButton.click() },
  toggle: function () { document.querySelector('.player-control').click(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('.player-cloudcast-title').text,
      'artist': document.querySelector('.player-cloudcast-author-link').text,
      'image' : document.querySelector('.player .player-cloudcast-image img').getAttribute('src')
    }
  }
}
