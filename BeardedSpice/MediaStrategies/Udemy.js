//
//  Udemy.plist
//  BeardedSpice
//
//  Created by Coder-256 on 10/3/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Udemy",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*udemy.com*/lecture/*'",
    args:"url"
  },
  isPlaying: function () {return !(document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.querySelector('video').paused);},
  toggle: function () {
    var theVideo = document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.getElementsByTagName("video")[0];
    if (theVideo.paused) { theVideo.play(); }
    else { theVideo.pause() }
  },
  next: function () {document.querySelector('div.ud-lectureangular > iframe').parent().parent().parent().find(".prev-lecture")[0].click();},
  favorite: function () {},
  previous: function () {document.querySelector('div.ud-lectureangular > iframe').parent().parent().next().find(".next-lecture")[0].click();},
  pause: function () {document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.getElementsByTagName("video")[0].pause();},
  trackInfo: function () {
    return {
      'track': document.querySelector('.curriculum-item.on .ci-title').innerText,
      'album': 'Udemy'
    }
  }
}
