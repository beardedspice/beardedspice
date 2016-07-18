//
//  ProductHunt.plist
//  BeardedSpice
//
//  Created by Alexandre Daussy (Kureb) on 05/16/2016.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "ProductHunt",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*producthunt.com/podcasts*'",
    args: ["URL"]
  },
  isPlaying: function () {
    var canToggle = document.querySelector('span.player--button.v-toggle') != null;
    if (canToggle)
        return document.querySelector('span.player--button.v-toggle').getAttribute("data-reactid").indexOf("play") == -1;
    return false;
  },
  toggle:    function () { document.querySelector('span.player--button.v-toggle').click() },
  previous:  function () { document.querySelector('div.player--controls > span:nth-child(1)').click() },
  next:      function () { document.querySelector('div.player--controls > span:nth-child(3)').click() },
  pause:     function () {
    var doesPlayerExist = document.querySelector('body.m-player-active') != null;
    var isPlaying = document.querySelector('span.player--button.v-toggle').getAttribute("data-reactid").indexOf("play") == -1;
    if (doesPlayerExist && isPlaying)
      document.querySelector('span.player--button.v-toggle').click();
  },
  favorite:  function () { document.querySelector('a[rel=save-button]').click() },
  trackInfo: function () {
    return {
      'track': document.querySelector('a.player--media--name').innerHTML,
      'image': document.querySelector('a.player--media--coverart > img').getAttribute('src'),
    };
  }
}
