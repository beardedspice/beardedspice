//
//  WonderFm.plist
//  BeardedSpice
//
//  Created by Kyle Conarro on 2/3/15.
//  Edited  by Richard Schreiber on 12/18/16
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
    version: 1,
    displayName: "WonderFM",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*wonder.fm*'",
        args: ["URL"]
    },
    isPlaying: function () {
        var isPlaying = !document.querySelector(".show--activeTrack .player-play").classList.contains("ng-hide");
        return isPlaying;
    },
    toggle: function () {
        var isPlaying = !document.querySelector(".show--activeTrack .player-play").classList.contains("ng-hide");
        var btn = isPlaying ? document.querySelector(".show--activeTrack .player-pause") : document.querySelector(".show--activeTrack .player-play");
        var evt = document.createEvent("MouseEvents");

        evt.initMouseEvent("click", true, true, window, 1, 0, 0, 0, 0,
                false, false, false, false, 0, null);
        btn.dispatchEvent(evt);
    },
    next: function () {
        var btn = document.querySelector(".show--activeTrack .player-skip");
        var evt = document.createEvent("MouseEvents");

        evt.initMouseEvent("click", true, true, window, 1, 0, 0, 0, 0,
                false, false, false, false, 0, null);
        btn.dispatchEvent(evt);
    },
    favorite:function () {
        var btn = document.querySelector(".track--active .track-fav");
        var evt = document.createEvent("MouseEvents");

        evt.initMouseEvent("click", true, true, window, 1, 0, 0, 0, 0,
                false, false, false, false, 0, null);
        btn.dispatchEvent(evt);
    },
    previous: function () {
        var t = document.querySelector(".track--active"),
            p = document.querySelector(".player__scrubber");
        if (!t) {return;}
        if (p && p.value > 0.01) {/* rewind instead of previous song if playhead further than 1% */
            t = p;
        }
        else {
            while (t = t.previousSibling) {
                if (t.classList && t.classList.contains("track")) {break;}
            }   
        }
        if (t) {
            var evt = document.createEvent("MouseEvents");

            evt.initMouseEvent("click", true, true, window, 1, 0, 0, 0, 0,
                    false, false, false, false, 0, null);
            t.dispatchEvent(evt);
        }
    },
    pause: function () {
        var btn = document.querySelector(".show--activeTrack .player-pause");
        var evt = document.createEvent("MouseEvents");

        evt.initMouseEvent("click", true, true, window, 1, 0, 0, 0, 0,
                false, false, false, false, 0, null);
        btn.dispatchEvent(evt);
    },
    trackInfo: function () {
        return {
            "track": document.querySelector(".track--active .track-name > a").text,
            "artist": document.querySelector(".track--active .track-artist > a").text
        };
    }
};
