//
//  VkNew.plist
//  BeardedSpice
//
//  Created by Roman Toroshin on 17/08/16.
//  Copyright (c) 2014 Roman Toroshin. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName:"VK New",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*vk.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    var isPlaying = !!document.querySelector('#top_audio_player.top_audio_player_playing');
    console.log('BeardedSpice: isPlaying', isPlaying);
    return isPlaying;
  },
  toggle: function () {
    console.log('BeardedSpice: toggle');
    document.querySelector('#top_audio_player .top_audio_player_play').click();
  },
  next: function () {
    console.log('BeardedSpice: next');
    document.querySelector('#top_audio_player .top_audio_player_next').click();
  },
  favorite: function () {
    // fixme
    var el = document.querySelector('.audio_page_player');

    var player = document.querySelector('#top_audio_player');
    var e  = document.createEvent('MouseEvents');
    e.initEvent('mousedown', true, true);

    ( ! el ) && player.dispatchEvent(e);

    var pagePlayerInterval = setInterval(function() {

      if ( el ) {
        var audioRow = document.querySelector('.audio_row.audio_row_playing');

        if ( !! audioRow && audioRow.classList.contains('canadd') ) {
          console.log('BeardedSpice: favorite add');
          document.querySelector('#add').click();
          player.dispatchEvent(e);
          audioRow && clearInterval(pagePlayerInterval);
          return;
        }

        if ( !! audioRow && audioRow.classList.contains('added') ) {
          console.log('BeardedSpice: favorite delete');
          document.querySelector('#delete').click();
          player.dispatchEvent(e);
          audioRow && clearInterval(pagePlayerInterval);
        }

      } else {
        el = document.querySelector('.audio_page_player');
      }
    });
  },
  previous: function () {
    console.log('BeardedSpice: previous');
    document.querySelector('#top_audio_player .top_audio_player_prev').click();
  },
  pause: function () {
    console.log('BeardedSpice: pause');
    document.querySelector('#top_audio_player .top_audio_player_play').click();
  },
  trackInfo: function () {
    console.log('BeardedSpice: trackInfo');

    var artist = document.querySelector('.audio_page_player_title_performer');
    var track  = document.querySelector('.audio_page_player_title_song');

    if ( track ) {
      track = track.outerText;
    }

    if ( artist ) {
      artist = artist.outerText;
    }

    if ( ! track && ! artist ) {
      var title = document.querySelector('#top_audio_player .top_audio_player_title').outerText;
      title  = title.split(' – ');
      artist = title[0];
      track  = title[1];
    }

    return {
      'artist':    artist,
      'track':     track
    }
  },
}
