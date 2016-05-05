//
//  Twitch.plist
//  BeardedSpice
//
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"twitch.tv",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*twitch.tv/*'",
    args:"url"
  },
  isPlaying: function isPlaying () {
      var doc = document;
      var frame = $('iframe[src^=\'http://player.twitch.tv/?channel=\']').get(0);
      if (frame) {
          doc = frame.contentDocument || frame.contentWindow.document;
      }
      return (doc.querySelector('.player[data-paused=\"false\"]') != null);
  },
  toggle: function toggle () {
    var doc = document;
    var frame = $("iframe[src^='http://player.twitch.tv/?channel=']").get(0);
    if (frame) {
        doc = frame.contentDocument || frame.contentWindow.document;
    }
    doc.querySelector('.js-control-playpause-button').click()
  },
  next: function next () {},
  favorite: function favorite () {},
  previous: function previous () {},
  pause: function pause () {
      var doc = document;
      var frame = $('iframe[src^=\'http://player.twitch.tv/?channel=\']').get(0);
      if (frame) {
          doc = frame.contentDocument || frame.contentWindow.document;
      }
      doc.querySelector('.player[data-paused="false"] .js-control-playpause-button').click()
  },
  trackInfo: function trackInfo () {}
}
