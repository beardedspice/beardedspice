//
//  Spotify.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/19/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"Spotify",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*open.spotify.com*'",
    args: ["URL"]
  },
  isPlaying: function() {
    return document.querySelector('.control-button--circled').classList.contains('spoticon-pause-16');
  },
  toggle: function () {
    document.querySelector('.control-button--circled').click();
  },
  next: function () {
    document.querySelector('.spoticon-skip-forward-16').click();
  },
  favorite: function () {
    if (document.querySelector('.spoticon-add-16')) {
      document.querySelector('.spoticon-add-16').click();
    }
  },
  previous: function () {
    document.querySelector('.spoticon-skip-back-16').click();
  },
  pause: function () {
    if (document.querySelector('.control-button--circled').classList.contains('spoticon-pause-16')) {
      document.querySelector('.control-button--circled').click();
    }
  },
  trackInfo: function () {
    return {
      'image': document.querySelector('.cover-art-image-loaded').style.backgroundImage.split("\"")[1],
      'track': document.querySelector('.track-info__name').querySelector('a').innerText,
      'artist': document.querySelector('.track-info__artists').querySelector('a').innerText
    };
  }
}
