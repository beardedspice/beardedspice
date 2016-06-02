//
//  BSMediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "BSMediaStrategy.h"
#import "TabAdapter.h"
#import "BSTrack.h"
#import "NSString+Utils.h"

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

// Metadata
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@property (nonatomic, assign) long strategyVersion;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *strategyURL;

// Cached scripts/components
@property (nonatomic, strong) NSDictionary *acceptParams;
@property (nonatomic, strong) NSDictionary *scripts;

// Internal setup functions
- (JSValue * _Nullable)_loadFile;
- (BOOL)_setupData:(JSValue *_Nonnull)data;
- (NSDictionary *_Nonnull)_setupAccept:(JSValue *_Nonnull)data;

@end

@implementation BSMediaStrategy

- (instancetype _Nonnull)initWithStrategyURL:(NSURL * _Nonnull)strategyURL
{
    self = [super init];
    if (self)
    {
        _loaded = NO;
        _strategyURL = strategyURL;
        _fileName = [strategyURL lastPathComponent];

        // if we reload on every init, the point of a cache will be lost.
        JSValue *strategyData = [self _loadFile];
        if (strategyData)
            _loaded = [self _setupData:strategyData];
        else
            NSLog(@"Failed to load strategy with URL: %@", strategyURL);
    }
    return self;
}

#pragma mark - Helper Functions

- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName
{
    NSString *value = _scripts[methodName];
    return (value && value.length);
}

- (JSValue * _Nullable)_loadFile
{
    if (!_strategyURL)
        return nil;

    NSError *error = nil;
    NSString *data = [[NSString alloc] initWithContentsOfURL:_strategyURL encoding:NSUTF8StringEncoding error:&error];
    if (!data || !data.length)
        return nil;

    __weak typeof(self) wself = self;
    JSContext *context = [JSContext new];

    // FIXME make sure this is run synchronously with evaluateScript: so we don't have race conditions
    context.exceptionHandler = ^(JSContext __attribute__((unused)) *context, JSValue *exception) {
        __strong typeof(wself) sself = wself;
        sself.loaded = NO;
        NSLog(@"JS Error with Strategy (%@): %@", _fileName, exception);
    };

    return [context evaluateScript:data];
}

- (BOOL)reloadDataFromURL:(NSURL *_Nonnull)strategyURL
{
    self.strategyURL = strategyURL;
    JSValue *strategyData = [self _loadFile];
    return [self _setupData:strategyData];
}

// quick helper function for safely extracting script strings from jsvalue
static inline NSString *js_string_for_key(NSString *key, JSValue *node)
{
    JSValue *value = node[key];
    if (!value || [value isNull] || [value isUndefined])
        return @"";

    return [[value toString] addExecutionStringToScript];
}

- (BOOL)_setupData:(JSValue *_Nonnull)data
{
    if (!_fileName || !_fileName.length)
        return NO;

    JSValue *version = data[kBSMediaStrategyKeyVersion];
    NSInteger strategyVersion = ([version isNull] || [version isUndefined]) ? 0 : [version toUInt32];
    if (_strategyVersion >= strategyVersion)
    {
        NSLog(@"WARNING: Tried to update a strategy %@ with an older version.", _fileName);
        return NO;
    }

    self.acceptParams = [self _setupAccept:data];

    NSString *displayName = [data[kBSMediaStrategyKeyDisplayName] toString];
    self.scripts = @{
        kBSMediaStrategyKeyDisplayName: (displayName ?: _fileName),
        kBSMediaStrategyKeyIsPlaying:   js_string_for_key(kBSMediaStrategyKeyIsPlaying, data),
        kBSMediaStrategyKeyToggle:      js_string_for_key(kBSMediaStrategyKeyToggle, data),
        kBSMediaStrategyKeyNext:        js_string_for_key(kBSMediaStrategyKeyNext, data),
        kBSMediaStrategyKeyPrevious:    js_string_for_key(kBSMediaStrategyKeyPrevious, data),
        kBSMediaStrategyKeyPause:       js_string_for_key(kBSMediaStrategyKeyPause, data),
        kBSMediaStrategyKeyFavorite:    js_string_for_key(kBSMediaStrategyKeyFavorite, data),
        kBSMediaStrategyKeyTrackInfo:   js_string_for_key(kBSMediaStrategyKeyTrackInfo, data)
    };
    return YES;
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
    if (!tab)
        return NO;

    NSString *script = [self isPlayingScript];
    NSNumber *isPlaying = [tab executeJavascript:script];
    return [isPlaying boolValue] ?: NO;
}

- (NSString * _Nonnull)toggle
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyToggle] ?: @"";
}

- (NSString * _Nonnull)previous
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyPrevious] ?: @"";
}

- (NSString * _Nonnull)next
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyNext] ?: @"";
}

- (NSString * _Nonnull)pause
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyPause] ?: @"";
}

- (NSString * _Nonnull)favorite
{
    if (!_scripts)
        return @"";

    return _scripts[kBSMediaStrategyKeyFavorite] ?: @"";
}

- (BSTrack * _Nullable)trackInfo:(TabAdapter * _Nonnull)tab
{
    if (!_scripts)
        return nil;

    NSString *script = [self trackInfoScript];
    NSDictionary *trackData = [tab executeJavascript:script];
    return (trackData && trackData.count) ? [[BSTrack alloc] initWithInfo:trackData] : nil;
}


- (NSString * _Nonnull)isPlayingScript
{
    return [self scriptForKey:kBSMediaStrategyKeyIsPlaying];
}

- (NSString * _Nonnull)trackInfoScript
{
    return [self scriptForKey:kBSMediaStrategyKeyTrackInfo];
}

#pragma mark - Internal script retrieval

- (NSString * _Nonnull)scriptForKey:(NSString * _Nonnull)key
{
    if (!_scripts || !_scripts.count)
        return @"";

    NSString *script = _scripts[key];
    if (!script || !script.length)
        return @"";

    return script;
}

@end
