//
//  DigitallyImported.plist
//  BeardedSpice
//
//  Created by Dennis Lysenko on 4/4/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"Digitally Imported",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*di.fm*'",
    args: ["URL"]
  },
  isPlaying:function () {
      var pause = $('#webplayer-region .controls .ico.icon-pause').length;
      var spinner = $('#webplayer-region .controls .ico.icon-spinner3').length;
      var sponsor = $('#webplayer-region .metadata-container .track-title .sponsor').length;
      return pause ? true : (spinner && sponsor);
  },
  toggle: function () { return document.querySelectorAll('div.controls a')[0].click() },
  favorite: function () { $('.vote-btn.up').click(); },
  pause:function () {
    var pause = document.querySelectorAll('div.controls a')[0];
    if(pause.classList.contains('icon-pause')){
      pause.click();
    }
  },
  trackInfo: function () {
    var artistName = $('.artist-name').text();
    var trackName = $('.track-name').text().replace(artistName, "");
    if (artistName.length > 3) {
        artistName = artistName.substring(0, artistName.length - 3);
    }
    return {
      'artist': artistName,
      'track': trackName.replace(/\s+/, ''),
      'favorited': ($('.icon-thumbs-up-filled').get(0) ? true : false),
      'image': $('#webplayer-region .track-region .artwork img').attr('src')
    }
  }
}
