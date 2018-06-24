//
//  YouTubeMusic.plist
//  BeardedSpice
//
//  Created by Cyril Find on 19/06/18.
//  Copyright (c) 2018 Cyril Find. All rights reserved.
//

BSStrategy = {
    version: 1,
    displayName: "Youtube Music",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*music.youtube.com/*'",
        args: ["URL"]
    },
    isPlaying: function () {
        return document.querySelector('paper-icon-button.play-pause-button').attributes['aria-label'] === "Pause"
    },
    toggle: function () {
        document.querySelector('paper-icon-button.play-pause-button').click()
    },
    previous: function () {
        document.querySelector('paper-icon-button.previous-button').click()
    },
    next: function () {
        document.querySelector('paper-icon-button.next-button').click()
    },
    favorite: function () {
        document.querySelector('paper-icon-button.like').click()
    },
    pause: function () {
        var e = document.querySelector('paper-icon-button.play-pause-button')
        if (e.attributes['aria-label'] === "Pause") {
            e.click()
        }
    },
    trackInfo: function () {
        return {
            'image': document.querySelector('img.image').src,
            'track': document.querySelector('.title.style-scope.ytmusic-player-bar').innerText,
            'artist': document.querySelector('span.subtitle.style-scope.ytmusic-player-bar > yt-formatted-string').innerText.replace(/\n|\r/g, ""),
            'progress': document.querySelector('span.time-info').innerText,
            'favorited': document.querySelector('paper-icon-button.like').attributes['aria-pressed'].value
        }
    }
}
