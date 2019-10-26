//
//  Napster.plist
//  BeardedSpice
//
//  Created by Aaron Pollack on 11/17/15.
//  Copyright © 2015  GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:2,
  displayName:"Napster",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*app.napster.com*'",
    args: ["URL"]
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
      'artist': ($('.player-artist a')[0].innerText).split('- ').slice(1).join('- ').trim(),
      'album': titleize($('.player-wrapper a').attr('href').split('album/')[1]),
      'image': $('.player-album-thumbnail img')[0].src
    };
  }
}
