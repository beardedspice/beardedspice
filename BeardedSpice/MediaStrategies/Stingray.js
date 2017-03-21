//
//  Stingray.js
//  BeardedSpice
//
//  Created by Jean-Maxime Couillard on 2016-12-05.
//  Updated v2 by Jean-Maxime Couillard on 2017-03-20.
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
		return document.querySelectorAll('player-controls image-local.button')[0].click();
	},
	previous: function () {
	},
    next: function () {
        return document.querySelectorAll('player-controls image-local.button')[1].click();
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
