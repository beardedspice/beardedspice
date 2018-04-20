//
//  Laracasts.js
//  BeardedSpice
//
//  Created by nVitius on 05/25/2017.
//  Updated by Carl Evison on 21/04/2018.
//
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 2,
  displayName: "Laracasts",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*laracasts.com*'",
    args: ["URL"]
  },

  isPlaying: function () {},
   toggle: function () {
    var iframe = document.querySelector('iframe');
    var player = new Vimeo.Player(iframe);

    player.getPaused().then(function(paused) {
      paused ? player.play() : player.pause()
    });
  },
  previous:  function () {},
  next:      function () {},
  pause:     function () {},
  favorite:  function () {},
}
