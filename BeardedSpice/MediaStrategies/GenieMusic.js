//
//  GenieMusic.js
//  BeardedSpice
//
//  Created by kimtree on 10/18/2017.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 2,
  displayName: "GenieMusic",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*genie.co.kr/player*'",
    args: ["URL"]
  },
  isPlaying: function () { return flowplayer().playing; },
  toggle: function () { flowplayer().toggle(); },
  previous: function () { fnPlayPrev(); },
  next: function () { fnPlayNext(); },
  pause: function () { flowplayer().pause(); },
  favorite:  function () { fnPlayerLikeAct(); },
  trackInfo: function () {
    return {
        'track': document.getElementById("SongTitleArea").textContent,
        'album': document.getElementById("AlbumImgArea").getElementsByTagName("img")[0].getAttribute("alt"),
        'artist': document.getElementById("ArtistNameArea").textContent,
        'image': 'http:' + document.getElementById("AlbumImgArea").getElementsByTagName("img")[0].getAttribute("src"),
        'favorited': (document.getElementsByClassName("btn-like")[0].className.indexOf("active") > 0)
    }
  }
}
