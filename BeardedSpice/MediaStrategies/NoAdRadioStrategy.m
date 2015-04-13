//
//  NoAdRadioStrategy.m
//  BeardedSpice
//


#import "NoAdRadioStrategy.h"

@implementation NoAdRadioStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*noadradio.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return document.getElementsByName('content')[0].contentWindow.document.getElementById('player_pp_icon').click()})()";
}

// Site doesn't support Previous!
//-(NSString *) previous
//{
//    return @"(function(){return document.querySelectorAll('.skipControl__previous')[0].click()})()";
//}

-(NSString *) next
{
    return @"(function(){return document.getElementsByName('content')[0].contentWindow.document.getElementById('player_ff_icon').click()})()";
}

-(NSString *) pause
{
    return @"(function(){var player = document.getElementsByName('content')[0].contentWindow.document.getElementById('player-outer-box');if(!player.classList.contains('paused')){document.getElementsByName('content')[0].contentWindow.document.getElementById('player_pp_icon').click()}})()";
}

-(NSString *) favorite
{
    // NEED TO WAIT AJAX REQUEST TO COMPLETE (they request /song_ratings/player_love_modal)
    // 500 is good because it gives the modal time to load and render and isn't too long in case the user is trying to favorite a song at the last second of the song!
    return @"(function(){document.getElementsByName('content')[0].contentWindow.document.getElementById('player_fav_icon').click();window.setTimeout(function(){document.getElementsByName('content')[0].contentWindow.document.getElementsByName('commit')[0].click();}, 500)})()";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *metadata;
    NSLog(@"Called trackInfo");
    do {
        usleep(100000); //sleep one tenth of a second, to avoid repeatedly executing the JS hundreds of times in the browser while it's loading
        // the number, 7, below in the substr, is because we need to cut the few first letters from the pattern by ARTIST_NAME on ALBUM_NAME
        // this means we need to cut 7 letters (by on ) plus the length of the artist name :)
        metadata = [tab executeJavascript:@"(function(){var innerDoc =document.getElementsByName('content')[0].contentWindow.document; var artist = innerDoc.getElementById('player_current_artist'); var trackInfo = { title: innerDoc.getElementById('current-song').innerText, album: '', artist:''}; if(artist.innerText != ''){trackInfo.album= artist.innerText.substr(7 + artist.getElementsByTagName('a')[0].innerText.length); trackInfo.artist = artist.getElementsByTagName('a')[0].innerText; trackInfo.image = innerDoc.getElementById('player_main_pic_img').src;} return trackInfo})()"];
    } while([[metadata objectForKey:@"title"]  isEqualToString: @"Loading Music…"]);
    Track *track = [[Track alloc] init];
    track.track = [metadata objectForKey:@"title"];
    track.album = [metadata objectForKey:@"album"];
    track.artist = [metadata objectForKey:@"artist"];
    track.image = [self imageByUrlString:[metadata objectForKey:@"image"]];
    
    return track;
}

-(NSString *) displayName
{
    return @"NoAdRadio";
}

@end
