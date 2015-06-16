//
//  TuneInStrategy.m
//  BeardedSpice
//
//  Created by Michael Alden on 4/17/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TuneInStrategy.h"

@implementation TuneInStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*tunein.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"document.querySelector('.playbutton-cont').click();";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"";
}

-(NSString *) pause
{
    return @"if($('#tuner').attr('class') == 'playing'){document.querySelector('.playbutton-cont').click();}";
}

-(NSString *) favorite
{
    return @"$('.icon.follow').click()";
}

-(NSString *) displayName
{
    return @"TuneIn";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    NSDictionary *metadata = [tab executeJavascript:@"TuneIn.payload.NowPlayingInfo"];
    NSString *albumart_url = [tab executeJavascript:@"$('.artwork.col._navigateNowPlaying').children('.image').children('.logo.loaded').attr('src');"];
    Track *track = [[Track alloc] init];
    track.track = [metadata valueForKeyPath:@"broadcast.DisplaySubtitle"];
    track.album = [metadata valueForKey:@"description"];
    track.artist = [metadata valueForKeyPath:@"broadcast.Location"];
    track.image = [self imageByUrlString:albumart_url];
    return track;
}

@end
