//
//  Stingray.js
//  BeardedSpice
//
//  Created by Jean-Maxime Couillard on 2016-12-05.
//  Updated v2 by Jean-Maxime Couillard on 2017-03-20.
//  Updated v3 by Jean-Maxime Couillard on 2017-05-21.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
	version: 2,
	displayName: "Stingray",
	accepts: {
		method: "predicateOnTab" /* OR "script" */,
		format: "%K LIKE[c] '*webplayer.stingray.com*'",
		args: ["URL"]
	},
	isPlaying: function () {
		return (document.querySelectorAll("minimized-player .stopped-info").length === 0);
	},
    toggle: function () {
        var buttons = document.querySelectorAll('player-controls image-local.button');
        return buttons[buttons.length-3].click();
	},
	previous: function () {
	},
    next: function () {
        var buttons = document.querySelectorAll('player-controls image-local.button');
        return buttons[buttons.length-2].click();
	},
	pause: function () {
	},
	favorite: function () {
	},
	trackInfo: function () {
		return {
			'track': document.querySelector(".track-info-container .title").innerText.trim().split("\n")[0],
			'album': document.querySelector(".track-info-container .album").innerText.trim().split("\n")[0],
			'artist': document.querySelector(".track-info-container .artist").innerText.trim().split("\n")[0],
			'image': document.querySelector(".album-cover .background").getAttribute("style").match(/(?:url)\((.*?)\)/)[1].replace(/('|")/g, ''),
		};
	}
}
