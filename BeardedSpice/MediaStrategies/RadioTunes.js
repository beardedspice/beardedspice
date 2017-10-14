//
//  RadioTunes.js
//  BeardedSpice
//
//  Created by Roman Sokolov on 05/25/17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"RadioTunes",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*.radiotunes.com/*'",
    args: ["URL"]
  },
  isPlaying:function () {
    return ($('#row-player-controls .ctl .icon-pause').get(0) != null);
  },
  toggle: function () { $('#row-player-controls .ctl').click(); },
  favorite: function () { $('.vote-btn.up').click(); },
  pause:function () {
    if($('#row-player-controls .ctl .icon-pause').get(0)){
      $('#row-player-controls .ctl').click();
    }
  },
  trackInfo: function () {
    var artistName = $('.artist-name').text();
    var trackName = $('.track-name').text().replace(artistName, "");
    if (artistName.length > 3) {
        artistName = artistName.substring(0, artistName.length - 3);
    }
    var imageUrl = $('#row-player-controls #art img').attr('src');
    if (! imageUrl )
        imageUrl = 'https://cdn-images.audioaddict.com/0/6/8/5/9/f/06859fcd8bc050391c952e9333062c05.png?size=200x200';

    return {
      'artist': artistName,
      'track': trackName.replace(/\s+/, ''),
      'favorited': ($('.vote-btn.up.voted').get(0) ? true : false),
      'image': imageUrl
    };
  }
}
