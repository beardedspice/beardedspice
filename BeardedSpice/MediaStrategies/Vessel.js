//
//  VesselStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 2/7/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "Vessel",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format: "SELF LIKE[c] '*vessel.com/videos/*'",
    args: "url"
  },
  isPlaying: function isPlaying () { return !(document.querySelector('video.video-show').paused)},
  toggle: function toggle () {
    v = document.querySelector('video.video-show');
    if (v.paused) {
      v.play();
    }
    else {
      v.pause();
    }
  },
  previous: function previous () {},
  next: function next () {},
  pause: function pause () {document.querySelector('video.video-show').pause()},
  play: function play () {document.querySelector('video.video-show').play()},
  favorite: function favorite () {},
  trackInfo: function trackInfo () {
    return {
      'track': document.title.substr(6),
      'image': document.querySelector('img[style="width:34px;height:34px;border-bottom-left-radius:4px;border-top-left-radius:4px;"]').src.replace(/?w=.*/, '')
    };
  }
}
