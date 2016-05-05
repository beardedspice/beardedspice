//
//  TwentyTwoTracks.plist
//  BeardedSpice
//
//  Created by Jan Pochyla on 08/26/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"22tracks",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*22tracks.com*'",
    args:"url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.playpause()},
  next: function next () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.next()},
  favorite: function favorite () {},
  previous: function previous () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.previous()},
  pause: function pause () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.pause()},
  trackInfo: function trackInfo () {}
}
