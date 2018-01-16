
//
//  SynthwaveClub.plist
//  BeardedSpice
//
//  Created by Chris Tate-Davies on 01/16/18.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"SynthwaveClub",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*synthwave.club*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('#play').style.display == "block" },
  toggle: function () {
    document.querySelector('#play').style.display == "none" ? document.querySelector('#pause').click() : document.querySelector('#play').click();
  },
  previous: function () { document.querySelector('#prev').click(); },
  next: function () { document.querySelector('#next').click(); },
  pause: function () { document.querySelector('#pause').click(); },
  trackInfo: function () {
    let track_title = document.querySelector('.track-name').innerText;
    let track_artist = document.querySelector('.user-name-track').innerText;
    track_artist = track_artist.replace(" - " + track_title, "");
    return {
        'image': document.querySelector('.track-artwork').getAttribute('src'),
        'track': track_title,
        'artist': track_artist
    };
  }
}

