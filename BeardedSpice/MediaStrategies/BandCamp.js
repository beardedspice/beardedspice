//
//  BandCamp.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
    version: 3,
    displayName: "BandCamp",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*bandcamp.com*'",
        args: ["URL"]
    },
    isPlaying: function () {
        var obj = document.querySelector('div.playbutton');
        if (obj) {
            return obj.classList.contains('playing');
        }
        obj = document.querySelector('div.carousel-player.show div.playpause > div.play');
        if (obj) {
            return obj.style.display === 'none';
        }
        return false;
    },
    pause: function () { if (document.querySelector('svg#topbarPlayerButtons>use').href.baseVal == "#icon-playback-topbar-playing") document.querySelector('div.player__button_stream-center').click(); },
    toggle: function () { document.querySelector('div.player__button_stream-center').click(); },
    next: function () { BSStrategy.seek(30); },
    previous: function () { if (BSStrategy.seek(-30) < 0) document.querySelector('div.player__button_stream-other-left').click(); },
    trackInfo: function () {
        let result = {
            'track': document.querySelector('div.mix-shortcut-time__topbar__title>span:nth-child(2)').textContent,
            'artist': document.querySelector('div.mix-shortcut-time__topbar__title>span:nth-child(1)').textContent,
            'progress': document.querySelector('div.mix-shortcut-time__topbar__current').textContent + ' of ' + document.querySelector('div.mix-shortcut-time__topbar__estimated').textContent
        };

        let bgImage = document.querySelector('div.player__controls_playlist-current').style.backgroundImage;
        if (bgImage) {
            try {
                bgImage = /url\(\"(.+)\"\)/.exec(bgImage)[1];
                if (bgImage.length > 0) {
                    let url = new URL(bgImage, document.baseURI)
                    result['image'] = url.href;
                }
            }
            catch (error) {
            }
        }
        return result;
    }
}
