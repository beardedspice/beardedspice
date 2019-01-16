//
//  PocketCasts.plist
//  BeardedSpice
//
//  Created by Marco Zuccaroli on 7/17/18.
//
BSStrategy = {
  version:2,
  displayName:"PocketCasts",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*play.pocketcasts.com*'",
    args: ["URL"]
  },
  toggle: function () {document.querySelector('.play_pause_button').click()},
  next: function () {document.querySelector('.skip_forward_button').click()},
  previous: function () {document.querySelector('.skip_back_button').click()},
  pause: function () {document.querySelector('.pause_button').click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('.controls-center span.player_episode').innerText,
      'album': document.querySelector('.controls-center span.player_podcast_title').innerText,
      'image': document.querySelector('.controls-left .podcast-image img').src,
    };
  }
}
