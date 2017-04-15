
//
//  Castro.fm.plist
//  BeardedSpice
//
//
BSStrategy = {
  version: 1,
  displayName: "Castro.fm",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*castro.fm/episode*'",
    args: ["URL"]
  },
  toggle: function () {document.querySelectorAll('#co-supertop-castro-play-pause')[0].click()},
  next: function () {document.querySelectorAll('#co-supertop-castro-skip-forward')[0].click()},
  previous: function () {document.querySelectorAll('#co-supertop-castro-skip-backward')[0].click()},
  pause: function () {document.querySelectorAll('#co-supertop-castro-play-pause')[0].click()},
  favorite: function () {},
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.
  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {
    var metadata = document.querySelector('#co-supertop-castro-metadata').innerText.split('\n');
    var track = metadata[0];
    var artist = metadata[1];
    var album = metadata[2];
    var progress = document.querySelector('#co-supertop-castro-playback-position').innerText;
    var image = document.querySelector('#artwork-container img').getAttribute('src');
    return {
      'track': track,
      'artist': artist,
      'album': album,
      'progress': progress,
      'image': image
    };
  }
}
