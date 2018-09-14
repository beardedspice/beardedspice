BSStrategy = {
  version: 4,
  displayName: "Deezer",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*deezer.com*'",
    args: ["URL"]
  },
  isPlaying: function() {
    return document.querySelector('.player-controls .svg-icon-play') == null;
  },
  toggle: function () {
    document.querySelector('.player-controls .svg-icon-play, .player-controls .svg-icon-pause').parentElement.click()
  },
  next: function () {
    document.querySelector('.player-controls .svg-icon-next').parentElement.click();
  },
  favorite: function () {
    if(!this.isFavorite()) {
      document.querySelector('.track-actions .svg-icon-love-outline').parentElement.click()
    }
  },
  previous: function () {
    document.querySelector('.player-controls .svg-icon-prev').parentElement.click();
  },
  pause: function () {
    if(el = document.querySelector('.player-controls .svg-icon-pause')){
      el.parentElement.click()
    }
  },
  isFavorite: function() {
    return document.querySelector('.track-actions .svg-icon-love-outline').classList.contains('is-active')
  },
  trackInfo: function () {
    track_and_artist = document.querySelector('.track-title').innerText.replace(/^\s+|\s+$/g, '').split(" · ");
    return {
      "track": track_and_artist[0],
      "artist": track_and_artist[1],
      "image": null,
      "favorited": this.isFavorite()
    };
  }
}
