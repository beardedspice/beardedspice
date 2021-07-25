//
//  HotNewHipHop.plist
//  BeardedSpice
//
//  Created by Ivan Doroshenko on 11/7/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"HotNewHipHop",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*hotnewhiphop.com*'",
    args: ["URL"]
  },
  isPlaying: function () { $('.jp-play:hidden').length },
  toggle: function () {
    var isPlaying = $('.jp-play:hidden').length;
    if (isPlaying) { $('.jp-pause').click(); }
    else { $('.jp-play').click(); }
  },
  next: function () {$(".jp-next").click();},
  previous: function () {$(".jp-previous").click();},
  pause: function () {$('.jp-pause').click();},
  trackInfo: function () {
    var album = $('.mixtape-info-title')[0].innerText;
    var artist = $('.mixtape-info-artist')[0].innerText;
    return {
      'track': $('.jp-playlist-current .mixtape-trackTitle .display')[0].innerText,
      'album': album.replace(/\s+/, ''),
      'artist': artist.replace(/\s+/, ''),
      'image': $('.mixtape-cover-img img')[0].getAttribute('src')
    }
  }
}
