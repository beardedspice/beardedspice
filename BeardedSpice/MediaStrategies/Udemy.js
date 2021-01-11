//
//  Udemy.plist
//  BeardedSpice
//
//  Created by Coder-256 on 10/3/15.
//  Updated by nelsonjchen on 11/24/16.
//  Updated by shalva-an on 01/11/2021
//  Copyright (c) 2015-2021 GPL v3 http://www.gnu.org/licenses/gpl.html
//  Copyright © 2021 BeardedSpice. All rights reserved.
//

BSStrategy = {
  version: 4,
  displayName:"Udemy",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*udemy.com*/course/*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return !document.querySelector("video").paused;
  },
  toggle: function () {
    const theVideo = document.querySelector("video");
    theVideo.paused ? theVideo.play() : theVideo.pause();
  },
  next: function () {
    document.querySelector('[data-purpose^="forward-skip-button"]').click()
  },
  previous: function () {
    document.querySelector('[data-purpose^="rewind-skip-button"]').click()

  },
  pause: function () {
    document.querySelector("video").pause();
  },
  trackInfo: function () {
    return {
      track: document.querySelector('[data-purpose^="course-header-title"]').innerText,
      album: "Udemy",
    };
  },
};

// class names as of 2021 instead of using data-purpose
// track: document.querySelector('.course-info__title').textContent,
// document.querySelector(".udi-exp-skip-forward").click();
// document.querySelector(".udi-exp-skip-back").click();
