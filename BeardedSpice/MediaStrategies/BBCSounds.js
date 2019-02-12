//
//  BBCSounds.js
//  BeardedSpice
//
//  Created by Ben Pollman on 02/12/19.
//  Copyright (c) 2019 Ben Pollman. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"BBC Sounds",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*.bbc.co.uk/sounds/play/*'",
    args: ["URL"]
  },
  isPlaying:function () {
    let iframe = window.parent.document.querySelector('#smphtml5iframesmp-wrapper');
    return (iframe != null) && (iframe.contentDocument.querySelector('#p_audioui_playpause_playIcon').style.opacity == "0");
  },
  toggle:function () {
    let iframe = window.parent.document.querySelector('#smphtml5iframesmp-wrapper');
    if (iframe != null) {
       iframe.contentDocument.querySelector('#p_audioui_playpause').click();
     }
  },
  next: function () { 
    let iframe = window.parent.document.querySelector('#smphtml5iframesmp-wrapper');
    if (iframe != null) {
       iframe.contentDocument.querySelector('#p_audioui_nextButton').click();
     }
  },
  favorite: function () {
  },
  previous: function () {
    let iframe = window.parent.document.querySelector('#smphtml5iframesmp-wrapper');
    if (iframe != null) {
       iframe.contentDocument.querySelector('#p_audioui_previousButton').click();
     }
  },
  pause: function () {
    let iframe = window.parent.document.querySelector('#smphtml5iframesmp-wrapper');
    if (iframe != null) {
       iframe.contentDocument.querySelector('#p_audioui_playpause').click();
     }
  },
  trackInfo: function () {
    let art= window.parent.document.querySelector('.play-c-header-image img');
    let title= window.parent.document.querySelector('h3');
    let artist= window.parent.document.querySelector('h1');
  
    return {'image': art ? art.src : null,
            'track': title ? title.innerText : document.title,
            'artist': artist ? artist.innerText : null
    };
  }
}
