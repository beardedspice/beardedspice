//
//  LastFmStrategy.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/19/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "LastFmStrategy.h"

@implementation LastFmStrategy

-(BOOL) accepts:(id <Tab>)tab
{
    return [[tab URL] isCaseInsensitiveLike:@"*last.fm/listen*"];
}

-(NSString *) toggle
{
    return @"(function(){var e=document.querySelectorAll('#radioControlPlay')[0];var t=document.querySelectorAll('#radioControlPause')[0];var m=document.querySelectorAll('#webRadio')[0];if(m.classList.contains('paused')){e.click()}else{t.click()}})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('#radioControlSkip')[0].click()})();";
}

-(NSString *) pause
{
    return @"(function(){var t=document.querySelectorAll('#radioControlPause')[0].click()})()";
}

-(NSString *) displayName
{
    return @"LastFM";
}

@end
