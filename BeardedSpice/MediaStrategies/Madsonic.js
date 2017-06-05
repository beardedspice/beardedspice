//
//  Madsonic.js
//  BeardedSpice
//
//  Created by Matt Behrens on 2017/05/20
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
//  Tested with:
//  v1 - Madsonic 6.2.9080
//
BSStrategy = {
    version:1,
    displayName:"Madsonic",
    accepts: {
        method: "predicateOnTab",
        format:"%K LIKE[c] '*Madsonic*'",
        args: ["title"]
    },

    isPlaying: function () {
        var is_playing = parent.frames.playQueue.document.querySelector('#startButton').style.display === "none";
        return is_playing;
    },

    toggle:function () {
        var is_playing = parent.frames.playQueue.document.querySelector('#startButton').style.display === "none";
        if (is_playing) {
            parent.frames.playQueue.document.querySelector('#stopButton').click();
        } else {
            parent.frames.playQueue.document.querySelector('#startButton').click();
        }
    },

    next:function () {
        parent.frames.playQueue.document.querySelector('#nextButton').click();
    },
    favorite: function () {
        parent.frames.playQueue.document.querySelector('#starred_off').click();
    },
    previous:function () {
        parent.frames.playQueue.document.querySelector('#previousButton').click();
    },
    pause:function () {
        parent.frames.playQueue.document.querySelector('#stopButton').click();
    },

    trackInfo: function () {
        frame = parent.frames.playQueue;
        return {
            'track': frame.document.querySelector('#songName').innerText,
            'artist': frame.document.querySelector('#artistName').textContent,
            'favorited': frame.parent.frames.playQueue.document.querySelector('#starred_on').style.display === "none",
            'image': frame.document.querySelector('#coverArt').src,
        };
    }
}
