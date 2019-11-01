//
//  NewStrategyName.js
//  BeardedSpice
//
//  Created by You on Today's Date.
//  Copyright (c) 2015-2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the file to retain consistent syntax coloring.

// Use a syntax checker to ensure validity. One is provided by nodejs (`node -c filename.js`)
// Normal formatting is supported (can copy/paste with newlines and indentations)

BSStrategy = {
  version: 1,
  displayName: "Strategy Name",
  accepts: {
    method: "predicateOnTab" /* OR "script" */,
    /* Use these if "predicateOnTab" */
    format: "%K LIKE[c] '*[YOUR-URL-DOMAIN-OR-TITLE-HERE]*'",
    args: ["URL" /* OR "title" */]
    /* Use "script" if method is "script" */
    /* [ex] script: "some javascript here that returns a boolean value" */
  },

  /*
  Elements marked as //OPTIONAL 
  'MUST' be removed if website does not support corresponding action 
  */
  pause:     function () { /* pause site playing */ },
  isPlaying: function () { /* javascript that returns a boolean */ }, //OPTIONAL
  toggle:    function () { /* toggle site playing */ },               //OPTIONAL
  previous:  function () { /* switch to previous track if any */ },   //OPTIONAL
  next:      function () { /* switch to next track if any */ },       //OPTIONAL
  favorite:  function () { /* toggles favorite on/off */},            //OPTIONAL
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.

  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {                                            //OPTIONAL
    return {
        'track': 'the name of the track',
        'album': 'the name of the current album',
        'artist': 'the name of the current artist',
        'image': 'http://www.example.com/some/album/artwork.png',
        'favorited': 'true/false if the track has been favorited',
    };
  }
}
// The file must have an empty line at the end.
