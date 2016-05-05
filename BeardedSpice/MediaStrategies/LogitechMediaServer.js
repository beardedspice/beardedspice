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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] 'Logitech Media Server'",
    args:"title"
  },
  toggle: function toggle () {return window.SqueezeJS.Controller.togglePause()},
  next: function next () {return document.querySelectorAll('#ctrlNext button')[0].click()},
  previous: function previous () {return document.querySelectorAll('#ctrlPrevious button')[0].click()},
  pause: function pause () {return window.SqueezeJS.Controller.playerControl(['pause'])},
  trackInfo: function trackInfo () {}
}
