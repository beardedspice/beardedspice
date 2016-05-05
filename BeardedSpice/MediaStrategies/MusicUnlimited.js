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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*music.sonyentertainmentnetwork.com*'",
    args:"url"
  },
  toggle: function toggle () { document.querySelector('#PlayerPlayPause').click(); },
  next: function next () { document.querySelector('#PlayerNext').click(); },
  previous: function previous () { document.querySelector('#PlayerPrevious').click(); },
  favorite: function favorite () { document.querySelector('#PlayerLike').click(); }
}
