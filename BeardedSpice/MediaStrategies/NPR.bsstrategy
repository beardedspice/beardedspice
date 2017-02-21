//
//  NPR.js
//  BeardedSpice
//
//  Created by Eli Goberdon on 2/17/2017.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
    version: 1,
    displayName: "NPR",
    accepts: {
        method: "predicateOnTab",
        //will this work with npr one strategy? does that strat work currently?
        format: "%K LIKE[c] '*npr.org*'",
        args: ["URL"]
    },

    isPlaying:function () {
        var e = document.querySelector('.player-basic');
        return e.classList.contains('is-playing');
    },
    toggle: function () {
        document.querySelector('.player-play-pause-stop').click()
    },
    next: function () {document.querySelector('.player-skip').click()},
    previous: function () {document.querySelector('.player-rewind').click()},
    favorite: function () {},
    pause: function () {
        var e = document.querySelector('.player-basic');
        if(e.classList.contains('is-playing')){
            e.click()
        }
    },
    trackInfo: function () {
        return {
            // @TODO
            // this splits on commas, so it would fail if the names had comma in them, might be better to
            // split based on quotes
            'track':  document.querySelector('.item-current h2').innerText.split(',')[1].replace(/\"/g,''),
            'album':  document.querySelector('.list-header__rest h3').innerText.split(',')[1].replace(/\'/g,''),
            'artist': document.querySelector('.item-current h2').innerText.split(',')[0],
            //@TODO - make this more sane
            'image':  document.querySelector('.playlistwrap.album').children[0].children[0].children[0].children[0].getAttribute('src')
        }
    }
}
