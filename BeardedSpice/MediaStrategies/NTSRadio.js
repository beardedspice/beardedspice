//
//  NTS Radio
//  BeardedSpice
//
//
//  Created by Grant Levene on 07/08/20
//  Copyright (c) 2015-2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
    version: 1,
    displayName: "NTS Radio",
    accepts: {
        method: "predicateOnTab",
        format: "%K LIKE[c] '*www.nts.live*'",
        args: ["URL"]
    },
    pause: function() {
        const mixcloudContent = document.getElementById("mixcloud-content");

        if (mixcloudContent) {
            const widget = window.Mixcloud.PlayerWidget(mixcloudContent);
            widget.ready.then(function() {
                widget.pause();
            });
        }

        document.dispatchEvent(new CustomEvent("ntsStopRadio"));
    },
    toggle: function() {
        const mixcloudContent = document.getElementById("mixcloud-content");

        if (mixcloudContent) {
            const widget = window.Mixcloud.PlayerWidget(mixcloudContent);
            widget.ready.then(function() {
                widget.togglePlay();
            });

            return;
        }

        const radioPlayer = document.querySelector("audio");

        if (radioPlayer) {
            if (radioPlayer.paused) {
                radioPlayer.play();
            } else {
                radioPlayer.pause();
            }
        }
    }
};
