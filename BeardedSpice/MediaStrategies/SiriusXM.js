//
//  SiriusXM.js
//  BeardedSpice
//
//  Created by Amit Chaudhari on 8/17/2017.
//  Updated by Mathew Peterson on 04/05/2018
//
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 2,
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
  favorite:  function () {$('div.fav-icon > button').click();},

  trackInfo: function () {
    return {
        'artist': $('h1.np-track-artist').text().split("-")[0],
        'track': $('h1.np-track-artist').text().split("-")[1],
        'image': $("#fallbackImg").attr("src")
    };
  }
}
