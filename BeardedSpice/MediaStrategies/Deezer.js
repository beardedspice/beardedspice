//
//  Deezer.plist
//  BeardedSpice
//
//  Created by Greg Woodcock on 06/01/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

BSStrategy = {

version:2,
displayName:"Deezer",
accepts: {
method: "predicateOnTab",
format:"%K LIKE[c] '*deezer.com*'",
args: ["URL"]
},
isPlaying: function(){return dzPlayer.isPlaying();},
toggle: function () {dzPlayer.control.togglePause()},
next: function () {dzPlayer.control.nextSong()},
favorite: function (){document.querySelector('div.player-actions span.icon-love').click()},
previous: function () {dzPlayer.control.prevSong()},
pause: function () {dzPlayer.control.pause()},
    
trackInfo: function () {
    var info = dzPlayer.getCurrentSong();
    return {
        'track': info["SNG_TITLE"] + (info["VERSION"] == "" ? "" : " " + info["VERSION"]),
        'album': info["ALB_TITLE"],
        'artist': dzPlayer.getArtistName(),
        'image': 'http://cdn-images.deezer.com/images/cover/' + info["ALB_PICTURE"]+ '/250x250.jpg',
        'favorited': userData.isFavorite('song',info["SNG_ID"])
    };
}
    
}
