//
//  KollektFm.plist
//  BeardedSpice
//
//  Created by Wiert Omta on 23/1/2015.
//  Copyright (c) 2015 Wiert Omta. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Kollekt.FM",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*kollekt.fm*'",
    args:"url"
  },
  toggle: function toggle() { $( "i[ng-click='playPause()']" ).click; },
  next: function next() { $( "i[ng-click='next()']" ).click; },
  favorite: function favorite() { $( "i[ng-click='favoriteTrack(activeTrack())']" ).click; },
  previous: function previous() { $( "i[ng-click='previous()']" ).click; },
  pause: function pause() { $( ".fa-pause" ).click; }
}
