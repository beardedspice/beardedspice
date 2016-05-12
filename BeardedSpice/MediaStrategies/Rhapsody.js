//
//  Rhapsody.plist
//  BeardedSpice
//
//  Created by Aaron Pollack on 11/17/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Rhapsody",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*app.rhapsody.com*'",
    args:"url"
  },
  isPlaying: function () {return !!$('.player-play-button .icon-pause2').length;},
  toggle: function () {
    if ($('.player-play-button .icon-pause2').length) {
      $('.player-play-button .icon-pause2').click();
    } else {
      $('.player-play-button .icon-play-button').click()
    }
  },
  next: function () {$('.player-advance-button').click();},
  favorite: function () {$('.favorite-button').click()},
  previous: function () {$('.player-rewind-button').click();},
  pause: function () {$('.player-play-button .icon-pause2').click();},
  trackInfo: function () {
    function titleize(slug) {
      var words = slug.split('-');
      return words.map(function(word) {
        return word.charAt(0).toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }
    return {
      'track': $('.player-track a')[0].innerText,
      'artist': ($('.player-artist a')[0].innerHTML).split('- ').slice(1).join('- ').trim(),
      'album': titleize($('.player-wrapper a').attr('href').split('album/')[1]),
      'image': $('.player-album-thumbnail img')[0].src
    };
  }
}
