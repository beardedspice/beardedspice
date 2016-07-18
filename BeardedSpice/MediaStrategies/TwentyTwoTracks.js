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
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*22tracks.com*'",
    args: ["URL"]
  },
  isPlaying: function () {},
  toggle: function () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.playpause()},
  next: function () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.next()},
  favorite: function () {},
  previous: function () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.previous()},
  pause: function () {angular.element(document.querySelector('.player .ng-scope')).scope().Audio.pause()},
  trackInfo: function () {}
}
