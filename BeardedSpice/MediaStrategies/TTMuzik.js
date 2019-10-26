//
//  TTNETMuzik.m
//  BeardedSpice
//
//  Created by Bilal Demirci on 08/03/16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "TT Muzik",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*turktelekommuzik.com*'",
    args: ["URL"]
  },
  toggle:   function () { document.querySelector('#player-play').click(); },
  previous: function () { document.querySelector('#player-prev').click(); },
  next:     function () { document.querySelector('#player-next').click(); },
  pause:    function () { document.querySelector('#player-play').click(); },
}
