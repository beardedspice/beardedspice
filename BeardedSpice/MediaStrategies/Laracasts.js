//
//  Laracasts.js
//  BeardedSpice
//
//  Created by Shane Welldon on 26/06/2015.
//  Converted to js strategy by Alex Evers 10/29/2016.
//
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Laracasts",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*laracasts.com*'",
    args: ["URL"]
  },

  isPlaying: function () { return !videojs('laracasts-video_html5_api').paused(); },
  toggle:    function () {
    var p = videojs('laracasts-video_html5_api');
    return p.paused() ? p.play() : p.pause();
  },
  previous:  function () { /* switch to previous track if any */ },
  next:      function () { /* switch to next track if any */ },
  pause:     function () { return videojs('laracasts-video_html5_api').pause(); },
  favorite:  function () { /* toggles favorite on/off */},
}
// The file must have an empty line at the end.
