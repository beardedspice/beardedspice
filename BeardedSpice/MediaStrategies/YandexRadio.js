//
//  YandexMusic.plist
//  BeardedSpice
//
//  Created by Leonid Ponomarev 15.06.15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"YandexRadio",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*radio.yandex.*'",
    args:"url"
  },
  isPlaying: function () { return Mu.Flow.flow.player.isPlaying(); },
  toggle: function () { Mu.Flow.togglePause(); },
  next: function () {
    var nextTreckInfo = Mu.Flow.flow.getNextTrack();
    Mu.Flow.flow.next("nextpressed");
    return nextTreckInfo
  },
  favorite: function () {},
  previous: function () {},
  pause: function () {
    if($('body').attr('class').length!=0){
      document.querySelector('.player-controls__play').click()
    }
  },
  trackInfo:function () {
    var result;
    if (!(Mu.Flow.player.isPaused() || Mu.Flow.player.isPlaying())) {
      result = Mu.Flow.flow.getNextTrack();
    }
    else {
      result = Mu.Flow.flow.getTrack();
      result['favorited'] = $('.like_action_like').hasClass('button_checked');
    }
    var albums = result.albums
    if (albums) {
      result["album"] = albums[0]["title"]
      result["image"] = albums[0]["coverUri"].replace('\%\%', '600x600')
      /* FIXME - UNTESTED */
    }
    return {
      'favorited': result.favorited,
      'track': result.version ? (result.title+' '+result.version) : result.title,
      'image': result.image,
      'album': result.album
    };
  }
}
