//
//  Pandora.js
//  BeardedSpice
//
//  Created by Jose Falcon on 2013-12-16
//  Updated by Anthony Whitaker on 2016-12-13
//  Support for new UI added by Bret Martin on 2017-01-01
//  Fix pause function in new UI by Andrew Ray on 2017-04-28
//  Fix Tuner__Controls query by Paul Hoisington on 2017-06-23
//  Minor fixes by Kunal Marwaha on 2018-06-27
//  Copyright (c) 2013-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 6,
  displayName: "Pandora",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*pandora.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    if (document.querySelector('.Tuner__Controls') !== null) {
      return document
          .querySelector('.Tuner__Control__Play__Button')
          .attributes['data-qa']
          .value === 'pause_button';
    } else {
      return document.querySelector('.pauseButton').style.display === 'block';
    }
  },
  toggle: function () {
    if (document.querySelector('.Tuner__Controls') !== null) {
      document.querySelector('.Tuner__Control__Play__Button').click();
    } else {
      var playButton = document.querySelector('.playButton');
      var pauseButton = document.querySelector('.pauseButton');
      if (playButton.style.display==='block') { playButton.click() }
      else { pauseButton.click() }
    }
  },
  next: function () {
    document.querySelector('.Tuner__Controls') !== null ?
    (document.querySelector('.Tuner__Control__Skip__Button')
      || document.querySelector('.Tuner__Control__SkipForeward__Button')).click() :
    document.querySelector('.skipButton').click();
  },
  previous: function () {
    document.querySelector('.Tuner__Control__SkipBack__Button')
      ? document.querySelector('.Tuner__Control__SkipBack__Button').click()
      : document.querySelector('.Tuner__Control__Replay__Button')
        && document.querySelector('.Tuner__Control__Replay__Button').click();
  },
  pause: function () {
    if(document.querySelector('.Tuner__Controls') !== null) {
      var playPauseButton = document.querySelector('.Tuner__Control__Play__Button');
      if (playPauseButton.attributes['data-qa'].value === 'pause_button') {
        playPauseButton.click()
      }
    } else {
    document.querySelector('.pauseButton').click();}
  },
  favorite: function () {
    document.querySelector('.Tuner__Controls') !== null ?
    document.querySelector('.Tuner__Control__ThumbUp__Button').click() :
    document.querySelector('.thumbUpButton').click();
  },
  trackInfo: function () {
    if (document.querySelector('.Tuner__Controls') !== null) {
      return {
        'track': (document.querySelector('.Tuner__Audio__TrackDetail__title')
                    || document.querySelector('.nowPlayingTopInfo__current__albumName')
                    || {})
                   .innerText,
        'artist': (document.querySelector('.Tuner__Audio__TrackDetail__artist')
                    || document.querySelector('.nowPlayingTopInfo__current__artistName')
                    || {})
                    .innerText,
        'album': (document.querySelector('.nowPlayingTopInfo__current__albumName') || {})
                   .innerText,
        'image': document.querySelector('[data-qa=album_active_image]')
                  && document.querySelector('[data-qa=album_active_image]')
                    .style['background-image']
                    .slice(5, -2),
        'favorited': document.querySelector('[data-qa=thumbs_up_button]')
                    && document.querySelector('[data-qa=thumbs_up_button]')
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
