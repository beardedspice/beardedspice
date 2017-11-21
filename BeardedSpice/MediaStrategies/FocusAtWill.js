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
  next: function () { window.faw.skip() },
  toggle: function () {
    window.faw.isPlaying ? window.faw.stop() : window.faw.play()
  },
  trackInfo: function () {
    var FindReact = function(dom) {
        for (var key in dom) {
            if (key.startsWith("__reactInternalInstance$")) {
                var compInternals = dom[key]._currentElement;
                var compWrapper = compInternals._owner;
                var comp = compWrapper._instance;
                return comp;
            }
        }
        return null;
    };
    var footerDiv = document.querySelector('header + footer div:first-child');
    var trackInfo = FindReact(footerDiv).props.currentTrack;
    return {
      "track": trackInfo.trackName,
      "artist": trackInfo.artistName,
    };
  }
}
