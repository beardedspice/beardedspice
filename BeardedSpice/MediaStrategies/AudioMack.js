//
//  AudioMack.plist
//  BeardedSpice
//
//  Created by Sean Coker on 12/11/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
    version:2,
    displayName:"Audiomack",
    accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*audiomack.com*'",
    args: ["URL"]
    },
    toggle: function () {
        window.amPlayer.paused() ? window.amPlayer.play() : window.amPlayer.pause();
    },
    isPlaying: function () {
        return !window.amPlayer.paused();
    },
    next: function () {
        window.amPlayer.next();
    },
    previous: function () {
        window.amPlayer.prev();
    },
    pause: function () {
        window.amPlayer.pause();
    },
    favorite: function () {
        window.amPlayer.favorite();
    },
    trackInfo: function () {
        var info = window.amPlayer.info();
        return {
            'artist': info.artist,
            'album': info.album,
            'track': info.title,
            'image': info.image,
            'progress': info.progress,
            'favorited': info.favorited
        }
    }
}
