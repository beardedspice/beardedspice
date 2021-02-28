//
//  BSStrategyCache.m
//  BeardedSpice
//
//  Created by Alex Evers on 05/28/2016
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyCache.h"
#import "BSMediaStrategy.h"


NSString *BSMediaStrategyErrorDomain = @"BSMediaStrategyErrorDomain";

@interface BSStrategyCache ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BSMediaStrategy *> *cache;
@property (nonatomic, strong) dispatch_queue_t cacheSerialQueue;
@end

@implementation BSStrategyCache

- (instancetype)initWithDelegate:(id<BSStrategyCacheDelegateProtocol>)delegate {
    if (delegate) {
        self = [self init];
        _delegate = delegate;
        return self;
    }
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // this is a dictionary instead of NSCache for extra add/remove functions.
        // Plus we don't want this to randomly get garbage collected
        _cache = [NSMutableDictionary new];
        _cacheSerialQueue = dispatch_queue_create("com.beardedspice.cache.strategies.serial", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSArray<NSString *> *)allKeys
{
    return [self.cache allKeys];
}

- (NSArray <BSMediaStrategy *> *)allStrategies{
    
    return [self.cache allValues];
}

- (void)removeStrategyFromCache:(BSMediaStrategy * _Nonnull)strategy
{
    __weak typeof(self) wself = self;
    dispatch_sync(_cacheSerialQueue, ^{
        // make a new strong pointer to this obj
        __strong typeof(wself) sself = wself;
        [sself.cache removeObjectForKey:strategy.fileName];
    });
    [self.delegate didDeleteStrategy:strategy];
}

- (NSError *)updateStrategyWithURL:(NSURL * _Nonnull)strategyURL
{
    
    __block NSError *result = nil;
    __block BSMediaStrategy *strategy;
    dispatch_sync(_cacheSerialQueue, ^{
        NSString *fileName = [strategyURL lastPathComponent];
        strategy = [_cache objectForKey:fileName];
        if (strategy){
            // do not update strategy if it was loaded from custom folder already,
            // or update if path is equal
            if (!strategy.custom || [[strategyURL path] isEqualToString:[strategy.strategyURL path]]) {
                result = [strategy reloadDataFromURL:strategyURL];
            }
        }
        else{
            result = [NSError errorWithDomain:BSMediaStrategyErrorDomain code:BSSC_ERROR_STRATEGY_NOTFOUND userInfo:nil];
        }
    });
    
    if (result == nil) {
        [self.delegate didChangeStrategy:strategy];
    }
    return result;
}

- (BSMediaStrategy *)addStrategyWithURL:(NSURL * _Nonnull)strategyURL
{
    
    __block BSMediaStrategy *result = nil;
    dispatch_sync(_cacheSerialQueue, ^{
        NSString *fileName = [strategyURL lastPathComponent];
        result = [BSMediaStrategy mediaStrategyWithURL:strategyURL error:nil];
        if (result) {
            _cache[fileName] = result;
        }
    });
    
    if (result) {
        [self.delegate didAddStrategy:result];
    }
    return result;
}

- (BSMediaStrategy * _Nullable)strategyForFileName:(NSString * _Nonnull)strategyName
{
    return _cache[strategyName];
}

#pragma mark - Cache Management

- (BOOL)loadStrategies
{
    NSURL *resourcesUrl = [NSURL URLForBundleStrategies];
    BOOL ret = [self updateStrategiesFromSourceURL:resourcesUrl];
    if (!ret)
        return NO;

#if !DEBUG_STRATEGY
    NSURL *savedURL = [NSURL URLForSavedStrategies];
    ret = [savedURL createDirectoriesToURL];
    if (!ret)
        return NO;

    ret = [self updateStrategiesFromSourceURL:savedURL];
    if (!ret)
        return NO;

    NSURL *customURL = [NSURL URLForCustomStrategies];
    ret = [customURL createDirectoriesToURL];
    if (!ret)
        return NO;

    ret = [self updateStrategiesFromSourceURL:customURL];
    if (!ret)
        DDLogWarn(@"Warning updating custom strategies. Reverting to official.");
#endif

    return YES;
}

- (BOOL)updateStrategiesFromSourceURL:(NSURL * _Nonnull)path
{
    NSError *error = nil;
    NSString *absPath = path.path;

    NSArray<NSString *> *elements = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absPath error:&error];
    if (error)
    {
        DDLogError(@"Error updating strategies from URL (%@): %@", absPath, [error localizedDescription]);
        return NO;
    }

    for (NSString *fileName in elements)
    {
        if ([fileName isEqualToString:@"versions.plist"])
            continue;

        NSURL *filePath = [[NSURL alloc] initWithString:fileName relativeToURL:path];
        NSError *err = [self updateStrategyWithURL:filePath];
        if (err.code == BSSC_ERROR_STRATEGY_NOTFOUND) {
            [self addStrategyWithURL:filePath];
        }
        
    }
    return YES;
}

@end
