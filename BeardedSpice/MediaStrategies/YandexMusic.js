//
//  YandexMusic.plist
//  BeardedSpice
//
//  Created by Vladimir Burdukov on 3/14/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"YandexMusic",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*music.yandex.*'",
    args: "url"
  },
  isPlaying: function () {return (document.querySelector('.player-controls__btn_play.player-controls__btn_pause') != null);},
  toggle: function () { document.querySelector('div.b-jambox__play, .player-controls__btn_play').click()},
  next: function () {document.querySelector('div.b-jambox__next, .player-controls__btn_next').click()},
  favorite: function () {$('.player-controls .like.player-controls__btn').click();},
  previous: function () {document.querySelector('div.b-jambox__prev, .player-controls__btn_prev').click()},
  pause: function () {
    var e = document.querySelector('.player-controls__btn_play');
    if(e!=null) {
      if(e.classList.contains('player-controls__btn_pause')){
        e.click()
      }
    } else {
      var e=document.querySelector('div.b-jambox__play');
      if(e.classList.contains('b-jambox__playing')){
        e.click()
      }
    }
  },
  trackInfo: function () {
    var track = $('.track.track_type_player').get(0);
    return {
      'track': $('.track__title', track)[0].innerText,
      'artist': $('.track__artists', track)[0].innerText,
      'favorited': $('.player-controls__track-controls .like.player-controls__btn').hasClass('like_on'),
      'image': $('.album-cover', track).attr('src')
    }
  }
}
