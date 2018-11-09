//
//  YandexMusic.plist
//  BeardedSpice
//
//  Created by Vladimir Burdukov on 3/14/14.
//  Updated by Ivan Tsyganov     on 2/13/18.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.

BSStrategy = {
  version:3,
  displayName:"YandexMusic",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.yandex.*'",
    args: ["URL"]
  },
  isPlaying: function () {return externalAPI.isPlaying();},
  toggle: function () {externalAPI.togglePause();},
  next: function () {externalAPI.next();},
  favorite: function () {externalAPI.toggleLike();},
  previous: function () {externalAPI.prev();},
  pause: function () {externalAPI.togglePause();},
  
  trackInfo: function () {
    return {
      track:  externalAPI.getCurrentTrack().title,
      artist: externalAPI.getCurrentTrack().artists.map(item => item.title).join(', '),
      favorited: externalAPI.getCurrentTrack().liked,
      image: externalAPI.getCurrentTrack().cover.replace('%%', '400x400')
    };
  }
}
