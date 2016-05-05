//
//  JangoMedia.plist
//  BeardedSpice
//
//  Created by Stanislav Sidelnikov on 09/11/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Jango",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*jango.com*'",
    args:"url"
  },
  isPlaying: function isPlaying () { return (document.querySelector('#btn-playpause.pause') != null);},
  toggle: function toggle () {document.querySelector('a#btn-playpause').click()},
  next: function next () {document.querySelector('a#btn-ff').click()},
  previous: function previous () {},
  favorite: function favorite () {},
  pause:function () {
    var e = document.querySelector('a#btn-playpause.pause');
    if(e != null) { e.click(); }
  },
  trackInfo: function trackInfo () {
    return {
      'track': $('#current-song')[0].innerText,
      'artist': $('#player_current_artist a')[0].innerText,
      'favorited': false,
      'image': $('#player_main_pic_img').attr('src')
    };
  }
}
