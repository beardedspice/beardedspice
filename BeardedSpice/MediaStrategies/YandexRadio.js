//
//  YandexMusic.plist
//  BeardedSpice
//
//  Created by Leonid Ponomarev 15.06.15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"YandexRadio",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*radio.yandex.*'",
    args: ["URL"]
  },
  isPlaying: function () { return !!document.querySelector('body.body_state_playing'); },
  toggle: function () { document.querySelector('.player-controls__play').click(); },
  next: function () { document.querySelector('.slider__item_track.slider__item_next .slider__item-bar').click(); },
  favorite: function () { document.querySelector('.player-controls__bar .button.like.like_action_like').click(); },
  previous: function () {},
  pause: function () { document.querySelector('.player-controls__play').click(); },
  trackInfo:function () {
    return {
      track: document.querySelector('.player-controls__title').title,
      artist: document.querySelector('.player-controls__artists').title,
      favorited: !!document.querySelector('.player-controls__bar .button.like.like_action_like.button_checked'),
      image: document.querySelector('.slider__item_track.slider__item_playing .track__cover')
        .style.backgroundImage.match(/url\(\"\/\/(.*)\"/)[1]
    };
  }
}
