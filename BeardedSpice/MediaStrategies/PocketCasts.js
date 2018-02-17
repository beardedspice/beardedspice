//
//  PocketCasts.plist
//  BeardedSpice
//
//  Created by Dmytro Piliugin on 1/23/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"PocketCasts",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*play*.pocketcasts.com*'",
    args: ["URL"]
  },
  toggle: function () {document.querySelector('.play_pause_button').click()},
  next: function () {document.querySelector('.skip_forward_button').click()},
  previous: function () {document.querySelector('.skip_back_button').click()},
  pause: function () {
    document.querySelector(
      '.play_pause_button'
    ).classList.contains('pause_button')
      ? document.querySelector('.play_pause_button').click()
      : []
  },
  isPlaying: function () {
    return document.querySelector('.play_pause_button').classList.contains('pause_button')
  },
  trackInfo: function () {
    return {
      'track': document.querySelector(
        'div.player_top div.player_episode'
      ) ? document.querySelector(
        'div.player_top div.player_episode'
      ).innerText : document.querySelector('.controls .episode-title').innerText,

      'album': document.querySelector(
        'div.player_podcast_title div.player_episode'
      ) ? document.querySelector(
        'div.player_podcast_title div.player_episode'
      ).innerText : document.querySelector('.controls .podcast-title').innerText,

      'image': document.querySelector(
        'div.player_top div.player_artwork img'
      ) ? document.querySelector(
        'div.player_top div.player_artwork img'
      ).src : document.querySelector('.controls .podcast-image img').src,
    };
  }
}

