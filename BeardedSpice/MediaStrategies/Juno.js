// Beatport.plist
// BeardedSpice

// Created by Daniel Bayley on 01/07/16.
// Copyright (c) 2016 Daniel Bayley. All rights reserved.

BSStrategy = {
  version: 1,
  displayName: "Juno",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*juno.co.uk/flashplayer*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('.player-btn-play').childNodes[0].getAttribute('class') == "glyphicon glyphicon-player-play"; },
  toggle: function () {
    var btn = document.querySelector('.player-btn-play');
    var playing = document.querySelector('.player-btn-play').childNodes[0].getAttribute('class') == "glyphicon glyphicon-player-play";
    if (playing) { btn.click();} else { btn.click();}
  },
  previous: function () { document.querySelector('.player-btn-back').click();},
  next: function () { document.querySelector('.player-btn-forward').click();},
  pause: function () { document.querySelector('.player-btn-play').click();},
  favorite: function () { document.querySelector('.player-btn-wishlist').click();},
  trackInfo: function () {
    var info = document.querySelectorAll('.track-artist a'),
        artists = [];
    for (i = 0; i < info.length; i++) { artists.push(info[i].innerText);}

    artists = artists.filter(function(item, pos, self) {
      return self.indexOf(item) == pos;
    });
    var track = document.querySelector('.primary-title').innerText +
        ' ('+ document.querySelector('.remixed').innerText +')';

    var artwork = document.querySelector('.track-artwork').getAttribute('src')
                 .replace(/[0-9]+x[0-9]+/,'600x600');
    return {
      track: track,
      //album: album,
      artist: artists.join(", "), //(" & ")
      image: artwork,
      favorited: document.querySelector('.buy-button.in-cart') != null
    };
  }
}
