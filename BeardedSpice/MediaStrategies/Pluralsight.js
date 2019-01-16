//
//  Pluralsight.plist
//  BeardedSpice
//
//  Created by Shreyas Minocha on 6/5/18.
//  Copyright (c) 2018 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"Pluralsight",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*app.pluralsight.com*'",
    args: ["URL"]
  },
  isPlaying: function () {return document.querySelector('button#play-control').title.includes("Pause")},
  toggle: function () {document.querySelector('button#play-control').click()},
  next: function () {document.querySelector('button#next-control').click()},
  previous: function () {document.querySelector('button#previous-control').click()},
  pause: function () {var button = document.querySelector('button#play-control'); if (button.title.includes("Pause")) button.click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('div#module-clip-title').innerText,
      'album': document.querySelector('a#course-title-link').innerText,
    };
  }
}
