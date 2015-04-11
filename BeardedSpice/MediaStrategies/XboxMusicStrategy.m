//
//  XboxMusicStrategy.m
//  BeardedSpice
//
//  Created by Jonathan Ruiz on 5/20/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "XboxMusicStrategy.h"

@implementation XboxMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.xbox.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){window.app.mainViewModel.playerVM.togglePause()})();";
}

-(NSString *) previous
{
    return @"(function(){window.app.mainViewModel.playerVM.previous()})();";
}

-(NSString *) next
{
    return @"(function(){window.app.mainViewModel.playerVM.next()})();";
}

-(NSString *) pause
{
    return @"(function(){var app=window.app.mainViewModel.playerVM;if(app.isPlayingOrLoading()){app.togglePause()}})();";
}

-(NSString *) displayName
{
    return @"Xbox Music";
}

@end
