//
//  RedditMusic.plist
//  BeardedSpice
//
//  Created by Travis Emery on 11/16/16.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"RedditMusic",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*reddit.musicplayer.io*'",
    args: ["URL"]
  },
  isPlaying: function () { return !document.querySelector('#movie_player video').paused; },
  toggle: function () { document.querySelector('.controls .item.play.button').click(); },
  previous: function () { document.querySelector('.controls .item.backward.button').click(); },
  next: function () { document.querySelector('.controls .item.forward.button').click(); },
  pause: function () { document.querySelector('#movie_player video').pause(); },
  trackInfo: function () {
    return {
        'image': document.querySelector('link[itemprop=thumbnailUrl]').getAttribute('href'),
        'track': document.querySelector('meta[itemprop=name]').getAttribute('content'),
        'artist': document.querySelector('.yt-user-info').innerText
    };
  }
}
