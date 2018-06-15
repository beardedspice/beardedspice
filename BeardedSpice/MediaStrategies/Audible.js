//
//  Audible.plist
//  BeardedSpice
//
//  Created by Max Borghino on 12/06/15.
//  Updated by Amit Chaudhari on 06/15/18.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
// strategy/site notes
// - favorite: sets a bookmark
// - prev: implements skip back 30 seconds
// - next: not used (alternative: we could do prev/next chapter, but this is not very useful)
// - track info: book title and author not in the player, only artwork, chapter, time/time left
BSStrategy = {
  version:2,
  displayName:"Audible",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*audible.com/cloudplayer*'",
    args: ["URL"]
  },
  isPlaying:function () {
    var p=document.querySelector('.adblPlayButton');
    return (p && p.classList.contains('bc-hidden'));
  },
  toggle: function () {document.querySelector('.adblPlayButton').click();},
  next: function () {document.querySelector('.adblFastForward').click();},
  favorite: function () {document.querySelector('.addBookmarkMenuIcon').click();},
  previous: function () {document.querySelector('.adblFastRewind').click()},
  pause:function () {
    var p=document.querySelector('.adblPlayButton');
    if(p && p.classList.contains('bc-hidden')){ p.click();}
  },
  trackInfo: function () {
    var art = document.querySelector('#adbl-cloudBook');
    var chapter = document.querySelector('#cp-Top-chapter-display');
    var timeCur = document.querySelector('#adblMediaBarTimeSpent');
    var timeRem = document.querySelector('#adblMediaBarTimeLeft');
    return {
      'image': art ? art.getAttribute('src') : null,
      'track': chapter ? chapter.innerText : null,
      'artist': (timeCur ? timeCur.innerText : null) + '/' + (timeRem ? timeRem.innerText : null),
    };
  }
}
