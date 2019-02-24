//
//  YouTubeMusic.plist
//  BeardedSpice
//
//  Created by Vladislav Gapurov on 07/28/18
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

BSStrategy = {
  version: 1,
  displayName: "YouTube Music",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*music.youtube.com/*'",
    args: ["URL"],
  },
  isPlaying: function() { return !document.querySelector('#movie_player video').paused; },
  toggle: function() { document.querySelector('.ytmusic-player-bar.play-pause-button').click(); },
  previous: function() { document.querySelector('.ytmusic-player-bar.previous-button').click(); },
  next: function() { document.querySelector('.ytmusic-player-bar.next-button').click(); },
  pause: function() {
    if(!document.querySelector('#movie_player video').paused) {
      document.querySelector('.ytmusic-player-bar.play-pause-button').click();
    }
  },
  favorite: function() {
    document.querySelector('ytmusic-like-button-renderer .ytmusic-like-button-renderer.like').click()
  },
  trackInfo: function() {
    timeInfo = document.querySelector('.ytmusic-player-bar.time-info').innerHTML.split('/');
    thumb = document.querySelector('.ytmusic-player-bar img');
    title = document.querySelector('.ytmusic-player-bar.title');
    byline = document.querySelector('.byline.ytmusic-player-bar');
    like = document.querySelector('ytmusic-like-button-renderer');

    return {
      'image': thumb.src,
      'track': title.text.runs[0].text,
      'artist': Array.from(byline.children)
        .reduce((acc, curr, i) => i === 0 ? curr.text : `${acc}, ${curr.text}`, '' ),
      'progress': `${timeInfo[0].trim()} of ${timeInfo[1].trim()}`,
      'favorited': like.getAttribute('like-status') === 'LIKE',
    };
  },
};
