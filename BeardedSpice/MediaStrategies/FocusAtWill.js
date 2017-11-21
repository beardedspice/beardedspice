//
//  FocusAtWill.plist
//  BeardedSpice
//
//  Created by Jayphen on 11/21/17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:2,
  displayName:"focus@will",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*focusatwill.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return window.faw.isPlaying
  },
  toggle: function () {window.faw.play()},
  next: function () { document.querySelector('a.next').click() },
  pause: function () { document.querySelector('a.play').click() }
}
