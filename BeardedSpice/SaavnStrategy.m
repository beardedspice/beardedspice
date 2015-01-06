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
    return @"(function(){var e=document.querySelectorAll('#play')[0];var t=document.querySelectorAll('#pause')[0];if(t.className.indexOf('hide')===-1){t.click()}else{e.click()}})()";
}

-(NSString *) previous
{
    return @"(function(){var e=document.querySelectorAll('#rew')[0];e.click()})()";
}

-(NSString *) next
{
    return @"(function(){var e=document.querySelectorAll('#fwd')[0];e.click()})()";
}

-(NSString *) pause
{
    return @"(function(){var e=document.querySelectorAll('#pause')[0];e.click()})()";
}

-(NSString *) displayName
{
    return @"Saavn";
}

@end
