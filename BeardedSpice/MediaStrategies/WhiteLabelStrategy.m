//
//  WhiteLabelStrategy.m
//  BeardedSpice
//
//  Created by Kyle Conarro on 3/4/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "WhiteLabelStrategy.h"

@implementation WhiteLabelStrategy


-(id) init
{
  self = [super init];
  if (self) {
    predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*white-label.fm*'"];
  }
  return self;
}

-(NSString *) displayName
{
  return @"White Label FM";
}

@end

