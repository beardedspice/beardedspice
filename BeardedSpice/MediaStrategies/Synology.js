//
//  Synology.plist
//  BeardedSpice
//  
//
BSStrategy = {
  version: 2,
  displayName: "Synology Audio Station",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '* - Audio Station*'",
    args: ["title"]
  },
  isPlaying: function () {return ( (document.querySelector('.player-play span:not(.player-btn-pause)') ? false : true));},
  toggle: function () {document.querySelectorAll('.player-play button')[0].click()},
  next: function () {document.querySelectorAll('.player-next button')[0].click()},
  previous: function () {document.querySelectorAll('.player-prev button')[0].click()},
  pause: function () {document.querySelectorAll('.player-stop button')[0].click()},
  favorite: function () {},
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.
  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {
    var track = document.querySelector('.info-title span').innerText;
    var albumArtist = document.querySelector('.info-album-artist span').innerText.split(' - ');
    var album = albumArtist[0];
    var artist = albumArtist.reverse();
    // Image not used due to image resources can only be loaded by authenticated apps
    // var albumArt = document.querySelector('.player-info-thumb').getAttribute('src');
    return {
      'track': track,
      'artist': artist[0],
      'album': album,
    };
  }
}
