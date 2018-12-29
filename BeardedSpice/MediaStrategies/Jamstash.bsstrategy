//
//  Jamstash.js
//  BeardedSpice
//
//  Created by ALKOUM dorian on 2018/12/27
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
    version: 1,
    displayName: "Jamstash",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*jamstash.com*'",
        args: ["URL"]
    },

    isPlaying: function () {
        var isPlaying = document.querySelector('.PlayTrack').style.display === "none";

        return isPlaying;
    },

    toggle: function () {
        var isPlaying = document.querySelector('.PlayTrack').style.display === "none";
        if (isPlaying) {
            document.querySelector('.PauseTrack').click();
        } else {
            document.querySelector('.PlayTrack').click();
        }
    },

    previous: function () {
        document.querySelector('#PreviousTrack').click();
    },

    next: function () {
        document.querySelector('#NextTrack').click();
    },

    pause: function () {
        var isPlaying = document.querySelector('.PlayTrack').style.display === "none";
        if (isPlaying) {
            document.querySelector('.PauseTrack').click();
        }
    },

    favorite: function () {
        var favoriteButton = document.querySelector('#songdetails_controls .rate');
        if (favoriteButton) {
            favoriteButton.click();
        }
    },

    trackInfo: function () {
        var meta = document.querySelector('a.playbackSoundBadge__title.sc-truncate');
        return {
            // 'Artist' can't be fetched from the app, at least not on every page
            'track': document.querySelector('#songdetails .song').textContent,
            'album': document.querySelector('#songdetails .album').textContent,
            'image': document.querySelector('#songdetails #coverart img').src.replace(/size=30/g, 'size=300'),
            'favorited': !!document.querySelector('#songdetails_controls .favorite'),
        }

    }
}
