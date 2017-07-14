// Bearded spice strategy for the web interface of HTTPMS.
// What is bearded spice you ask? https://github.com/beardedspice/beardedspice
// What about HTTPMS? https://github.com/ironsmile/httpms

BSStrategy = {
  version: 1,
  displayName: "HTTPMS",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*HTTPMS'",
    args: ["title"]
  },

  isPlaying: function () { return document.title.match(/.*\| HTTPMS$/) != null; },
  toggle:    function () {
    var playing = (document.title.match(/.*\| HTTPMS$/) != null);
    if (playing) {
      document.querySelector('.jp-pause').click();
    } else {
      document.querySelector('.jp-play').click();
    }
  },
  previous:  function () { document.querySelector('.jp-previous').click(); },
  next:      function () { document.querySelector('.jp-next').click(); },
  pause:     function () { document.querySelector('.jp-pause').click(); },
  favorite:  function () { /* there is no favourite feature in this player */ },

  trackInfo: function () {
    var selected = document.querySelector('a.jp-playlist-current');
    var artist = document.querySelector('a.jp-playlist-current > .jp-artist').innerText.slice(3);
    var trackNumberedText = selected.innerText;
    var album = document.querySelector('li.jp-playlist-current').children[0].children[1].children[0].innerText;
    var m = trackNumberedText.match(/\d+\.\s+(.+) by/);

    if (m) {
      track = m[1];
    } else {
      track = trackNumberedText;
    }

    return {
        'track': track,
        'album': album,
        'artist': artist,
        'favorited': false
    };
  }
}
