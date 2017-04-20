//
//  Synology.plist
//  BeardedSpice
//
//
BSStrategy = {
  version: 3,
  displayName: "Synology Audio Station",
  accepts: {
    method: "script",
    script: function () {
      /* first check if the window is running synology webmanager  */
      if (window.SYNO_WebManager_Strings != undefined) {
        /* check if window is running synology audio station */
        return (baseURL == "webman/3rdparty/AudioStation");
      }
    }
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
    var progress = document.querySelector('.syno-as-player-position-block').innerText;
    /*
    Image not used due to image resources can only be loaded by authenticated apps
    var albumArt = document.querySelector('.player-info-thumb').getAttribute('src');
    */
    return {
      'track': track,
      'artist': artist[0],
      'album': album,
      'progress': progress
    };
  }
}
