// Beatport.plist
// BeardedSpice

// Created by Daniel Bayley on 01/07/16.
// Copyright (c) 2016 Daniel Bayley. All rights reserved.

BSStrategy = {
  version: 1,
  displayName: "Beatport",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*beatport.com*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('.play-button.play') === null },
  toggle: function () {
    var play = document.querySelector('.play-button.play'),
        pause = document.querySelector('.play-button.pause');
    if (pause != null) { pause.click();} else { play.click();}
  },
  previous: function () { document.querySelector('.prev-button').click();},
  next: function () { document.querySelector('.next-button').click();},
  pause: function () { document.querySelector('.play-button.pause').click();},
  favorite: function () { document.querySelector('.add-to-default').click();},
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
