//
//  MediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// Order is important.
// New custom classes should go at the bottom of the list. Libraries and protocols go just below main import

#import "BSMediaStrategy.h"
#import "BSStrategyVersionManager.h"
#import "TabAdapter.h"
#import "BSTrack.h"

#define NBSP_STRING                         @"\u00a0"

NSString *const kBSMediaStrategyKeyVersion       = @"version";
NSString *const kBSMediaStrategyKeyDisplayName   = @"displayName";

// Metadata and categorization/breakdown of complex types
NSString *const kBSMediaStrategyKeyPredicate     = @"predicate";
NSString *const kBSMediaStrategyKeyScript        = @"script";
NSString *const kBSMediaStrategyKeyTabValue      = @"tabValue";
NSString *const kBSMediaStrategyKeyTabValueURL   = @"url";
NSString *const kBSMediaStrategyKeyTabValueTitle = @"title";

// Strategy values custom implemented in each plist
NSString *const kBSMediaStrategyKeyAccepts       = @"accepts";
NSString *const kBSMediaStrategyKeyIsPlaying     = @"isPlaying";
NSString *const kBSMediaStrategyKeyToggle        = @"toggle";
NSString *const kBSMediaStrategyKeyPrevious      = @"previous";
NSString *const kBSMediaStrategyKeyNext          = @"next";
NSString *const kBSMediaStrategyKeyFavorite      = @"favorite";
NSString *const kBSMediaStrategyKeyPause         = @"pause";
NSString *const kBSMediaStrategyKeyTrackInfo     = @"trackInfo";

@interface BSMediaStrategy ()

@property (nonatomic, assign) long strategyVersion;
@property (nonatomic, strong) NSDictionary<NSString *, id> *strategyData;
@property (nonatomic, strong) NSString *fileName;

+ (NSDictionary *)loadFile:(NSString *)strategyName;

@end

@implementation BSMediaStrategy

+ (BSMediaStrategy *)cacheForStrategyName:(NSString *)strategyName
{
    static dispatch_once_t setupCache;
    static dispatch_queue_t cacheSerialQueue;
    static NSCache *strategyCache = nil;

    dispatch_once(&setupCache, ^{
        cacheSerialQueue = dispatch_queue_create("com.beardedspice.strategies.cache", DISPATCH_QUEUE_SERIAL);
        strategyCache = [NSCache new];
        [strategyCache setName:@"MediaStrategyCache"];
    });

    __block BSMediaStrategy *strategy = nil;
    dispatch_sync(cacheSerialQueue, ^{
        strategy = [strategyCache objectForKey:strategyName];
        if (!strategy)
        {
            strategy = [[BSMediaStrategy alloc] initWithStrategyName:strategyName];
            [strategyCache setObject:strategy forKey:strategyName];
        }

        long currentVersion = [BSStrategyVersionManager.sharedVersionManager versionForMediaStrategy:strategy.fileName];
        BOOL isOlder = strategy.strategyVersion < currentVersion;
        if (isOlder)
        {
            [strategy reloadData];
        }
    });
    return strategy;
}

- (instancetype)initWithStrategyName:(NSString *)strategyName
{
    self = [super init];
    if (self)
    {
        _fileName = strategyName;

        // if we reload on every init, the point of a cache will be lost.
        _strategyData = [BSMediaStrategy loadFile:_fileName];
        if (!_strategyData)
            NSLog(@"Failed to load strategy with name: %@", strategyName);

        _strategyVersion = [(_strategyData ? _strategyData[kBSMediaStrategyKeyVersion] : @0) longValue];
    }
    return self;
}

- (void)reloadData
{
    if (_fileName && _fileName.length)
    {
        self.strategyData = [BSMediaStrategy loadFile:_fileName];
        self.strategyVersion = [(_strategyData ? _strategyData[kBSMediaStrategyKeyVersion] : 0) longValue];
    }
}

#pragma mark - Core Functionality

- (NSString *)displayName
{
    if (!_strategyData)
        return _fileName;

    return self.strategyData[kBSMediaStrategyKeyDisplayName] ?: @"";
}

- (BOOL)accepts:(TabAdapter *)tab
{
    if (!_strategyData || !tab)
        return NO;

    NSDictionary<NSString *, NSString *> *acceptDict = self.strategyData[kBSMediaStrategyKeyAccepts];
    if (!acceptDict.count)
        return NO;

    NSString *predicateString = acceptDict[kBSMediaStrategyKeyPredicate];
    NSString *scriptString = acceptDict[kBSMediaStrategyKeyScript];

    BOOL hasPredicate = (predicateString && [predicateString length]);
    BOOL hasScriptString = (scriptString && [scriptString length]);

    if (hasPredicate)
    {
        id object = nil;
        // tabValue is the value to take from the provided tab. URL or Title for existing types
        NSString *tabValue = acceptDict[kBSMediaStrategyKeyTabValue];
        if ([tabValue isEqualToString:kBSMediaStrategyKeyTabValueURL])
            object = [tab URL];
        else if ([tabValue isEqualToString:kBSMediaStrategyKeyTabValueTitle])
            object = [tab title];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        return object ? [predicate evaluateWithObject:object] : NO;
    }
    else if (hasScriptString)
        return [[tab executeJavascript:scriptString] boolValue];

    return NO;
}

- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName
{
    NSString *scriptString = self.strategyData[methodName];
    return scriptString && scriptString.length;
}

- (BOOL)isPlaying:(TabAdapter *)tab
{
    if (!_strategyData || !tab)
        return NO;

    NSString *scriptString = self.strategyData[kBSMediaStrategyKeyIsPlaying];
    if (!scriptString || !scriptString.length)
        return NO;

    NSNumber *isPlaying = [tab executeJavascript:scriptString];
    return [isPlaying boolValue] ?: NO;
}

- (NSString *)toggle
{
    if (!_strategyData)
        return @"";

    return self.strategyData[kBSMediaStrategyKeyToggle] ?: @"";
}

- (NSString *)previous
{
    if (!_strategyData)
        return @"";

    return self.strategyData[kBSMediaStrategyKeyPrevious] ?: @"";
}

- (NSString *)next
{
    if (!_strategyData)
        return @"";

    return self.strategyData[kBSMediaStrategyKeyNext] ?: @"";
}

- (NSString *)pause
{
    if (!_strategyData)
        return @"";

    return self.strategyData[kBSMediaStrategyKeyPause] ?: @"";
}

- (NSString *)favorite
{
    if (!_strategyData)
        return @"";

    return self.strategyData[kBSMediaStrategyKeyDisplayName] ?: @"";
}

- (BSTrack *)trackInfo:(TabAdapter *)tab
{
    if (!_strategyData)
        return nil;

    NSString *trackString = self.strategyData[kBSMediaStrategyKeyTrackInfo];
    if (!trackString || !trackString.length)
        return nil;

    NSDictionary *trackData = [tab executeJavascript:trackString];
    return (trackData && trackData.count) ? [[BSTrack alloc] initWithInfo:trackData] : nil;
}

#pragma mark - Helper Functions

+ (NSDictionary *)loadFile:(NSString *)strategyName
{
    if (!strategyName || !strategyName.length)
        return nil;

    NSURL *dataString = [NSURL fileFromURL:strategyName];
    if (!dataString)
        dataString = [[NSBundle mainBundle] URLForResource:strategyName withExtension:@"plist"];
    if (!dataString)
        return nil;

    NSDictionary<NSString *, id> *data = [[NSDictionary alloc] initWithContentsOfURL:dataString];
    if (!data || !data.count)
        return nil;

    return data;
}

@end
