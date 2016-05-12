//
//  TidalHiFi.plist
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"TidalHiFi",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*listen.tidal.com*'",
    args:"url"
  },
  isPlaying:function () {
    var player = require('media/playbackController');
    return player.isPlaying();
  },
  toggle:function () {
    var player = require('media/playbackController');
    if (player.isPlaying()) { player.pause(); }
    else { player.resume(); }
  },
  next: function () {require('media/playbackController').playNext();},
  favorite:function () {
    var obj = require('media/playbackController').getCurrentTrack();
    var event = {
      'isFavorited':(obj.get('favoriteDate') === undefined),
      'data': obj,
      'type':'track'
    };
    require('controllers/favorites').favoriteEventHandler(event);
  },
  previous: function () {require('media/playbackController').playPrevious();},
  pause: function () {require('media/playbackController').pause();},
  trackInfo: function () {
    var obj = require('media/playbackController').getCurrentTrack().attributes;
    return {
      'track':obj.title,
      'artist':obj.artist.name,
      'album':obj.album.title,
      'image':$('div.player div.image--player img[data-bind-src="imageUrl"]').attr('src'),
      'favorited':(obj.favoriteDate !== undefined)
    };
  }
}
