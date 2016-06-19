//
//  StyleJukebox.js
//  BeardedSpice
//
//  Created by Roman Sokolov on 06/18/2016.
//  Copyright (c) 2016 Bearded Spice. All rights reserved.
//

BSStrategy = {
version:1,
displayName:"Style Jukebox",
accepts: {
method: "predicateOnTab",
format:"%K LIKE[c] '*play.stylejukebox.com*'",
args: ["URL"]
},
isPlaying: function(){return $('div.player-content span.play-button').hasClass('ng-hide');},
toggle: function () {$('div.player-content span.playpause').click();},
next: function () {$('div.player-content span.next').click();},
favorite: function (){$('div.player-content span.favoriteImage').click();},
previous: function () {$('div.player-content span.prev').click();},
pause: function () {if($('div.player-content span.play-button').hasClass('ng-hide')) $('div.player-content span.playpause').click();},
    
trackInfo: function () {
    var playerContent = $('div.player-content');
    return {
        'track': playerContent.find('span.song-title').get(0).innerText,
        'artist': playerContent.find('span.song-artist').get(0).innerText,
        'image': playerContent.find('div.playerAlbumArt img').attr('src'),
        'favorited': playerContent.find('img.favImage').attr('src').includes('favorites_active.')
    };
}
}
