//
//  RadioParadise.plist
//  BeardedSpice
//
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "Radio Paradise",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*radioparadise.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return document.querySelector('#play-button').getAttribute('title') === "Pause";
  },
  toggle: function () {
    document.querySelector('#play-button').click();
  },
  previous: function () {},
  next: function () {
    document.querySelector('#skip-button').click();
  },
  pause: function () {
    if (document.querySelector('#play-button').getAttribute('title') === "Pause") {
      document.querySelector('#play-button').click();
    }
  },
  favorite: function () {},
  trackInfo: function () {
    var isMiniPlayer = document.querySelector('app-player-mini-controller') !== null;
    var track = isMiniPlayer ? document.querySelector('app-player-mini-controller div.player-title').innerText 
      : document.querySelector('#now_playing .title a:first-child').childNodes[0].textContent;
    var album = isMiniPlayer ? null 
      : document.querySelector('#now_playing .title .album').innerText;
    var artist = isMiniPlayer ? document.querySelector('app-player-mini-controller div.player-artist').innerText 
      : document.querySelector('#now_playing .title .artist').innerText;
    var image = isMiniPlayer ? document.querySelector('app-player-mini-controller img.player-cover').getAttribute("src")
      : document.querySelector('#now_playing .now_playing_cover').getAttribute('src');

    return {
        'track': track,
        'album': album,
        'artist': artist,
        'image': image,
    };
  }
}

