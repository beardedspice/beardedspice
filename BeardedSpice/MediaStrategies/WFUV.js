//
//  wfuv.js
//  BeardedSpice
//
//  Created by You on Today's Date.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the file to retain consistent syntax coloring.

// Use a syntax checker to ensure validity. One is provided by nodejs (`node -c filename.js`)
// Normal formatting is supported (can copy/paste with newlines and indentations)

BSStrategy = {
  version: 1,
  displayName: "WFUV",
  accepts: {
    method: "predicateOnTab" /* OR "script" */,
    /* Use these if "predicateOnTab" */
    format: "%K LIKE[c] '*wfuv.org*'",
    args: ["URL"]
    /* Use "script" if method is "script" */
    /* script: function () { "javascript that returns a boolean value" } */
  },

  isPlaying: function () { 
    return $('BUTTON[type="button"][title="Pause"]').length === 1
  },
  toggle: function () {  
    if ($('BUTTON[type="button"][title="Pause"]:visible').length) {
      let p = $('BUTTON[type="button"][title="Pause"]:visible').get(0);
      $(p).click();
    } else {
      let p = $('BUTTON[type="button"][title="Play"][aria-label="Play"]').get(0);
      $(p).click();
    }

  },
  previous: function () { },
  next: function () {  },
  pause: function () {
    $('BUTTON[type="button"][title="Pause"]').click();
  },
  favorite: function () { /* toggles favorite on/off */},
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.

  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {
    let channelInfo = $('.channelid').html().split('<br>');
    let track = 'Unknown Track', artist = 'Unknown Artist';
    if (channelInfo.length) {
      let trackInfo = channelInfo[0].split(' - ');
      if (trackInfo.length) track = trackInfo[0].replace('Now Playing: ','');
      if (trackInfo.length > 1) artist = trackInfo[1];
    } else {
      console.log('No channel info available',channelInfo);
    }


    return {
        'track': track,
        'album': '',
        'artist': artist,
        'image': 'http://www.example.com/some/album/artwork.png',
        'favorited': 'true/false if the track has been favorited',
    };
  }
}
// The file must have an empty line at the end.