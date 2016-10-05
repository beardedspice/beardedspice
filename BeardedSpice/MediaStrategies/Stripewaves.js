//
//  Stripewaves.plist
//  BeardedSpice
//
//  Created by Wouter Beugelsdijk on 31/08/16.
//
BSStrategy = {
  version:1,
  displayName:"Stripewaves",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*stripewaves.com*'",
    args: ["URL"]
  },
  isPlaying: function () {$('.playButton').hasClass('is-playing')},
  toggle: function () {$('.playButton').click()},
  next: function () {$('.nextButton').click()},
  favorite: function () {},
  previous: function () {$('.prevButton').click()},
  pause: function () {$('.playButton').hasClass('is-playing') && $('.playButton').click()},
  trackInfo: function () {
      return {
          'image': $(".is-playing .track-artwork").attr('src'),
          'track': $(".currentTrack-title").text(),
          'artist': $(".currentTrack-user").text()
    };
  }
}
