//
//  Chorus.plist
//  BeardedSpice
//
//  Created by Mark Reid on 10/01/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Chorus",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '▶ * | Chorus.'",
    args: "title"
  },
  toggle: function () {return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.togglePlay() : app.shellView.playerPlay() },
  next: function () {return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.next() : app.shellView.playerNext()},
  previous: function () {return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.prev() : app.shellView.playerPrev() },
  pause: function () {return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.pause(): true },
}
