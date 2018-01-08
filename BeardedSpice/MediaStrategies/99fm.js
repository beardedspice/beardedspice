//
//  99fm
//  BeardedSpice
//
//  Created by Roy Sommer on 01/08/18.
//  Copyright (c) 2018 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "99fm",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*eco99fm.maariv.co.il/music_channel/*'",
    args: ["URL"]
  },
  isPlaying: function () { return !document.querySelector('video.vjs-tech').paused; },
  toggle: function () { document.querySelector('button.vjs-play-control').click(); },
  previous: function () { document.querySelector('video.vjs-tech').currentTime -= 30; },
  next: function () { document.querySelector('video.vjs-tech').currentTime += 30; },
  pause: function () { document.querySelector('video.vjs-tech').pause(); },
  trackInfo: function () {
    return {
      'image': 'http://eco99fm.maariv.co.il' + document.querySelector('.vjs-poster').style.backgroundImage.replace('url("', '').replace('")', ''),
      'track': document.querySelector('.newtopSetTitle').innerText,
      'artist': '99fm',
      'progress': document.querySelector('.vjs-current-time').innerText.replace('Current Time ', '').trim() + ' / ' + document.querySelector('.vjs-duration-display').innerText.replace('Duration Time ', '').trim()
    };
  }
}