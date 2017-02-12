//
//  PhishTracks.plist
//  BeardedSpice
//
//  Created by Frank Febbraro on 01/05/2017.
//  Copyright (c) 2017 Frank Febbraro. All rights reserved.
//
BSStrategy = {
    version: 1,
    displayName: "PhishTracks",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*phishtracks.com*'",
        args: ["URL"]
    },
    isPlaying: function () { return document.querySelector('#playBtn span.pause') !== null; },
    toggle: function () { document.querySelector('#playBtn').click(); },
    previous: function () { document.querySelector("[data-control='prev']").click(); },
    next: function () { document.querySelector("[data-control='next']").click(); },
    pause: function () { if(isPlaying()) { document.querySelector('#playBtn').click(); } },
    trackInfo: function () {
        return {
            'image': document.querySelector('meta[property="og:image"]').getAttribute('content'),
            'track': document.querySelector('#player h2 a').text,
            'album': document.querySelector('#player h3 a').text,
            'artist': 'Phish'
        };
    }
}
