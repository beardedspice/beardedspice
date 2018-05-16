//
//  LeReglement.plist
//  BeardedSpice
//
//  Created by Constant Lahousse on 16th May 2018.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName:"Le Règlement",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*lereglement.sale*'",	
    args: ["URL"]
  },
  isPlaying:function () {
    var play = document.querySelector('.button-player');
    return play.getAttribute('data-icon') === 'pause';
  },
  toggle: function () {return document.querySelector('.button-player').click()},
  next: function () {},
  favorite:function () {},
  previous: function () {},
  pause: function (){
      var play = document.querySelector('.button-player');
      if(play.getAttribute('data-icon') === 'pause') { play.click(); }
  },
  trackInfo: function () {
    var artist = document.querySelector('.header-radio-subtitle').innerText
    return {
        'track': document.querySelector('.header-radio-title').innerText,
	'artist': artist.replace("de ", ""),
        'image': "http:" + document.querySelector('.cover').style['background-image'].slice(5, -2)
    }
  }
}
