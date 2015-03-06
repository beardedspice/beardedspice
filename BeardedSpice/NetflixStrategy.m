//
//  NetflixStrategy.m
//  BeardedSpice
//
//  Created by Martijn Engler on 3/6/15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NetflixStrategy.h"

@implementation NetflixStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*netflix.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    /**
     original script (minifying made it easier to paste into a single string:
     function pauseNetflix(v, playPauseButton)
     {
     v.pause();
     playPauseButton.className = playPauseButton.className.replace(/(?:^|\s)icon-player-pause(?!\S)/g ,' icon-player-play ');
     playPauseButton.className = playPauseButton.className.replace(/(?:^|\s)pause(?!\S)/g ,' play ');
     }

     function playNetflix(v, playPauseButton)
     {
     v.play();
     playPauseButton.className = playPauseButton.className.replace(/(?:^|\s)icon-player-play(?!\S)/g ,' icon-player-pause ');
     playPauseButton.className = playPauseButton.className.replace(/(?:^|\s)play(?!\S)/g ,' pause ');
     }

     var ppb = document.getElementsByClassName('player-play-pause')[0];
     var v = document.getElementsByTagName('video')[0];
     v.paused ? playNetflix(v, ppb) : pauseNetflix(v, ppb);
     **/
    return @"function pauseNetflix(a,e){a.pause(),e.className=e.className.replace(/(?:^|\\s)icon-player-pause(?!\S)/g,' icon-player-play '),e.className=e.className.replace(/(?:^|\\s)pause(?!\\S)/g,' play ')}function playNetflix(a,e){a.play(),e.className=e.className.replace(/(?:^|\\s)icon-player-play(?!\\S)/g,' icon-player-pause '),e.className=e.className.replace(/(?:^|\\s)play(?!\\S)/g,' pause ')}var ppb=document.getElementsByClassName('player-play-pause')[0],v=document.getElementsByTagName('video')[0];v.paused?playNetflix(v,ppb):pauseNetflix(v,ppb);";
}

-(NSString *) previous
{
    // can not be implemented for Netflix.com
    return @"";
}

-(NSString *) next
{
    // can not be implemented for Netflix.com
    return @"";
}

-(NSString *) displayName
{
    return @"Netflix.com";
}

@end
