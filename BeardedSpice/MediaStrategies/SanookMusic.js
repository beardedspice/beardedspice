//
//  SanookMusic.js
//  BeardedSpice
//
//  Created by Vorathep Sumetphong on 10/16/2017.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Sanook Music",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*music.sanook.com*'",
    args: ["URL"]
  },

  isPlaying: function () { !document.querySelector("#btnPlay").classList.contains("joox-play") },
  toggle:    function () { document.querySelector("#btnPlay").click() },
  previous:  function () { document.querySelector("#btnPrev").click() },
  next:      function () { document.querySelector("#btnNext").click() },
  pause:     function () { var isPlaying = !document.querySelector("#btnPlay").classList.contains("joox-play"); if(isPlaying) { document.querySelector("#btnPlay").click() } },

  trackInfo: function () {
    return {
        'track': document.querySelector("#lblSongName").innerHTML,
        'artist': document.querySelector("#lblSinger").innerHTML,
        'image': document.querySelector("#jooxAlbum").src,
    };
  }
}
