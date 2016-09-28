//
//  MixcloudBeta.plist
//  BeardedSpice
//
BSStrategy = {
  version:2,
  displayName:"Mixcloud Beta",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*beta.mixcloud.com*'",
    args: ["URL"]
  },
  isPlaying: function() {return (document.querySelector('.mz-player-control.mz-pause-state') != null)},
  pause: function () { var aButton = document.querySelector('.mz-player-control.mz-pause-state'); if(aButton) aButton.click() },
  toggle: function () { document.querySelector('.mz-player-control').click(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('.mz-player-cloudcast-title').text,
      'artist': document.querySelector('.mz-player-cloudcast-author-link').text,
      'image' : document.querySelector('div.mz-player img.loaded').getAttribute('src')
    }
  }
}
