//
//  FocusAtWill.plist
//  BeardedSpice
//
//  Created by Ken Mickles on 1/15/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"focus@will",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*focusatwill.com*'",
    args: ["URL"]
  },
  toggle: function () { document.querySelector('button[class*="playButton"]').click() },
  next: function () { document.querySelector('button[class*="skipButton"]').click() },
  pause: function () { document.querySelector('button[class*="playButton"]').click() }
}
