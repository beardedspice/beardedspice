//
//  Qobuz.js
//  BeardedSpice
//
//  Created by Roman Sokolov on 15.10.16.
//  Copyright (c) 2016 BeardedSpice. All rights reserved
//
BSStrategy = {
  version:1,
  displayName:"Qobuz",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*player.qobuz.com*'",
    args: ["URL"]
  },
  isPlaying: function () {return qbPlayer.playerManager.isPlaying();},
  toggle: function () {qbPlayer.playerManager.togglePause();},
  next: function () {qbPlayer.playerManager.next();},
  previous: function () {qbPlayer.playerManager.previous();},
  pause: function () {if (qbPlayer.playerManager.isPlaying()) qbPlayer.playerManager.togglePause();},
  favorite: function () {
      if (qbPlayer.globalManager.isFavorite("track", qbPlayer.playerManager.currentTrack.id)) {
          qbPlayer.actionManager.triggerEvent("deleteFromFavorites", {
              type: "track",
              ids: [qbPlayer.playerManager.currentTrack.id],
              label: qbPlayer.playerManager.currentTrack.metadata.title});
      }
      else {
          qbPlayer.actionManager.triggerEvent("addToFavorites", {
              type: "track",
              ids: [qbPlayer.playerManager.currentTrack.id],
              label: qbPlayer.playerManager.currentTrack.metadata.title});
      }
  },
  trackInfo: function () {
    return {
        track:  qbPlayer.playerManager.currentTrack.metadata.title,
      artist: qbPlayer.playerManager.currentTrack.metadata.artistName,
      album: qbPlayer.playerManager.currentTrack.metadata.albumTitle,
      favorited: qbPlayer.globalManager.isFavorite("track", qbPlayer.playerManager.currentTrack.id),
      image: qbPlayer.playerManager.currentTrack.metadata.picture
    };
  }
}
