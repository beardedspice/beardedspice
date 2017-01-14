//
//  Pluralsight.plist
//  BeardedSpice
//
//  Created by Raz Damaschin on 1/14/17.
//	Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"Pluralsight",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*app.pluralsight.com/player*'",
    args: ["URL"]
  },
  isPlaying: function () {return document.querySelector('#play-control').title.includes("Pause")},
  toggle: function () {document.querySelector('#play-control').click()},
  next: function () {document.querySelector('#next-control').click()},
  previous: function () {document.querySelector('#previous-control').click()},
  pause: function () {var button = document.querySelector('#play-control'); if (button.title.includes("Pause")) button.click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('li.selected h3').innerText,
      'album': document.querySelector('header.active h2').innerText,
    };
  }
}
