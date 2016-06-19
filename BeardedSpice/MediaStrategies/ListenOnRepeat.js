//
//  ListenOnRepeat
//  BeardedSpice
//  Created by Alexandre Daussy (Kureb) on 05/23/16.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName: "ListenOnRepeat",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*listenonrepeat.com*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('i.mdi-av-pause') == null; } ,
  toggle: function () { return document.querySelector('div.control-play-pause').click(); },
  previous: function () { return document.querySelector('i.mdi-av-skip-previous').click(); },
  next: function () { return document.querySelector('i.mdi-av-skip-next').click(); },
  pause: function () { document.querySelector('i.mdi-av-pause').click(); },
  favorite: function () { document.querySelector('mdi-action-favorite-outline').click(); },
  trackInfo: function() {
    return {
        'track': document.querySelector('div.video-title').innerHTML,
        'favorite': document.querySelector('div.control-heart > i:nth-child(1)').getAttribute("title").indexOf("Add") == -1
    };
  }
}
