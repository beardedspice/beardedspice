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

//---
NSString *const kBSMediaStrategyErrorDomain     = @"kBSMediaStrategyErrorDomain";


@interface BSMediaStrategy ()

// Metadata
@property (nonatomic, assign) long strategyVersion;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *strategyURL;
@property (nonatomic) BOOL custom;
@property (nonatomic) NSString * _Nonnull strategyJsBody;

// Cached scripts/components
@property (nonatomic, strong) NSDictionary *acceptParams;
@property (nonatomic, strong) NSDictionary *scripts;

// Internal setup functions
- (NSError *)_loadFile;
- (NSError *)_setupData:(JSValue *_Nonnull)data;
- (NSDictionary *_Nonnull)_setupAccept:(JSValue *_Nonnull)data;

@end

@implementation BSMediaStrategy

+ (BSMediaStrategy *)mediaStrategyWithURL:(NSURL *)strategyURL
                                    error:(NSError **)error {

    BSMediaStrategy *strategy = [BSMediaStrategy new];

    strategy.strategyURL = strategyURL;
    
    strategy.fileName = [[[strategyURL lastPathComponent]
        stringByDeletingPathExtension] stringByAppendingString:@".js"]; // Prevent custom extension, like 'bsstrategy'

    strategy.custom = [[strategyURL absoluteString]
        hasPrefix:[[NSURL URLForCustomStrategies] absoluteString]];

    // We don't need strategy, which is not loaded.
    NSError *err = [strategy _loadFile];
    if (err) {
        NSLog(@"Failed to load strategy with URL: %@", strategyURL);
        if (error) {
            *error = err;
        }

        strategy = nil;
    }

    return strategy;
}

#pragma mark - Helper Functions

/**
 Copying of the variables, which reflect state of the object.
 
 @param strategy Object from which performed copying.
 
 @return Returns self.
 */
- (instancetype _Nonnull)copyStateFrom:(BSMediaStrategy * _Nonnull)strategy{

    self.strategyVersion = strategy.strategyVersion;
    self.strategyURL = strategy.strategyURL;
    self.strategyJsBody = strategy.strategyJsBody;
    self.custom = strategy.custom;
    self.fileName = strategy.fileName;
    self.scripts = strategy.scripts;
    self.acceptParams = strategy.acceptParams;
    
    return self;
}

- (NSComparisonResult)compare:(BSMediaStrategy *)strategy{
    
    return [self.displayName localizedCompare:strategy.displayName];
}

- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName
{
    NSString *value = _scripts[methodName];
    return (value && value.length);
}

- (NSError *)_loadFile
{
    if (!_strategyURL)
        return [self internalError];
    
    NSError *error = nil;
    _strategyJsBody = [[NSString alloc] initWithContentsOfURL:_strategyURL encoding:NSUTF8StringEncoding error:&error];
    if ([NSString isNullOrEmpty:_strategyJsBody])
        return [self internalError];
    
    __block NSError *err = nil;
    JSContext *context = [JSContext new];
    
    // This is run synchronously with evaluateScript :)
    context.exceptionHandler = ^(JSContext __attribute__((unused)) * context,
                                 JSValue * exception) {
      NSString *descr = [NSString
          stringWithFormat:NSLocalizedString(
                               @"Error occured when parsing javascript: %@",
                               @"(BSMediaStrategy) Parsing javascript error "
                               @"description."),
                           exception];
      err = [NSError errorWithDomain:kBSMediaStrategyErrorDomain
                                code:BSMS_ERROR_JSPARSING
                            userInfo:@{NSLocalizedDescriptionKey : descr}];
      NSLog(@"JS Error with Strategy (%@): %@", _fileName, exception);
    };

    JSValue *strategyData = [context evaluateScript:_strategyJsBody];
    if (!err && strategyData.isObject)
        return [self _setupData:strategyData];
    
    return err;
}

