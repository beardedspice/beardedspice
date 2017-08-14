//
//  Audiomack.plist
//  BeardedSpice
//
//  Created by Sean Coker on 08/10/17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
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
