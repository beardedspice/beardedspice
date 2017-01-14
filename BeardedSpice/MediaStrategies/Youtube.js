//
//  YouTube.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Modifed by Jinseop Kim 15/01/17.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version: 2,
  displayName: "Youtube",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*youtube.com/watch*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return !document.querySelector('#movie_player video').paused;
  },
  toggle: function () {
    document.querySelector('#movie_player .ytp-play-button').click();
  },
  previous: function () {
    var elapsedTime = function () {
      return document.querySelector("#movie_player").getCurrentTime();
    };
    var toSecs = function (s = 0, m = 0, h = 0) {
      return parseInt(s) + parseInt(m) * 60 + parseInt(h) * 60*60;
    };
    var timeTable = function () {
      return [].slice.call(document.querySelectorAll(
        'a[onclick*="seekTo"], a[href^="/watch?v="][href*="&t="][href$="s"]'))
        .map((it) => it.text)
        .map((it) => it.split(':'))
        .map((it) => it.reverse())
        .map((it) => toSecs.apply(null, it))
        .filter((it) => !isNaN(it))
        .sort((a, b) => a-b);
    };

    var cur = elapsedTime() - 5;
    var prev = timeTable().filter((it) => { return cur > it; }).slice(-1)[0];

    if (prev !== undefined)
      yt.www.watch.player.seekTo(prev);
    else
      document.querySelector('#movie_player .ytp-prev-button').click();
  },
  next: function () {
    var elapsedTime = function () {
      return document.querySelector("#movie_player").getCurrentTime();
    };
    var toSecs = function (s = 0, m = 0, h = 0) {
      return parseInt(s) + parseInt(m) * 60 + parseInt(h) * 60*60;
    };
    var timeTable = function () {
      return [].slice.call(document.querySelectorAll(
        'a[onclick*="seekTo"], a[href^="/watch?v="][href*="&t="][href$="s"]'))
        .map((it) => it.text)
        .map((it) => it.split(':'))
        .map((it) => it.reverse())
        .map((it) => toSecs.apply(null, it))
        .filter((it) => !isNaN(it))
        .sort((a, b) => a-b);
    };

    var cur = elapsedTime();
    var next = timeTable().filter((it) => { return cur < it; })[0];

    if (next !== undefined)
      yt.www.watch.player.seekTo(next);
    else
      document.querySelector('#movie_player .ytp-next-button').click();
  },
  pause: function () {
    document.querySelector('#movie_player video').pause();
  },
  trackInfo: function () {
    return {
      'image': document.querySelector('link[itemprop=thumbnailUrl]').getAttribute('href'),
      'track': document.querySelector('meta[itemprop=name]').getAttribute('content'),
      'artist': document.querySelector('.yt-user-info').innerText
    };
  }
};
