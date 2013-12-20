//
//  PandoraStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "PandoraStrategy.h"

@implementation PandoraStrategy

-(BOOL) accepts:(id <Tab>)tab
{
    return [[tab URL] isCaseInsensitiveLike:@"*pandora.com*"];
}

-(NSString *) toggle
{
    return @"(function(){var e=document.querySelectorAll('.playButton')[0];var t=document.querySelectorAll('.pauseButton')[0];if(t.style.display==='block'){t.click()}else{e.click()}})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('.skipButton')[0].click()})();";
}

-(NSString *) pause
{
    return @"(function(){var t=document.querySelectorAll('.pauseButton')[0];e.click()})()";    
}

@end
