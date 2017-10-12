//
//  FitRadio.plist
//  BeardedSpice
//
//  Created by Lucas Culbertson on 10/12/17.
//
BSStrategy = {
  version: 1,
  displayName: "Fitradio",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*fitradio.com/music*'",
    args: ["URL"]
  },
  isPlaying: function () { return $('#jplayer_pause').is(":visible"); },
  toggle: function () {
    var isPlaying = $('#jplayer_pause').is(":visible");
    if (isPlaying) {
      $("#jquery_jplayer").jPlayer("pause");
    } else {
      $("#jquery_jplayer").jPlayer("play");
    }
  },
  next: function () { document.querySelector('#jplayer_next').click(); },
  pause: function () { $("#jquery_jplayer").jPlayer("pause"); },
  favorite: function () { document.querySelector('#player_heart_box').click(); },
  trackInfo: function () {
    return {
      'image': document.querySelector('#artwork').getAttribute('src'),
      'track': document.querySelector('#current_title').innerText,
      'artist': document.querySelector('#current_dj').innerText,
      'progress': function () {
        var currentTime = document.querySelector('.jp-current-time').innerText;
        var totalTime = document.querySelector('.jp-duration').innerText;
        return currentTime + " of " + totalTime;
      }
    };
  }
};
