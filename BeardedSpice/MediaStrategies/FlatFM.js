//
//  Flat.fm
//  BeardedSpice
//
//  Created by Roman Sokolov.
//  Copyright (c) 2015-2020 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"Flat.FM",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*/flat.fm/*'",
    args: ["URL"]
  },
  seek: function(offset) {
    let hmsToSeconds = function (str) {
        var p = str.split(':'),
            s = 0, m = 1;

        while (p.length > 0) {
            s += m * parseInt(p.pop(), 10);
            m *= 60;
        }

        return s;
    }
    let newPosition = hmsToSeconds(document.querySelector('div.mix-shortcut-time__topbar__current').textContent) + offset;
    let timeEnd = hmsToSeconds(document.querySelector('div.mix-shortcut-time__topbar__estimated').textContent);
    if (newPosition > timeEnd) newPosition = timeEnd;
    let elem = document.querySelector('div.player__seekbar_stream');
    let elemRect = elem.getBoundingClientRect();
    let x = newPosition*elemRect.width/timeEnd;
    let y = elemRect.y+ elemRect.height/2;
    let eventData = {'view': window, 'bubbles': true, 'cancelable': true, 'clientX': x, 'clientY': y};
    elem.dispatchEvent((new MouseEvent('mousedown', eventData)));
    elem.dispatchEvent((new MouseEvent('mouseup', eventData)));
    return newPosition;
  },
  isPlaying: function() {return (document.querySelector('svg#topbarPlayerButtons>use').href.baseVal == "#icon-playback-topbar-playing")},
  pause: function () { if (document.querySelector('svg#topbarPlayerButtons>use').href.baseVal == "#icon-playback-topbar-playing") document.querySelector('div.player__button_stream-center').click(); },
  toggle: function () { document.querySelector('div.player__button_stream-center').click(); },
  next: function() {BSStrategy.seek(30);},
  previous: function() {if (BSStrategy.seek(-30) < 0) document.querySelector('div.player__button_stream-other-left').click();},
  trackInfo: function () {
      let result = {
      'track': document.querySelector('div.mix-shortcut-time__topbar__title>span:nth-child(2)').textContent,
      'artist': document.querySelector('div.mix-shortcut-time__topbar__title>span:nth-child(1)').textContent,
      'progress': document.querySelector('div.mix-shortcut-time__topbar__current').textContent + ' of ' + document.querySelector('div.mix-shortcut-time__topbar__estimated').textContent
    };

      let bgImage = document.querySelector('div.player__controls_playlist-current').style.backgroundImage;
      if (bgImage) {
          try {
              bgImage = /url\(\"(.+)\"\)/.exec(bgImage)[1];
              if (bgImage.length > 0) {
                  let url = new URL( bgImage, document.baseURI)
                  result['image'] = url.href;
              }
          }
          catch (error) {
          }
      }
      return result;
  }
}
