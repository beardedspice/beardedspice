//
//  SiriusXM.js
//  BeardedSpice
//
//  Created by Amit Chaudhari on 8/17/2017.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "SiriusXM",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*player.siriusxm.com*'",
    args: ["URL"]
  },

  isPlaying: function () {$('.play span').hasClass('RegularPause');},
  toggle:    function () {$('.play span').click();},
  previous:  function () {$('.prev span').click();},
  next:      function () {$('.next span').click();},
  pause:     function () {if($('.play span').hasClass('RegularPause')) $('play span').click();},
  favorite:  function () {$('div.content-type-header--right > button.fav-icon').click();},

  trackInfo: function () {
    return {
        'track': $('div.line-two h2')[1].innerText,
        'album': $('div.line-two h2')[0].innerText,
        'artist': $('div.now-playing-channel-info button h1')[0].innerText,
        'favorited': $('div.content-type-header--right > button.fav-icon').hasClass('RegularFav_B')
    };
  }
}
