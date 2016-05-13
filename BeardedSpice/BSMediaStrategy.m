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
NSString *const kBSMediaStrategyKeyAccept        = @"accepts";
NSString *const kBSMediaStrategyKeyIsPlaying     = @"isPlaying";
NSString *const kBSMediaStrategyKeyToggle        = @"toggle";
NSString *const kBSMediaStrategyKeyPrevious      = @"previous";
NSString *const kBSMediaStrategyKeyNext          = @"next";
NSString *const kBSMediaStrategyKeyFavorite      = @"favorite";
NSString *const kBSMediaStrategyKeyPause         = @"pause";
NSString *const kBSMediaStrategyKeyTrackInfo     = @"trackInfo";

// Metadata and categorization/breakdown of complex types
NSString *const kBSMediaStrategyAcceptMethod         = @"method";
NSString *const kBSMediaStrategyAcceptPredicateOnTab = @"predicateOnTab";
NSString *const kBSMediaStrategyAcceptScript         = @"script";
NSString *const kBSMediaStrategyAcceptKeyFormat      = @"format";
NSString *const kBSMediaStrategyAcceptKeyArgs        = @"args";
NSString *const kBSMediaStrategyAcceptValueURL       = @"url";
NSString *const kBSMediaStrategyAcceptValueTitle     = @"title";

@interface BSMediaStrategy ()

@property (nonatomic, assign) long strategyVersion;
@property (nonatomic, strong) NSString *fileName;

// Cached scripts/components
@property (nonatomic, strong) NSDictionary *acceptParams;
@property (nonatomic, strong) NSDictionary *scripts;

+ (JSValue *)loadFile:(NSString *)strategyName;
- (void)_setupData:(JSValue *_Nonnull)data;
- (NSDictionary *_Nonnull)_setupAccept:(JSValue *_Nonnull)data;

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
        JSValue *strategyData = [BSMediaStrategy loadFile:_fileName];
        if (strategyData)
            [self _setupData:strategyData];
        else
            NSLog(@"Failed to load strategy with name: %@", strategyName);
    }
    return self;
}

#pragma mark - Helper Functions

- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName
{
    NSString *value = _scripts[methodName];
    return (value && value.length);
}

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

- (void)reloadData
{
    JSValue *strategyData = [BSMediaStrategy loadFile:_fileName];
    [self _setupData:strategyData];
}

// quick helper function for safely extracting script strings from jsvalue
static inline NSString *js_string_for_key(NSString *key, JSValue *node)
{
    JSValue *value = node[key];
    if ([value isNull] || [value isUndefined])
        return @"";

    return [[value toString] makeFunctionExecute];
}

- (void)_setupData:(JSValue *_Nonnull)data
{
    if (!_fileName || !_fileName.length)
        return;

    self.acceptParams = [self _setupAccept:data];

    JSValue *version = data[kBSMediaStrategyKeyVersion];
    self.strategyVersion = ([version isNull] || [version isUndefined]) ? 0 : [version toUInt32];
    self.scripts = @{
        kBSMediaStrategyKeyDisplayName: js_string_for_key(kBSMediaStrategyKeyDisplayName, data),
        kBSMediaStrategyKeyIsPlaying:   js_string_for_key(kBSMediaStrategyKeyIsPlaying, data),
        kBSMediaStrategyKeyToggle:      js_string_for_key(kBSMediaStrategyKeyToggle, data),
        kBSMediaStrategyKeyNext:        js_string_for_key(kBSMediaStrategyKeyNext, data),
        kBSMediaStrategyKeyPrevious:    js_string_for_key(kBSMediaStrategyKeyPrevious, data),
        kBSMediaStrategyKeyPause:       js_string_for_key(kBSMediaStrategyKeyPause, data),
        kBSMediaStrategyKeyFavorite:    js_string_for_key(kBSMediaStrategyKeyFavorite, data),
        kBSMediaStrategyKeyTrackInfo:   js_string_for_key(kBSMediaStrategyKeyTrackInfo, data)
    };
}

