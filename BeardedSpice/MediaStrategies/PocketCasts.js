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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*play.pocketcasts.com*'",
    args:"url"
  },
  toggle: function () {document.querySelector('div.play_pause_button').click()},
  next: function () {document.querySelector('div.skip_forward_button').click()},
  previous: function () {document.querySelector('div.skip_back_button').click()},
  pause: function () {document.querySelector('div.pause_button').click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('div.player_top div.player_episode').innerHTML,
      'album': document.querySelector('div.player_top div.player_podcast_title').innerHTML,
      'image': document.querySelector('div.player_top div.player_artwork img').src,
    };
  }
}
