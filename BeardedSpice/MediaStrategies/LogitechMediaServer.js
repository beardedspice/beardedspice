//
//  Media.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Logitech Media Server",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] 'Logitech Media Server'",
    args: ["title"]
  },
  toggle: function () {return window.SqueezeJS.Controller.togglePause()},
  next: function () {return document.querySelectorAll('#ctrlNext button')[0].click()},
  previous: function () {return document.querySelectorAll('#ctrlPrevious button')[0].click()},
  pause: function () {return window.SqueezeJS.Controller.playerControl(['pause'])},
  trackInfo: function () {}
}
