//
//  GenieMusic.js
//  BeardedSpice
//
//  Created by Pnamu on 2017. 03. 05
//  Copyright 짤 2017 BeardedSpice. All rights reserved.
//

BSStrategy = {
  version:1,
  displayName:"GenieMusic",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*genie.co.kr/player*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.getElementsByClassName('pause')[0] == undefined; },
  toggle: function () { document.getElementById('PlayBtnArea').click(); },
  next: function () { document.getElementsByClassName('control-2')[0].getElementsByClassName('next')[0].click(); },
  previous: function () { document.getElementsByClassName('control-2')[0].getElementsByClassName('prev')[0].click(); },
  pause: function () {document.getElementById('PlayBtnArea').click(); },
  trackInfo: function () {
    return {
        image: 'http:' + document.getElementById("AlbumImgArea").getElementsByTagName('img')[0].getAttribute("src"),
        track: document.getElementById("SongTitleArea").getAttribute("title"),
        artist: document.getElementById("ArtistNameArea").getElementsByTagName("span")[0].textContent
    }
  }
}
