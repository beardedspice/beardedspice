//
//  PandoraStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "PandoraStrategy.h"

@implementation PandoraStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*pandora.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var e=document.querySelector('.playButton');var t=document.querySelector('.pauseButton');if(t.style.display==='block'){t.click()}else{e.click()}})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelector('.skipButton').click()})();";
}

-(NSString *) pause
{
    return @"(function(){var t=document.querySelector('.pauseButton').click()})()";
}

-(NSString *) displayName
{
    return @"Pandora";
}

@end
