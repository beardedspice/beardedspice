//
//  Zing.plist
//  BeardedSpice
//
//  Created by Alvin Nguyen on 06/23/16.
//  Updated by ToanPVN on 08/23/17.
//
BSStrategy = {
  version: 2,
  displayName: "Zing MP3",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*mp3.zing.vn/bai-hat*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('#zp-svg-play') == null; },
toggle: function(){ document.querySelector('.paused').click(); },
  previous: function(){
    var button_prev = document.querySelector('.zp-button-prev').getAttribute('style');
    if (button_prev === null) {
      document.querySelector('.zp-button-prev').click();
    } else {
      window.history.back();
    } 
  },
  next: function(){ document.querySelector('.zp-button-next').click(); },
  pause: function(){ 
    if (document.querySelector('#zp-svg-play') == null) {
      document.querySelector('.paused').click();
    }},
  trackInfo: function () {
    return {
        'image': document.querySelector('.pthumb').getAttribute('src'),
        'track':  document.querySelector('.fn-song.fn-current .fn-name').innerText,
        'artist': document.querySelector('.fn-song.fn-current h4 a').innerText
    };
  }
}
