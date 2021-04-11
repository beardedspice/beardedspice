//
//  BandCamp.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
    version: 4,
    displayName: "BandCamp",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*bandcamp.com*'",
        args: ["URL"]
    },
    onClick: function() {
        BSStrategy.pAudio();
    },
    isPlaying: function () {
        return BSStrategy.pAudio() != null;
    },
    pause: function () {
        let au = BSStrategy.pAudio();
        if (au != null) {
            au.pause();
            return true;
        }
        return false;
    },
    toggle: function () { 
        if (! BSStrategy.pause()) {
            let au = BSStrategy.lastPlayed || document.querySelectorAll('audio[src]')[0];
            if (au) au.play();
        }
    },
    next: function () { 
        BSStrategy.lastControllerData.next();
    },
    previous: function () { 
        BSStrategy.lastControllerData.prev();
    },
    favorite:function () {
        BSStrategy.lastControllerData.fav();
    },
    trackInfo: function () {
        if (BSStrategy.lastControllerData && BSStrategy.lastControllerData.info) { 
            return BSStrategy.lastControllerData.info();
        }
        return null;
    },
    // custom (private)
    lastPlayed: null,
    lastControllerData: null,
    pAudio: function () {
        let audio = document.querySelectorAll('audio[src]');
        for(var i = 0; i < audio.length; i++) {
            if (audio[i].paused == false) {
                BSStrategy.lastPlayed = audio[i];
                BSStrategy.pController();
                return BSStrategy.lastPlayed;                
            }
        }
        return null;
    },
    pController: function () {
        let nextElem = null;
        let prevElem = null;
        let titleElem = null;
        let artistElem = null;
        let albumElem = null;
        let imgElem = null;
        let favedAction = null;
        let favElem = null;
        let favAction = null;
        let found = false;

        //try to find controller - new and notable main view 
        if (!found) {
            let controller = document.querySelector("div.notable-item a.item-img.playing");
            if (controller) {
                let p = controller;
                imgElem = p.querySelector("img");
                p = p.parentElement;
                titleElem = p.querySelector(".item-title > a > span:nth-child(1)");
                artistElem = p.querySelector(".item-title > a > span.item-artist > span");
                let favedElem = p.querySelector(".collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favedElem = null;
                }
                else {
                    favAction = () => {
                        let css = (favedElem && favedElem.classList.contains('wishlisted')) ? ".wishlisted-msg" : ".wishlist-msg";
                        favedElem.querySelector(css).click();
                    }
                    favedAction = () => { return (favedElem && favedElem.classList.contains('wishlisted')) == true; };
                    if (!titleElem) {
                        titleElem = albumElem;
                    }
                }
                found = true;
            }
        }

        //try to find controller - bottom panel 
        let controllers = document.querySelectorAll("div.carousel-player.show div.playpause div.pause");
        if (controllers) {
            for (let i = 0; i < controllers.length; i++) {
                const element = controllers[i];
                if (element.style.display != "none") {
                    let p = element.parentElement.parentElement;
                    nextElem = p.querySelector("div.transport div.next-icon");
                    prevElem = p.querySelector("div.transport div.prev-icon");
                    titleElem = p.querySelector("div.info-progress > div.info > div.title > a > span:nth-child(2)")
                                || p.querySelector("div.info-progress > div.info > div.title > a > span");
                    p = p.parentElement;
                    artistElem = p.querySelector("div.now-playing div.artist > span");
                    albumElem = p.querySelector("div.now-playing div.title");
                    imgElem = p.querySelector("div.now-playing > a > img");
                    favElem = p.querySelector("span.wishlisted-msg.collection-btn > a");
                    let favedElem = p.querySelector("div.item-collection-controls.collect-item");
                    if (favedElem.classList.contains("purchased")) {
                        favElem = null;
                    }
                    else {
                        favedAction = () => {return (favedElem && favedElem.classList.contains('wishlisted')) == true;};
                    }
                    found = true;
                    break;
                }
            }
        }

        //try to find controller - album view 
        if (!found) {
            let controller = document.querySelector("#trackInfoInner div.inline_player div.playbutton.playing");
            if (controller) {
                let p = controller.parentElement.parentElement.parentElement;
                titleElem = p.querySelector("td.track_cell span.title-section span");
                p = p.parentElement;
                nextElem = p.querySelector("td.next_cell div.nextbutton");
                prevElem = p.querySelector("td.prev_cell div.prevbutton");
                p = p.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
                artistElem = p.querySelector("#name-section a");
                albumElem = p.querySelector("#name-section .trackTitle");
                imgElem = p.querySelector("#tralbumArt img");
                let favedElem = p.querySelector("#collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favElem = null;
                }
                else {
                    favAction = () => {
                        let css = (favedElem && favedElem.classList.contains('wishlisted')) ? "#wishlisted-msg" : "#wishlist-msg";
                        favedElem.querySelector(css).click();
                    }
                    favedAction = () => { return (favedElem && favedElem.classList.contains('wishlisted')) == true; };
                }
                
                found = true;
            }
        }

        //try to find controller - daily view 
        if (!found) {
            let controller = document.querySelector("div.player-wrapper > mplayer.player.playing");
            if (controller) {
                let p = controller;
                titleElem = p.querySelector("span.mptracktitle");
                nextElem = p.querySelector("span.mpcontrols span.next > div");
                prevElem = p.querySelector("span.mpcontrols span.prev > div");
                artistElem = p.querySelector("a.mpartist");
                albumElem = p.querySelector("a.mptralbum");
                favElem = p.querySelector("div.mpbuttons.collect-item a.wishlist-msg > span");
                let favedElem = p.querySelector("div.mpbuttons.collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favElem = null;
                }
                else {
                    favedAction = () => {return (favedElem && favedElem.classList.contains('wishlisted')) == true;};
                }
                if (!titleElem) {
                    titleElem = albumElem;
                }
                imgElem = p.querySelector("div.mpaa > img");
                found = true;
            }
        }

        //try to find controller - fan activity view 
        if (!found) {
            let controller = document.querySelector("#story-list div.collection-item-container.playing");
            if (controller) {
                let p = controller;
                titleElem = p.querySelector("div.story-body span.favoriteTrackLabel > span");
                artistElem = p.querySelector("div.story-body div.collection-item-artist");
                albumElem = p.querySelector("div.story-body div.collection-item-title");
                let favedElem = p.querySelector("div.collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favedElem = null;
                }
                else {
                    favAction = () => {
                        let css = (favedElem && favedElem.classList.contains('wishlisted')) ? "span.wishlisted-msg" : "span.wishlist-msg";
                        favedElem.querySelector(css).click();
                    }
                    favedAction = () => { return (favedElem && favedElem.classList.contains('wishlisted')) == true; };
                    if (!titleElem) {
                        titleElem = albumElem;
                    }
                }
                imgElem = p.querySelector("div.story-body div.tralbum-art-container img");
                found = true;
            }
        }

        //try to find controller - new and notable side view 
        if (!found) {
            let controller = document.querySelector("li.collection-item-container.playing");
            if (controller) {
                let p = controller;
                titleElem = p.querySelector("div.collection-item-gallery-container .collection-item-title");
                artistElem = p.querySelector("div.collection-item-gallery-container div.collection-item-artist");
                let favedElem = p.querySelector("div.collection-item-details-container div.collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favedElem = null;
                }
                else {
                    favAction = () => {
                        let css = (favedElem && favedElem.classList.contains('wishlisted')) ? "span.wishlisted-msg" : "span.wishlist-msg";
                        favedElem.querySelector(css).click();
                    }
                    favedAction = () => { return (favedElem && favedElem.classList.contains('wishlisted')) == true; };
                    if (!titleElem) {
                        titleElem = albumElem;
                    }
                }
                imgElem = p.querySelector("div.collection-item-gallery-container img.collection-item-art");
                found = true;
            }
        }

        //try to find controller - bandcamp weekly view 
        if (!found) {
            let controller = document.querySelector("#bcweekly-inner.playing ~ div.bcweekly-info li.row.bcweekly-track.bcweekly-current > div.track-large");
            if (controller) {
                let p = controller;
                titleElem = p.querySelector("p.track-details > a > span.track-title");
                artistElem = p.querySelector("p.track-artist > a");
                albumElem = p.querySelector("p.track-details > a > span.track-album");
                let favedElem = p.querySelector("div.collect-item-container .collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favedElem = null;
                }
                else {
                    favAction = () => {
                        let css = (favedElem && favedElem.classList.contains('wishlisted')) ? "span.wishlisted-msg" : "span.wishlist-msg";
                        favedElem.querySelector(css).click();
                    }
                    favedAction = () => {return (favedElem && favedElem.classList.contains('wishlisted')) == true;};
                    if (!titleElem) {
                        titleElem = albumElem;
                    }
                }
                imgElem = p.querySelector("div.col-8-15 > a > img");
                found = true;
            }
        }
        
        //try to find controller - discover view 
        if (!found) {
            let controller = document.querySelector("#discover td.play_cell > a > div.playbutton.playing");
            if (controller) {
                let p = controller.parentElement.parentElement.parentElement;
                titleElem = p.querySelector("td.track_cell span.title");
                p = p.parentElement.parentElement.parentElement.parentElement.parentElement;
                artistElem = p.querySelector("div.detail-body > .detail-artist > a");
                albumElem = p.querySelector("div.detail-body .detail-album > a");
                let favedElem = p.querySelector("div.collect-item-container .collect-item");
                if (favedElem.classList.contains("purchased")) {
                    favedElem = null;
                }
                else {
                    favAction = () => {
                        let css = (favedElem && favedElem.classList.contains('wishlisted')) ? "span.wishlisted-msg" : "span.wishlist-msg";
                        favedElem.querySelector(css).click();
                    }
                    favedAction = () => {return (favedElem && favedElem.classList.contains('wishlisted')) == true;};
                    if (!titleElem) {
                        titleElem = albumElem;
                    }
                }
                imgElem = p.querySelector("a > img");
                found = true;
            }
        }

        //try to find controller - `also like` view 
        if (!found) {
            let controller = document.querySelector("div.recommendations-container div.album-art-container.playing");
            if (controller) {
                let prevController = document.querySelector(".beardie_marker")
                prevController && prevController.classList.remove("beardie_marker");
                controller.classList.add('beardie_marker');
            }
            else {
                if (BSStrategy.lastPlayed && !BSStrategy.lastPlayed.paused) {
                    controller = document.querySelector("div.recommendations-container div.album-art-container.beardie_marker");
                }
            }
            if (controller) {
                let p = controller;
                imgElem = p.querySelector("img.album-art");
                p = p.parentElement;
                titleElem = p.querySelector(".release-title");
                artistElem = p.querySelector(".by-artist");
                found = true;
            }
        }

        if (found) {
            BSStrategy.lastControllerData = {
                next: () => { nextElem && nextElem.click(); },
                prev: () => { prevElem && prevElem.click(); },
                fav: favAction ? favAction : (favElem ? () => { favElem && favElem.click(); } : null),
                info: () => {
                    let result = {};
                    let album = albumElem && albumElem.innerText;
                    if (album) {
                        result.album = album;
                    }
                    if (titleElem) {
                        result.track = titleElem.innerText || album;
                    }
                    if (artistElem) {
                        result.artist = artistElem.innerText;
                    }
                    if (imgElem) {
                        result.image = imgElem.src;
                    }
                    if (favedAction) {
                        result.favorited = favedAction();
                    }
                    return result;
                }
            };
        }
        else {
            BSStrategy.lastControllerData = null;
        }
    }

}
