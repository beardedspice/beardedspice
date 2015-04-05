//
//  DigitallyImportedStrategy.m
//  BeardedSpice
//
//  Created by Dennis Lysenko on 4/4/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "DigitallyImportedStrategy.h"

@implementation DigitallyImportedStrategy

- (id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*di.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('div.controls a')[0].click()})()";
}

-(NSString *) previous
{
    // cannot skip tracks in DI
    return @"(function(){})()";
}

-(NSString *) next
{
    // cannot skip tracks in DI
    return @"(function(){})()";
}

-(NSString *) pause
{
    return @"(function(){var pause = document.querySelectorAll('div.controls a')[0];if(pause.classList.contains('icon-pause')){pause.click();}})()";
}

-(NSString *) displayName
{
    return @"Digitally Imported";
}

@end
