//
//  Anghami.js
//  BeardedSpice
//
//  Created by Raja Baz on 08/24/2016.
//

BSStrategy = {
    version:1,
    displayName:"Anghami",
    accepts: {
        method: "predicateOnTab",
        format:"%K LIKE[c] '*play.anghami.com*'",
        args: ["URL"]
    },
    isPlaying: function () {
        return ($(".action.play .icon-pause").length + $(".action.play .loader").length) > 0;
    },
    toggle: function () {
        $(".action.play").click();
    },
    next: function () {
        $('.action.next').click();
    },
    favorite: function () {
        $(".action.extras .icon-like").click();
    },
    previous: function () {
        $('.action.previous').click();
    },
    pause: function () {
        $(".action.play .icon-pause").click();
    },
    trackInfo: function () {
        return {
            'track': $("a.track-title").text(),
            'artist': $("a.track-artist").text(),
            'image': $(".cover-art img")[0].src,
        };
    }
}
