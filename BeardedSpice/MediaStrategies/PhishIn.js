//
//  PhishIn.plist
//  BeardedSpice
//
//  Created by Frank Febbraro on 01/06/2017.
//  Copyright (c) 2017 Frank Febbraro. All rights reserved.
//
BSStrategy = {
version: 1,
displayName: "PhishIn",
accepts: {
method: "predicateOnTab",
format: "%K LIKE[c] '*phish.in*'",
args: ["URL"]
},
isPlaying: function () { return document.querySelector('#control_playpause.playing') !== null; },
toggle: function () { document.querySelector('#control_playpause').click(); },
previous: function () { document.querySelector('#control_previous').click(); },
next: function () { document.querySelector('#control_next').click(); },
pause: function () { document.querySelector('#control_playpause.playing').click(); },
trackInfo: function () {
    return {
        'track': document.querySelector('#player_title').innerText,
        'album': document.querySelector('#player_detail').innerText,
        'artist': 'Phish'
    };
}
}
