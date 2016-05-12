//
//  NoAdRadio.plist
//  BeardedSpice
//
BSStrategy = {
  version:1,
  displayName:"NoAdRadio",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*noadradio.com*'",
    args:"url"
  },
  isPlaying: function () { return (document.querySelector('#btn-playpause.pause') != null);},
  toggle: function () {document.querySelector('a#btn-playpause').click()},
  previous: function () {},
  next: function () {document.querySelector('a#btn-ff').click()},
  favorite: function () {},
  pause:function () {
    var e = document.querySelector('a#btn-playpause.pause');
    if(e != null) { e.click(); }
  },
  trackInfo: function () {
    return {
        'track': $('#current-song')[0].innerText,
        'artist': $('#player_current_artist a')[0].innerText,
        'favorited': false,
        'image': $('#player_main_pic_img').attr('src')
    };
  }
}
