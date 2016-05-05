//
//  MediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// Order is important.
// New custom classes should go at the bottom of the list. Libraries and protocols go just below main import


#import <JavaScriptCore/JavaScriptCore.h>

#import "BSMediaStrategy.h"
#import "BSStrategyVersionManager.h"
#import "TabAdapter.h"
#import "BSTrack.h"

#define NBSP_STRING                         @"\u00a0"

NSString *const kBSMediaStrategyKeyVersion       = @"version";
NSString *const kBSMediaStrategyKeyDisplayName   = @"displayName";


// Strategy values custom implemented in each plist
NSString *const kBSMediaStrategyKeyAcceptsMethod = @"acceptMethod";
NSString *const kBSMediaStrategyKeyAcceptsParams = @"acceptParams";
NSString *const kBSMediaStrategyKeyIsPlaying     = @"isPlaying";
NSString *const kBSMediaStrategyKeyToggle        = @"toggle";
NSString *const kBSMediaStrategyKeyPrevious      = @"previous";
NSString *const kBSMediaStrategyKeyNext          = @"next";
NSString *const kBSMediaStrategyKeyFavorite      = @"favorite";
NSString *const kBSMediaStrategyKeyPause         = @"pause";
NSString *const kBSMediaStrategyKeyTrackInfo     = @"trackInfo";

// Metadata and categorization/breakdown of complex types
NSString *const kBSMediaStrategyAcceptPredicateOnTab = @"predicateOnTab";
NSString *const kBSMediaStrategyAcceptScript         = @"script";
NSString *const kBSMediaStrategyAcceptKeyFormat      = @"format";
NSString *const kBSMediaStrategyAcceptKeyArgs        = @"args";
NSString *const kBSMediaStrategyAcceptValueURL       = @"url";
NSString *const kBSMediaStrategyAcceptValueTitle     = @"title";


@interface BSMediaStrategy ()

@property (nonatomic, assign) long strategyVersion;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) JSValue *strategyData;

+ (JSValue *)loadFile:(NSString *)strategyName;

@end

@implementation BSMediaStrategy

+ (BSMediaStrategy * _Nullable)cacheForStrategyName:(NSString * _Nonnull)strategyName
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

- (instancetype _Nonnull)initWithStrategyName:(NSString * _Nonnull)strategyName
{
    self = [super init];
    if (self)
    {
        _fileName = strategyName;

        // if we reload on every init, the point of a cache will be lost.
        _strategyData = [BSMediaStrategy loadFile:_fileName];
        if (!_strategyData)
            NSLog(@"Failed to load strategy with name: %@", strategyName);

        JSValue *version = _strategyData[kBSMediaStrategyKeyVersion];
        _strategyVersion = ([version isNull] || [version isUndefined]) ? 0 : [version toUInt32];
    }
    return self;
}

- (void)reloadData
{
    if (_fileName && _fileName.length)
    {
        self.strategyData = [BSMediaStrategy loadFile:_fileName];

        JSValue *version = _strategyData[kBSMediaStrategyKeyVersion];
        self.strategyVersion = ([version isNull] || [version isUndefined]) ? 0 : [version toUInt32];
    }
}

#pragma mark - Core Functionality

- (NSString * _Nonnull)displayName
{
    if (!_strategyData)
        return _fileName;

    NSString *displayName = [self.strategyData[kBSMediaStrategyKeyDisplayName] toString];
    return displayName ?: @""; // so we dont double the calculations
}

