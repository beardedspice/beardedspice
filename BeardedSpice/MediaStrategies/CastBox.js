//
//  CastBox.plist
//  BeardedSpice
//
//  Created by Colin Vinson on 11/03/17.
//  Copyright (c) 2017 Tyler Rhodes / Colin Vinson. All rights reserved.
//
BSStrategy = {
    version: 1,
    displayName: "CastBox",
    accepts: {
      method: "predicateOnTab",
      format:"%K LIKE[c] '*castbox.fm*'",
      args: ["URL"]
    },
    toggle: function () { document.getElementsByClassName('playBtn')[0].click(); },
    next: function () { document.getElementsByClassName('forward')[0].click(); },
    previous: function () { document.getElementsByClassName('back')[0].click(); },
    pause: function () { document.getElementsByClassName('play')[0].click(); },
    trackInfo: function () {
      return {
        'artist': unescape(document.querySelector('.guru-breadcrumb-item:nth-of-type(2) a').innerHTML) || unescape(document.querySelector('h1.author').innerHTML),
        'track': document.querySelector('.title').innerHTML,
        'image': document.querySelector('.footerFeed .leftImg img').src,
        'progress': document.getElementsByClassName('currentTime')[0].innerText + " / " + document.getElementsByClassName('duration')[0].innerText
      };
    }
  }
  