- (NSError *)reloadDataFromURL:(NSURL *_Nonnull)strategyURL
{
    NSError *error;
    BSMediaStrategy *newStrategy = [BSMediaStrategy mediaStrategyWithURL:strategyURL error:&error];
    if (newStrategy) {
        [self copyStateFrom:newStrategy];
        return nil;
    }
    return error;
}

// quick helper function for safely extracting script strings from jsvalue
static inline NSString *js_string_for_key(NSString *key, JSValue *node)
{
    JSValue *value = node[key];
    if (!value || [value isNull] || [value isUndefined])
        return @"";

    return [[value toString] addExecutionStringToScript];
}

- (NSError *)_setupData:(JSValue *_Nonnull)data
{
    if (!_fileName || !_fileName.length)
        return [self internalError];

    NSString *displayName = [data[kBSMediaStrategyKeyDisplayName] toString];
    if ([NSString isNullOrEmpty:displayName]) {
        return [NSError
            errorWithDomain:kBSMediaStrategyErrorDomain
                       code:BSMS_ERROR_DISPLAYNAME
                   userInfo:@{
                       NSLocalizedDescriptionKey : NSLocalizedString(
                           @"Error occured when checking strategy: display "
                           @"name of the strategy don't found.",
                           @"(BSMediaStrategy) Not found displayName error "
                           @"description")
                   }];
    }

    JSValue *version = data[kBSMediaStrategyKeyVersion];
    self.strategyVersion = ([version isNull] || [version isUndefined]) ? 0 : [version toUInt32];
    self.acceptParams = [self _setupAccept:data];

    self.scripts = @{
        kBSMediaStrategyKeyDisplayName: displayName,
        kBSMediaStrategyKeyIsPlaying:   js_string_for_key(kBSMediaStrategyKeyIsPlaying, data),
        kBSMediaStrategyKeyToggle:      js_string_for_key(kBSMediaStrategyKeyToggle, data),
        kBSMediaStrategyKeyNext:        js_string_for_key(kBSMediaStrategyKeyNext, data),
        kBSMediaStrategyKeyPrevious:    js_string_for_key(kBSMediaStrategyKeyPrevious, data),
        kBSMediaStrategyKeyPause:       js_string_for_key(kBSMediaStrategyKeyPause, data),
        kBSMediaStrategyKeyFavorite:    js_string_for_key(kBSMediaStrategyKeyFavorite, data),
        kBSMediaStrategyKeyTrackInfo:   js_string_for_key(kBSMediaStrategyKeyTrackInfo, data)
    };
    return nil;
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
        NSString *acceptScript = [[value toString] addExecutionStringToScript];
        return @{
            kBSMediaStrategyAcceptMethod: method,
            kBSMediaStrategyKeyAccept: (acceptScript ?: @"")
        };
    }

    return @{};
}

- (NSError *)internalError{

    return [NSError errorWithDomain:kBSMediaStrategyErrorDomain
                               code:BSMS_ERROR_INTERNAL
                           userInfo:@{
                               NSLocalizedDescriptionKey :
                                   NSLocalizedString(@"Internal error occured.", @"(BSMediaStrategy) Internal error description.")
                               }];
}

#pragma mark - Core Functionality

- (NSString * _Nonnull)displayName
{
    return _scripts[kBSMediaStrategyKeyDisplayName];
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

    NSString *script = _scripts[kBSMediaStrategyKeyIsPlaying];
    if ([NSString isNullOrEmpty:script]) {
        return NO;
    }
    
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

    NSString *script = _scripts[kBSMediaStrategyKeyTrackInfo];
    if ([NSString isNullOrEmpty:script]) {
        return nil;
    }
    
    NSDictionary *trackData = [tab executeJavascript:script];
    return (trackData && trackData.count) ? [[BSTrack alloc] initWithInfo:trackData] : nil;
}

- (NSString *)description{

    return [NSString
        stringWithFormat:
            NSLocalizedString(
                @"Strategy with file name: \"%@\"\nDisplay name: \"%@\"\nVersion: %d",
                @"(BSMediaStrategy) Format of the media strategy description"),
            self.fileName, self.displayName, self.strategyVersion];
}

@end
