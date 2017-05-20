//
//  BBCRadioProgrammes.plist
//  BeardedSpice
//
//  Created by Ben Pollman on 05/16/17.
//  Copyright (c) 2017 Ben Pollman. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"BBC Radio Programmes",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*bbc.co.uk/programmes/*'",
    args: ["URL"]
  },

  isPlaying: function () {
  	let iframe = window.parent.document.querySelector('iframe[id^="smphtml5iframeepisode-playout-"]');
    return (iframe != null) && (iframe.contentDocument.querySelector('.p_pauseButton') != null);
  },

  toggle: function () {
  	let iframe = window.parent.document.querySelector('iframe[id^="smphtml5iframeepisode-playout-"]');
  
    if (iframe != null) {
      let play = iframe.contentDocument.querySelector('.p_playButton');
      let pause = iframe.contentDocument.querySelector('.p_pauseButton');
     
      if (play != null) {
        play.click();
      } 
      else if (pause != null) {
        pause.click();
      }
    }
  },

  previous: function () { window.parent.document.querySelector('.istats--more-panel-play-previous a').click(); },
  next: function () { window.parent.document.querySelector('.istats--more-panel-play-next a').click(); },
  pause: function () {
  	let iframe = window.parent.document.querySelector('iframe[id^="smphtml5iframeepisode-playout-"]');

    if (iframe != null) {
      let pause = iframe.contentDocument.querySelector('.p_pauseButton');
      if (pause != null) {
        pause.click();
      }
    }
  },

  favorite: function () { window.parent.document.querySelector('#pf1').click(); },

  trackInfo: function () {
    let trackdiv = window.parent.document.querySelector('div.br-masthead__title > a');
    let artistdiv = window.parent.document.querySelector("div.island > div > h1[property='name']");
    let albumdiv = window.parent.document.querySelector('.service-brand-logo-master');
    let favoritediv = window.parent.document.querySelector('#pf1');

    let iframe = window.parent.document.querySelector('iframe[id^="smphtml5iframeepisode-playout-"]');
    let imagediv = iframe != null ? iframe.contentDocument.querySelector('#mediaContainer') : null;
    let timediv = iframe != null ? iframe.contentDocument.querySelector('.p_timeDisplay') : null;
  	
    return {
      'track': trackdiv ? trackdiv.text : null,
      'artist': artistdiv ? artistdiv.innerText : null,
      'album' : albumdiv ? albumdiv.innerText : null,
      'image': imagediv ? imagediv.style.backgroundImage : null,
      'favorited': favoritediv ? favoritediv.classList.contains("p-f-added") : false,
      'progress': timediv ? timediv.innerText.replace("/", " / ") : "- / -"
    };
  }
}
