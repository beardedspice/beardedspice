//
//  Lynda.plist
//  BeardedSpice
//
//  Created by Raz Damaschin on 1/14/17.
//	Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"Lynda",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*www.lynda.com*'",
    args: ["URL"]
  },
  isPlaying: function () {return document.querySelector('button#player-playpause').title.includes("Pause")},
  toggle: function () {document.querySelector('button#player-playpause').click()},
  next: function () {document.querySelector('button#player-next').click()},
  previous: function () {document.querySelector('button#player-previous').click()},
  pause: function () {var button = document.querySelector('button#player-playpause'); if (button.title.includes("Pause")) button.click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('h1.default-title').innerText,
      'album': document.querySelector('a.headline-course-title').innerText,
    };
  }
}
