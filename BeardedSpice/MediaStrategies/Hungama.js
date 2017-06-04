//
//  Hungama.js
//  BeardedSpice
//
//  Created by tanmaysachan on 6/4/2017.
//  Copyright (c) 2017 tanmaysachan. All rights reserved.
//

BSStrategy = {
	version:1,
	displayName:"Hungama",
	accepts: {
		method: "predicateOnTab",
		format:"%K LIKE[c] '*hungama.com*'",
		args: ["URL"]
	},

	isPlaying: function () {
		if(document.getElementsByClassName("jp-play")[0].getAttribute("data-tooltip") === "Pause"){
			return true;
		}
		else{
			return false;
		}		  
	},

	toggle: function(){
		document.getElementsByClassName("jp-play")[0].click();	
	},
	next: function() {
		document.getElementsByClassName("jp-next")[0].click();
	},
	previous: function() {
		document.getElementsByClassName("jp-previous")[0].click();
	},
	pause: function() {
		if(document.getElementsByClassName("jp-play")[0].getAttribute("data-tooltip") === "Pause")
			document.getElementsByClassName("jp-play")[0].click();
	},
	play: function(){
		if(document.getElementsByClassName("jp-play")[0].getAttribute("data-tooltip") === "Play")
			document.getElementsByClassName("jp-play")[0].click();
	},
	trackInfo: function() {
		return {
			'track': getElementsByClassName("jw-songName")[0].innerText,
			'album': getElementsByClassName("jw-songAlbum")[0].innerText,
			'image': getElementsbyClassName("jw-albumThumb")[0].src
		}
	}

}
