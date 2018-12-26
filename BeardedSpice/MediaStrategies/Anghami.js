//
//  Anghami.js
//  BeardedSpice
//
//  Created by Raja Baz on 08/24/2016. 
//  Updated by Yasser El-Sayed on 26/12/2018.
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
        return ($(".p-sub-item.playpause .icon-pause-2").length + $(".p-sub-item.playpause .buffering").length) > 0;
    },
    toggle: function () {
        $(".p-sub-item.playpause").click();
    },
    next: function () {
        $(".p-sub-item.next").click();
    },
    favorite: function () {
        $(".p-item.action.like").click();
    },
    previous: function () {
        $(".p-sub-item.previous").click();
    },
    pause: function () {
        $(".p-sub-item.play .icon-pause-2").click();
    },
    trackInfo: function () {
        return {
            'track': $(".track-title a").text(),
            'artist': $("a.track-artist").text(),
            'image': $(".cover-art img").attr('src'),
        };
    }
}
