//
//  YouTube.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "YouTube",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*youtube.com/watch*'",
    args: ["URL"]
  },
  isPlaying: function () { return !document.querySelector('#movie_player video').paused; },
  toggle: function () { document.querySelector('#movie_player .ytp-play-button').click(); },
  previous: function () { document.querySelector('#movie_player .ytp-prev-button').click(); },
  next: function () { document.querySelector('#movie_player .ytp-next-button').click(); },
  pause: function () { document.querySelector('#movie_player video').pause(); },
  trackInfo: function () {
    return {
      'image': document.querySelector('link[itemprop=thumbnailUrl]').getAttribute('href'),
      'track': document.querySelector('meta[itemprop=name]').getAttribute('content'),
      'artist': document.querySelector('.yt-user-info').innerText
    };
  }
}
