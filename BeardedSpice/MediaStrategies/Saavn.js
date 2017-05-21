//
//  Saavn.plist
//  BeardedSpice
//
//  Created by Yash Aggarwal on 1/6/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"Saavn",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*saavn.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
  	return document.querySelector('#play').classList.contains('hide')
  },
  toggle: function () {
    var e = document.getElementById('play');
    var t = document.getElementById('pause');
    if (t.className.indexOf('hide')===-1) { t.click(); }
    else { e.click(); }
  },
  next: function () { document.getElementById('fwd').click();},
  previous: function () { document.getElementById('rew').click();},
  pause: function () { document.getElementById('pause').click();},
  trackInfo: function () {
    var reg = /(.*)(\()(.*)(\).*)/;

  	return {
  	  'track': document.querySelector('#player-track-name a').textContent,
  	  'album': document.querySelector('#player-album-name a').textContent,
  	  'image': document.querySelector('#now-playing .key-art').getAttribute('style').replace(reg, "$3").replace(/\"/g, "")
	}
  }
}
