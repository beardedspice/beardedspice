//
//  YouTube.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
youtube = {
    version: 1,
    displayName: "YouTube",
    acceptMethod: "predicateOnTab",
    acceptParams: {
        format: "SELF LIKE[c] '*youtube.com/watch*'",
        args: 'url'
    },
    isPlaying: function isPlaying () { return !document.querySelector('#movie_player video').paused; },
    toggle: function toggle () { document.querySelector('#movie_player .ytp-play-button').click(); },
    previous: function previous () { document.querySelector('#movie_player .ytp-prev-button').click(); },
    next: function next () { document.querySelector('#movie_player .ytp-next-button').click(); },
    pause: function pause () { document.querySelector('#movie_player video').pause(); },
    trackInfo: function trackInfo () {
        return {
            'image': document.querySelector('link[itemprop=thumbnailUrl]').getAttribute('href'),
            'track': document.querySelector('meta[itemprop=name]').getAttribute('content'),
            'artist': document.querySelector('.yt-user-info').innerText
        };
    }
}
