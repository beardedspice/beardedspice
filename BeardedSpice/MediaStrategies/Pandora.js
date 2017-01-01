//
//  Pandora.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//  Modified by Anthony Whitaker on 12/13/16
//
BSStrategy = {
  version: 2,
  displayName: "Pandora",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*pandora.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    if (document.querySelector('div.Tuner__Controls') !== null) {
      return
        document
          .querySelector('.Tuner__Control__Play__Button')
          .attributes['data-qa']
          .value === 'play_button';
    } else {
      return document.querySelector('.pauseButton').style.display === 'block';
    }
  },
  toggle: function () {
    if (document.querySelector('div.Tuner__Controls') !== null) {
      document.querySelector('.Tuner__Control__Play__Button').click();
    } else {
      var playButton = document.querySelector('.playButton');
      var pauseButton = document.querySelector('.pauseButton');
      if (playButton.style.display==='block') { playButton.click() }
      else { pauseButton.click() }
    }
  },
  next: function () {
    document.querySelector('div.Tuner__Controls') !== null ?
    document.querySelector('.Tuner__Control__Skip__Button').click() :
    document.querySelector('.skipButton').click();
  },
  pause: function () {
    document.querySelector('div.Tuner__Controls') !== null ?
    document.querySelector('.Tuner__Control__Play__Button').click() :
    document.querySelector('.pauseButton').click();
  },
  favorite: function () {
    document.querySelector('div.Tuner__Controls') !== null ?
    document.querySelector('.Tuner__Control__ThumbUp__Button').click() :
    document.querySelector('.thumbUpButton').click();
  },
  trackInfo: function () {
    if (document.querySelector('div.Tuner__Controls') !== null) {
      return {
        'track': document
                   .querySelector('div.Tuner__Audio__TrackDetail__title')
                   .innerText,
        'artist': document
                    .querySelector('div.Tuner__Audio__TrackDetail__artist')
                    .innerText,
        'album': document
                   .querySelector('.nowPlayingTopInfo__current__albumName')
                   .innerText,
        'image': document
                   .querySelector('[data-qa=album_active_image]')
                   .style['background-image']
                   .slice(5, -2),
        'favorited': document
                       .querySelector('[data-qa=thumbs_up_button]')
                       .classList.contains('ThumbUpButton--active')
      };
    } else {
      return {
        'track': document.querySelector('.playerBarSong').innerText,
        'artist': document.querySelector('.playerBarArtist').innerText,
        'album': document.querySelector('.playerBarAlbum').innerText,
        'image': document.querySelector('.playerBarArt').src,
        'favorited': document
                       .querySelector('div.thumbUpButton')
                       .classList.contains('indicator')
      };
    };
  }
}
