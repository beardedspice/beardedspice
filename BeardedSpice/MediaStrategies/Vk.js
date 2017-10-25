//
//  newVk.js
//  BeardedSpice
//
//  Created by Max Kupetskii on 21/07/16.
//  Copyright © 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
        version: 3,
        displayName: "VK",
        accepts: {
        method: "predicateOnTab",
        format:"%K LIKE[c] '*vk.com*'",
        args: ["URL"]
    },
    isPlaying: function () {
        return (document.querySelector('#top_audio_player.top_audio_player_playing') != null);
    },
    toggle: function () {
        (function (w) {
         var el = document.querySelector('#top_audio_player > button.top_audio_player_btn.top_audio_player_play');
         if (el) { el.click(); return; }
         w.AudioUtils.showAudioLayer();
         var pollPlayerInterval = setInterval(
            (function(w){
                return function(){
                    var el = document.querySelector('.audio_page_player_play');
                    if (!el) { return; }
                    clearInterval(pollPlayerInterval);
                    el.click();
                    w.AudioUtils.showAudioLayer();
                }
            })(w), 10);
         }(window))
    },
    next: function () {
        var el = document.querySelector('#top_audio_player > button.top_audio_player_btn.top_audio_player_next');
        if (el) { el.click(); return; }
        return;
    },
    favorite: function () {
        (function (w) {
         var el = document.querySelector('.audio_page_player_add#add');
         if (el) { el.click(); return; }
         w.AudioUtils.showAudioLayer();
         var pollPlayerInterval = setInterval(
            (function(w){
                return function(){
                    var el = document.querySelector('.audio_page_player_add#add');
                    if (!el) { return; }
                    clearInterval(pollPlayerInterval);
                    el.click();
                    w.AudioUtils.showAudioLayer();
                }
            })(w), 10);
         }(window))
    },
    previous: function () {
        var el = document.querySelector('#top_audio_player > button.top_audio_player_btn.top_audio_player_prev');
        if (el) { el.click(); }
        return;
    },
    pause: function () {
        if (document.querySelector('#top_audio_player.top_audio_player_playing') != null) {
            var el = document.querySelector('#top_audio_player > button.top_audio_player_btn.top_audio_player_play');
            if (el) { el.click(); }
        }
        return;
            
    },
    trackInfo: function () {
        var fullTitle = document.querySelector('#top_audio_player > div.top_audio_player_title_wrap > div');
        var fullTitleText = fullTitle.textContent.split(" – ");
        if (!fullTitle) {
            return {};
        }
        return {
            'artist': fullTitleText[0],
            'track': fullTitleText[1]
        };
    },
}
