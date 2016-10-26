//
//  BE-AT.TV.js
//  BeardedSpice
//
//  Created by Marvin Tam on 10/25/2016.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "BE-AT.TV",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*be-at.tv*'",
    args: ["URL"]
  },
  isPlaying: function() {
    return document.querySelector('#radio .playbutton')
      .style.display === 'none';
  },
  toggle: function() {
    var playButton = document.querySelector('#radio .playbutton');
    var pauseButton = document.querySelector('#radio .pausebutton');

    playButton.style.display === 'none' ? pauseButton.click() :
      playButton.click();
  },
  next: function() {
    document.querySelector('#radio .next').click();
  },
  favorite: function() {}, // not applicable here
  previous: function() {
    document.querySelector('#radio .back').click();
  },
  pause: function() {
    document.querySelector('#radio .pausebutton').click();
  },
  trackInfo: function() {
    // Ticker format: "artist : track"
    var items = document.querySelector('#radio .ticker').textContent
      .split(':', 2);

    // Get the un-resized thumbnail by removing the ?w=36&h36 query
    var imageUrl = document.querySelector('#radio img').src;
    imageUrl = imageUrl.slice(0, imageUrl.indexOf('?'));

    return {
      artist: items[0].trim(),
      track: items[1].trim(),
      image: imageUrl
    };
  }
}
