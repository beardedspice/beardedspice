//
//  MusicUnlimited.plist
//  BeardedSpice
//
//  Created by Tyler Rhodes on 2/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"MusicUnlimited",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.sonyentertainmentnetwork.com*'",
    args: ["URL"]
  },
  toggle: function () { document.querySelector('#PlayerPlayPause').click(); },
  next: function () { document.querySelector('#PlayerNext').click(); },
  previous: function () { document.querySelector('#PlayerPrevious').click(); },
  favorite: function () { document.querySelector('#PlayerLike').click(); }
}
