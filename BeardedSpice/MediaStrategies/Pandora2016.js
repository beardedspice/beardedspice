//
//  Pandora2016.js
//  BeardedSpice
//
//  Created by Bret Martin on 2016-12-19
//
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Pandora (late 2016)",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*pandora.com*'",
    args: ["URL"]
  },

  isPlaying: function () {
    document.querySelector('.Tuner__Control__Play__Button').attributes['data-qa'].value === 'play_button'
  },
  toggle: function () { document.querySelector('.Tuner__Control__Play__Button').click(); },
  next: function () { document.querySelector('.Tuner__Control__Skip__Button').click(); },
  pause: function () { document.querySelector('.Tuner__Control__Play__Button').click(); },
  favorite: function() { document.querySelector('.Tuner__Control__ThumbUp__Button').click(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('.nowPlayingTopInfo__current__trackName .Marquee__wrapper__content__child').innerText,
      'artist': document.querySelector('.nowPlayingTopInfo__current__artistName').innerText,
      'album': document.querySelector('.nowPlayingTopInfo__current__albumName').innerText,
      'image': document.querySelector('[data-qa=album_active_image]').style['background-image'].slice(5, -2),
      'favorited': document.querySelector('[data-qa=thumbs_up_button]').classList.contains('ThumbUpButton--active')
    };
  }
}