- (BOOL)accepts:(TabAdapter * _Nonnull)tab
{
    if (!_strategyData || !tab)
        return NO;

    NSDictionary *acceptParams = [self.strategyData[kBSMediaStrategyKeyAcceptsParams] toDictionary];
    if (!acceptParams.count)
        return NO;

    NSString *acceptType = [self.strategyData[kBSMediaStrategyKeyAcceptsMethod] toString];
    if ([acceptType isEqualToString:kBSMediaStrategyAcceptPredicateOnTab])
    {
        NSDictionary *acceptParams = [self.strategyData[kBSMediaStrategyKeyAcceptsParams] toDictionary];
        if (!acceptParams.count)
            return NO;

        NSString *typeFormat = acceptParams[kBSMediaStrategyAcceptKeyFormat];
        NSString *typeArgs = acceptParams[kBSMediaStrategyAcceptKeyArgs];

        id object = nil;
        if ([typeArgs isEqualToString:kBSMediaStrategyAcceptValueURL])
            object = [tab URL];
        else if ([typeArgs isEqualToString:kBSMediaStrategyAcceptValueTitle])
            object = [tab title];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:typeFormat];
        return object ? [predicate evaluateWithObject:object] : NO;
    }
    else if ([acceptType isEqualToString:kBSMediaStrategyAcceptScript])
    {
        JSValue *acceptParams = _strategyData[kBSMediaStrategyKeyAcceptsParams];
        JSValue *acceptScript = acceptParams[kBSMediaStrategyAcceptScript];
        NSString *scriptString = [acceptScript toString];
        return [[tab executeJavascript:[scriptString makeFunctionExecute]] boolValue];
    }

    return NO;
}

- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName
{
    JSValue *scriptString = self.strategyData[methodName];
    return (![scriptString isNull] && ![scriptString isUndefined]);
}

- (BOOL)isPlaying:(TabAdapter * _Nonnull)tab
{
    if (!_strategyData || !tab)
        return NO;

    JSValue *value = self.strategyData[kBSMediaStrategyKeyIsPlaying];
    NSString *scriptString = ([value isNull] || [value isUndefined]) ? @"" : [value toString];
    if (!scriptString || !scriptString.length)
        return NO;

    NSNumber *isPlaying = [tab executeJavascript:[scriptString makeFunctionExecute]];
    return [isPlaying boolValue] ?: NO;
}

- (NSString * _Nonnull)toggle
{
    if (!_strategyData)
        return @"";

    JSValue *value = self.strategyData[kBSMediaStrategyKeyToggle];
    return ([value isNull] || [value isUndefined]) ? @"" : [[value toString] makeFunctionExecute];
}

- (NSString * _Nonnull)previous
{
    if (!_strategyData)
        return @"";

    JSValue *value = self.strategyData[kBSMediaStrategyKeyPrevious];
    return ([value isNull] || [value isUndefined]) ? @"" : [[value toString] makeFunctionExecute];
}

- (NSString * _Nonnull)next
{
    if (!_strategyData)
        return @"";

    JSValue *value = self.strategyData[kBSMediaStrategyKeyNext];
    return ([value isNull] || [value isUndefined]) ? @"" : [[value toString] makeFunctionExecute];
}

- (NSString * _Nonnull)pause
{
    if (!_strategyData)
        return @"";

    JSValue *value = self.strategyData[kBSMediaStrategyKeyPause];
    return ([value isNull] || [value isUndefined]) ? @"" : [[value toString] makeFunctionExecute];
}

- (NSString * _Nonnull)favorite
{
    if (!_strategyData)
        return @"";

    JSValue *value = self.strategyData[kBSMediaStrategyKeyDisplayName];
    return ([value isNull] || [value isUndefined]) ? @"" : [[value toString] makeFunctionExecute];
}

- (BSTrack * _Nullable)trackInfo:(TabAdapter * _Nonnull)tab
{
    if (!_strategyData)
        return nil;

    NSString *trackString = [self.strategyData[kBSMediaStrategyKeyTrackInfo] toString];
    if (!trackString || !trackString.length)
        return nil;

    NSDictionary *trackData = [tab executeJavascript:[trackString makeFunctionExecute]];
    return (trackData && trackData.count) ? [[BSTrack alloc] initWithInfo:trackData] : nil;
}

#pragma mark - Helper Functions

+ (JSValue * _Nullable)loadFile:(NSString * _Nonnull)strategyName
{
    if (!strategyName || !strategyName.length)
        return nil;

    NSString *dataPath = [[NSBundle mainBundle] pathForResource:strategyName ofType:@"js"];
    if (!dataPath)
        return nil;

    NSError *error = nil;
    NSString *data = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
    if (!data || !data.length)
        return nil;

    return [[JSContext new] evaluateScript:data];
}

@end
