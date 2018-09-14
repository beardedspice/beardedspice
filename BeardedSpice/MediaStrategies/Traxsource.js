// Traxsource.plist
// BeardedSpice

// Created by Mat Johnson on 14/09/18.

BSStrategy = {
  version: 2,
  displayName: "Traxsource",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*traxsource.com*'",
    args: ["URL"]
  },
  //Check for the style element of display: none
  isPlaying: function () { return document.querySelector('.jp-play').style.display === "none"; },
  toggle: function () {
    var play = document.querySelector('.jp-play'),
        pause = document.querySelector('.jp-pause');
    if (play.style.display == "none") { pause.click();} else { play.click();}
  },
  previous: function () { document.querySelector('.jp-previous').click();},
  next: function () { document.querySelector('.jp-next').click();},
  pause: function () { document.querySelector('.jp-pause').click();},
  favorite: function () { document.querySelector('.cart-alt-dummy').click();},
  trackInfo: function () {
    var info = document.querySelectorAll('.com-artist a'),
        artists = [];
    for (i = 0; i < info.length; i++) { artists.push(info[i].innerText);}

    artists = artists.filter(function(item, pos, self) {
      return self.indexOf(item) == pos;
    });
    var track = document.querySelector('.com-title').innerText

    var artwork = document.querySelector('.pinfo-image').getAttribute('src')
                 .replace(/[0-9]+x[0-9]+/,'600x600');
    return {
      track: track,
      //album: album,
      artist: artists.join(", "), //(" & ")
      image: artwork,
      favorited: document.querySelector('.cart-alt-dummy') != null
    };
  }
}
