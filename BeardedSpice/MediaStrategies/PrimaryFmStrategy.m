//
//  PrimaryFmStrategy.m
//  BeardedSpice
//
//  Created by Kyle Conarro on 3/4/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "PrimaryFmStrategy.h"

@implementation PrimaryFmStrategy


-(id) init
{
  self = [super init];
  if (self) {
    predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*primary.fm*'"];
  }
  return self;
}

-(NSString *) displayName
{
  return @"Primary FM";
}

@end