- (NSDictionary *_Nonnull)_setupAccept:(JSValue *_Nonnull)data
{
    JSValue *acceptJS = data[kBSMediaStrategyKeyAccept];
    if (!acceptJS || [acceptJS isNull] || [acceptJS isUndefined])
        return @{};

    NSDictionary *dict = [acceptJS toDictionary];
    if (!dict)
        return @{};

    NSString *method = dict[kBSMediaStrategyAcceptMethod];
    if (!method)
        return @{};

    if ([method isEqualToString:kBSMediaStrategyAcceptPredicateOnTab])
    {
        NSString *typeFormat = dict[kBSMediaStrategyAcceptKeyFormat];
        NSArray *typeArgs = dict[kBSMediaStrategyAcceptKeyArgs];
        return @{
            kBSMediaStrategyAcceptMethod: method,
            kBSMediaStrategyAcceptKeyArgs: typeArgs ?: @[],
            kBSMediaStrategyKeyAccept: [NSPredicate predicateWithFormat:typeFormat argumentArray:typeArgs]
        };
    }
    else if ([method isEqualToString:kBSMediaStrategyAcceptScript])
    {
        JSValue *value = acceptJS[kBSMediaStrategyAcceptScript];
        NSString *acceptScript = [value toString];
        return @{
            kBSMediaStrategyAcceptMethod: method,
            kBSMediaStrategyKeyAccept: (acceptScript ?: @"")
        };
    }

    return @{};
}

#pragma mark - Core Functionality

- (NSString * _Nonnull)displayName
{
    if (!_scripts || !_scripts[kBSMediaStrategyKeyDisplayName])
        return _fileName;

    return _scripts[kBSMediaStrategyKeyDisplayName] ?: @""; // incase uninitialized
}

- (BOOL)accepts:(TabAdapter * _Nonnull)tab
{
    if (!tab || !_acceptParams)
        return NO;

    NSString *method = _acceptParams[kBSMediaStrategyAcceptMethod];
    if (!method)
        return NO;

    if ([method isEqualToString:kBSMediaStrategyAcceptPredicateOnTab])
    {
        /*id object = nil;
        NSArray *typeArgs = (NSArray *)_acceptParams[kBSMediaStrategyAcceptKeyArgs];
        if ([typeArgs containsObject:kBSMediaStrategyAcceptValueURL])
            object = [tab URL];
        else if ([typeArgs containsObject:kBSMediaStrategyAcceptValueTitle])
            object = [tab title];
        */
        NSPredicate *acceptValue = (NSPredicate *)_acceptParams[kBSMediaStrategyKeyAccept];
        return acceptValue ? [acceptValue evaluateWithObject:tab] : NO;
    }
    else if ([method isEqualToString:kBSMediaStrategyAcceptScript])
    {
        NSString *acceptValue = (NSString *)_acceptParams[kBSMediaStrategyKeyAccept];
        return [[tab executeJavascript:acceptValue] boolValue];
    }

    return NO;
}

- (BOOL)isPlaying:(TabAdapter * _Nonnull)tab
{
    if (!_scripts || !tab)
        return NO;

    NSString *script = _scripts[kBSMediaStrategyKeyIsPlaying];
    if (!script || !script.length)
        return NO;

    NSNumber *isPlaying = [tab executeJavascript:script];
    return [isPlaying boolValue] ?: NO;
}

- (NSString * _Nonnull)toggle
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyToggle];
}

- (NSString * _Nonnull)previous
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyPrevious];
}

- (NSString * _Nonnull)next
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyNext];
}

- (NSString * _Nonnull)pause
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyPause];
}

- (NSString * _Nonnull)favorite
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyFavorite];
}

- (BSTrack * _Nullable)trackInfo:(TabAdapter * _Nonnull)tab
{
    if (!_scripts)
        return nil;

    NSString *script = _scripts[kBSMediaStrategyKeyTrackInfo];
    if (!script || !script.length)
        return nil;

    NSDictionary *trackData = [tab executeJavascript:script];
    return (trackData && trackData.count) ? [[BSTrack alloc] initWithInfo:trackData] : nil;
}

@end
