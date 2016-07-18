//
//  Vk.plist
//  BeardedSpice
//
//  Created by Anton Mihailov on 17/06/14.
//  Copyright (c) 2014 Anton Mihailov. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName:"VK",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*vk.com*'",
    args: ["URL"]
  },
  isPlaying: function () { !!document.querySelector('#ac_play.playing, #gp_play.playing'); },
  toggle: function () {
    (function (w) {
      var el = document.querySelector('#ac_play, #gp_play');
      if (el) { el.click(); return; }
      w.Pads.show('mus', null);
      var pollPlayerInterval = setInterval(
      (function(w){
          return function(){
              var el = document.querySelector('#pd_play');
              if (!el) { return; }
              clearInterval(pollPlayerInterval);
              el.click();
              w.Pads.hide('mus', null);
          }
      })(w),10);
    }(window))
  },
  next: function () {
    (function (w) {
      var el = document.querySelector('#ac_next');
      if (el) { el.click(); return; }
      w.Pads.show('mus', null);
      var pollPlayerInterval = setInterval(
      (function(w){
          return function(){
              var el = document.querySelector('#pd_next');
              if (!el) { return; }
              clearInterval(pollPlayerInterval);
              el.click();
              w.Pads.hide('mus', null);
          }
      })(w), 10);
    }(window))
  },
  favorite: function () {
    (function (w) {
      var el = document.querySelector('#ac_add');
      if (el) { el.click(); return; }
      w.Pads.show('mus', null);
      var pollPlayerInterval = setInterval(
      (function(w){
          return function(){
              var el = document.querySelector('#pd_add');
              if (!el) { return; }
              clearInterval(pollPlayerInterval);
              el.click();
              w.Pads.hide('mus', null);
          }
      })(w), 10);
    }(window))
  },
  previous: function () {
    (function (w) {
      var el = document.querySelector('#ac_prev');
      if (el) { el.click(); return; }
      w.Pads.show('mus', null);
      var pollPlayerInterval = setInterval( (function(w){
          return function(){
              var el = document.querySelector('#pd_prev');
              if (!el) { return; }
              clearInterval(pollPlayerInterval);
              el.click();
              w.Pads.hide('mus', null);
          }
      })(w), 10);
    }(window))
  },
  pause: function () {
    (function (w) {
      var el = document.querySelector('#ac_play.playing, #gp_play.playing');
      if (el) { el.click(); return; }
      w.Pads.show('mus', null);
      var pollPlayerInterval = setInterval(
      (function(w){
          return function(){
              var el = document.querySelector('#pd_play.playing');
              if (!el) { return; }
              clearInterval(pollPlayerInterval);
              el.click();
              w.Pads.hide('mus', null);
          }
      })(w), 10);
      setTimeout(function(){clearInterval(pollPlayerInterval);}, 1000);
    }(window))
  },
  trackInfo: function () {
    (function (w) {
      var titleEl = document.querySelector('span#ac_title, #gp_title');
      var artistEl = document.querySelector('span#ac_performer, #gp_performer');
      if (! titleEl || ! artistEl) {
          w.Pads.show('mus', null);
          titleEl = document.querySelector('span#pd_title'),
          artistEl = document.querySelector('span#pd_performer');
          w.Pads.hide('mus', null);
      }
      if (!(titleEl && artistEl)) {
        return {};
      }
      return {
          'title': titleEl.firstChild.nodeValue,
          'artist': artistEl.firstChild.nodeValue
      };
    }(window))
  },
}
