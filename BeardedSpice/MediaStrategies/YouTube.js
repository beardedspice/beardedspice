//
//  YouTube.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Updated by Alin Panaitiu on 3/2/18.
//  Updated by Vladislav Gapurov on 07/28/18
//  Updated by Andreas Willi on 02/24/19
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

BSStrategy = {
  version: 4,
  displayName: "YouTube",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*youtube.com/watch*' && !%@ LIKE[c] '*music.youtube.com*'",
    args: ["URL", "URL"]
  },
  isPlaying: function () { return !document.querySelector('#movie_player video').paused; },
  toggle: function () { document.querySelector('#movie_player .ytp-play-button').click(); },
  previous: function () { document.querySelector('#movie_player').previousVideo(); },
  next: function () { document.querySelector('#movie_player').nextVideo(); },
  pause: function () { document.querySelector('#movie_player').pauseVideo(); },
  favorite: function () { document.querySelector('ytd-toggle-button-renderer').click(); },
  trackInfo: function () {
    function pad(number) {
      if (number < 10) {
        return `0${number}`;
      } else {
        return number.toString();
      }
    };

    function secondsToTimeString(seconds) {
      hours = Math.floor(seconds / 3600);
      minutes = Math.floor(seconds / 60);
      seconds = Math.floor(seconds % 60);

      if (hours > 0) {
        return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
      } else {
        return `${pad(minutes)}:${pad(seconds)}`;
      }
    };

    playerManager = document.querySelector('yt-player-manager');
    player = playerManager.player_;
    videoData = player.getVideoData();

    progress = player.getProgressState();
    played = secondsToTimeString(progress.current);
    duration = secondsToTimeString(progress.duration);

    return {
      'image': `https://i.ytimg.com/vi/${videoData.video_id}/hqdefault.jpg`,
      'track': videoData.title,
      'artist': videoData.author,
      'progress': `${played} of ${duration}`,
      'favorited': document.querySelector('ytd-toggle-button-renderer').data.isToggled
    };
  }
}
