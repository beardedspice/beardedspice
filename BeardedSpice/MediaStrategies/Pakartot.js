//
//  Pakartot.js
//  BeardedSpice
//
//  Created by monai on 2015-08-05.
//  Converted to js by Alex Evers on 1/28/2017.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Pakartot",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*pakartot.lt*'",
    args: ["URL"]
  },

  isPlaying: function () { !$('#playernode').data().jPlayer.status.paused; },
  toggle:    function () {
    var action = $('#playernode').data().jPlayer.status.paused ? 'play' : 'pause';
    $('#playernode').jPlayer(action);
  },
  previous:  function () { $('.jp-previous').click(); },
  next:      function () { $('.jp-next').click(); },
  pause:     function () { $('#playernode').jPlayer('pause'); },
  favorite:  function () { $('.jp-love').click(); },
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.

  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {
    var album = $('.main-title div').map(function(key, value){
      return $(value).text().trim();
    });
    return {
        'track': $('.jp-player-title').text().trim(),
        'album': album.length > 0 ? album[0] : '',
        'artist': album.length > 1 ? album[1] : '',
        'favorited': $('.jp-love').hasClass('on'),
    };
  }
}
