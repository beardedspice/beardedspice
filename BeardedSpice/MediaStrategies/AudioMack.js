//
//  AudioMack.plist
//  BeardedSpice
//
//  Created by Sean Coker on 12/11/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"AudioMack",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*audiomack.com*'",
    args: ["URL"]
  },
  toggle: function () {
    var player = document.getElementById('listplayer');
    var play_button = document.getElementById('play-button');
    if (player && player.clientHeight) {
        play_button.click();
        return;
    }
    var feed_buttons = document.querySelectorAll('.feed a.play');
    if (feed_buttons.length) {
        feed_buttons[0].click();
        return;
    }
    if (play_button) { play_button.click(); }
  },
  next: function () {
    var player = document.getElementById('listplayer');
    if (player && player.clientHeight) {
        var next_button = player.querySelector('.next-track');
        next_button.click();
        return;
    }
    var feed_buttons = document.querySelectorAll('.feed a.play');
    if (feed_buttons.length) {
        feed_buttons[0].click();
        return;
    }
  },
  previous: function () {
    var player = document.getElementById('listplayer');
    if (player && player.clientHeight) {
        var prev_button = player.querySelector('.prev-track');
        prev_button.click();
        return;
    }
    var feed_buttons = document.querySelectorAll('.feed a.play');
    if (feed_buttons.length) {
        feed_buttons[0].click();
        return;
    }
  },
  pause: function () {
    var play_button = document.getElementById('play-button');
    if (play_button.className.indexOf('pause') > 1) {
        play_button.click();
    }
  }
}
