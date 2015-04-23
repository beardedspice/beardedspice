//
//  KollektFmStrategy.m
//  BeardedSpice
//
//  Created by Wiert Omta on 23/1/2015.
//  Copyright (c) 2015 Wiert Omta. All rights reserved.
//

#import "KollektFmStrategy.h"

@implementation KollektFmStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*kollekt.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"($( \"i[ng-click='playPause()']\" ).click())";
}

-(NSString *) previous
{
    return @"($( \"i[ng-click='previous()']\" ).click())";
}

-(NSString *) next
{
    return @"($( \"i[ng-click='next()']\" ).click())";
}

-(NSString *) pause
{
    return @"($( \".fa-pause\" ).click())";
}

-(NSString *) favorite
{
    return @"($( \"i[ng-click='favoriteTrack(activeTrack())']\" ).click())";
}

-(NSString *) displayName
{
    return @"Kollekt.FM";
}

@end
