//
//  Audible.plist
//  BeardedSpice
//
//  Created by Max Borghino on 12/06/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
// strategy/site notes
// - favorite: sets a bookmark
// - prev: implements skip back 30 seconds
// - next: not used (alternative: we could do prev/next chapter, but this is not very useful)
// - track info: book title and author not in the player, only artwork, chapter, time/time left
BSStrategy = {
  version:1,
  displayName:"Audible",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*audible.com/cloud-player*'",
    args: ["URL"]
  },
  isPlaying:function () {
    var p=document.querySelector('.pause');
    return (p && !p.classList.contains('hide'));
  },
  toggle: function () {document.querySelector('.play').click();},
  next: function () {document.querySelector('.fav').click();},
  favorite: function () {},
  previous: function () {document.querySelector('.repeat').click()},
  pause:function () {
    var p=document.querySelector('.pause');
    if(p && !p.classList.contains('hide')){ p.click();}
  },
  trackInfo: function () {
    var art = document.querySelector('.item img');
    var chapter = document.querySelector('.chapter');
    var timeCur = document.querySelector('.cur');
    var timeRem = document.querySelector('.rem');
    return {
      'image': art ? art.getAttribute('src') : null,
      'track': chapter ? chapter.innerText : null,
      'artist': (timeCur ? timeCur.innerText : null) + '/' + (timeRem ? timeRem.innerText : null),
    };
  }
}
