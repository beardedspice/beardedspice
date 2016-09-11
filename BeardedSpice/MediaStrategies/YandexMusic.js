//
//  YandexMusic.plist
//  BeardedSpice
//
//  Created by Vladimir Burdukov on 3/14/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"YandexMusic",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.yandex.*'",
    args: ["URL"]
  },
  isPlaying: function () {return !!document.querySelector('body.body_show-pause');},
  toggle: function () {document.querySelector('div.b-jambox__play, .player-controls__btn_play').click();},
  next: function () {document.querySelector('div.b-jambox__next, .player-controls__btn_next').click();},
  favorite: function () { document.querySelector('.player-controls .like.player-controls__btn').click(); },
  previous: function () {document.querySelector('div.b-jambox__prev, .player-controls__btn_prev').click();},
  pause: function () {document.querySelector('.player-controls__btn.player-controls__btn_play').click();},
  trackInfo: function () {
    return {
      track:  document.querySelector('.track.track_type_player .track__title').innerText,
      artist: document.querySelector('.track.track_type_player .track__artists').innerText,
      favorited: !!document.querySelector('.player-controls__track-controls .like.like_on'),
      image: document.querySelector('.album-cover').src.replace('50x50', '600x600')
    };
  }
}
