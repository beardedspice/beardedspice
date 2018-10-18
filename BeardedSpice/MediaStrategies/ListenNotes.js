//
//  ListenNotes.plist
//  BeardedSpice
//
//  Created by Mauricio Coelho on 10/18/18
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

BSStrategy = {
  version: 1,
  displayName: "Listen Notes",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*listennotes.com/*'",
    args: ["URL"],
  },
  isPlaying: function() { return !document.querySelector('.media-player audio').paused; },
  toggle: function() { document.querySelector('.ln-audioplayer-controls-container a:nth-child(2)').click(); },
  previous: function() { document.querySelector('.ln-audioplayer-controls-container a:nth-child(1)').click(); },
  next: function() { document.querySelector('.ln-audioplayer-controls-container a:nth-child(3)').click(); },
  pause: function() {
    if(!document.querySelector('.media-player audio').paused) {
      document.querySelector('.ln-audioplayer-controls-container a:nth-child(2)').click()
    }
  },  
  trackInfo: function() {
    timeInfo = document.querySelector('.ln-audioplayer-time-text-left').innerText;
    thumb = document.querySelector('.ln-audioplayer-desktop-image');
    title = document.querySelector('.ln-audioplayer-desktop-left-episode-title').innerText;
    artist = document.querySelector('.ln-audioplayer-desktop-left-channel-title').innerText;    

    return {
      'image': thumb.src,
      'track': title,
      'artist': artist,
      'progress': `${timeInfo}`,      
    };
  },
};
