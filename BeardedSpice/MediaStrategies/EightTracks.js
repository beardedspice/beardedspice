//
//  EightTracks.plist
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/15/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "8tracks",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*8tracks.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    var pause = document.querySelector('#player_pause_button');
    return pause !== null && pause !== undefined &&pause.style.display !== 'none';
  },
  toggle: function () {
    var play = document.querySelector('#player_play_button');
    var pause = document.querySelector('#player_pause_button');
    var overlay = document.querySelector('#play_overlay');
    if (play !== undefined && play !== null && play.style.display !== 'none') { play.click(); }
    else if (pause !== undefined && pause !== null && pause.style.display !== 'none') { pause.click(); }
    else if (overlay !== undefined) { overlay.click(); }
  },
  next: function () {
    var skip = document.querySelector('#player_skip_button');
      if (skip !== undefined && skip !== null) skip.click();
  },
  favorite: function () {
    var fav = document.querySelector('#now_playing a.fav');
      if (fav !== null && fav !== undefined) fav.click()
  },
  pause: function () {
    var pause = document.querySelector('#player_pause_button');
      if (pause !== null && pause !== undefined) pause.click()
  },
  trackInfo: function () {
    var nowPlaying = document.querySelector('#now_playing');
    var titleArtist = nowPlaying.querySelector('.title_artist');
    return {
      'title':  titleArtist.querySelector('.t').textContent,
      'artist': titleArtist.querySelector('.a').textContent,
      'album':  nowPlaying.querySelector('.track_details .track_metadata .album .detail').textContent,
      'favorited': nowPlaying.querySelector('a.fav').classList.contains('active'),
      'image': document.querySelector('#mix_player_details a.thumb img').src,
    };
  }
}
