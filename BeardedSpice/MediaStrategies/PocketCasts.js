//
//  PocketCasts.plist
//  BeardedSpice
//
//  Created by Dmytro Piliugin on 1/23/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"PocketCasts",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*play.pocketcasts.com*'",
    args: ["URL"]
  },
  toggle: function () {document.querySelector('div.play_pause_button').click()},
  next: function () {document.querySelector('div.skip_forward_button').click()},
  previous: function () {document.querySelector('div.skip_back_button').click()},
  pause: function () {document.querySelector('div.pause_button').click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('div.player_top div.player_episode').innerText,
      'album': document.querySelector('div.player_top div.player_podcast_title').innerText,
      'image': document.querySelector('div.player_top div.player_artwork img').src,
    };
  }
}
