//
//  SaavnStrategy.m
//  BeardedSpice
//
//  Created by Yash Aggarwal on 1/6/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SaavnStrategy.h"

@implementation SaavnStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*saavn.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var e=document.getElementById('play');var t=document.getElementById('pause');if(t.className.indexOf('hide')===-1){t.click();}else{e.click();}})()";
}

-(NSString *) previous
{
    return @"document.getElementById('rew').click();";
}

-(NSString *) next
{
    return @"document.getElementById('fwd').click();";
}

-(NSString *) pause
{
    return @"document.getElementById('pause').click();";
}

-(NSString *) displayName
{
    return @"Saavn";
}

@end
