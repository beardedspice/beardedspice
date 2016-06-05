//
//  BSStrategyCache.m
//  BeardedSpice
//
//  Created by Alex Evers on 05/28/2016
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyCache.h"
#import "BSMediaStrategy.h"

/// Folder name, which contains media strategies, in app bundle.
static NSString *const kBSMediaStrategiesResourcesFolder = @"MediaStrategies";

@interface BSStrategyCache ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BSMediaStrategy *> *cache;
@property (nonatomic, strong) dispatch_queue_t cacheSerialQueue;
@end

@implementation BSStrategyCache

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

- (void)removeStrategyFromCache:(NSString * _Nonnull)strategyName
{
    __weak typeof(self) wself = self;
    dispatch_sync(_cacheSerialQueue, ^{
        // make a new strong pointer to this obj
        __strong typeof(wself) sself = wself;
        [sself.cache removeObjectForKey:strategyName];
    });
}

- (void)updateCacheWithURL:(NSURL * _Nonnull)strategyURL
{
    __weak typeof(self) wself = self;
    dispatch_sync(_cacheSerialQueue, ^{
        // make a new strong pointer to this obj
        __strong typeof(wself) sself = wself;
        [sself _updateCacheWithURL:strategyURL];
    });
}

- (void)_updateCacheWithURL:(NSURL *_Nonnull)strategyURL
{
    NSString *fileName = [strategyURL lastPathComponent];
    BSMediaStrategy *strategy = [_cache objectForKey:fileName];
    if (strategy){
        // do not update strategy if it was loaded from custom folder already,
        // or update if path is equal
        if (!strategy.custom || [strategyURL isEqual:strategy.strategyURL]) {
            [strategy reloadDataFromURL:strategyURL];
        }
    }
    else
        _cache[fileName] = [[BSMediaStrategy alloc] initWithStrategyURL:strategyURL];
}

- (BSMediaStrategy * _Nullable)strategyForName:(NSString * _Nonnull)strategyName
{
    return _cache[strategyName];
}

#pragma mark - Cache Management

- (BOOL)loadStrategies
{
    NSURL *resourcesUrl = [[NSBundle mainBundle] resourceURL];
    BOOL ret = [self updateStrategiesFromSourceURL:[resourcesUrl URLByAppendingPathComponent:kBSMediaStrategiesResourcesFolder]];
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
        NSLog(@"Warning updating custom strategies. Reverting to official.");
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
        NSLog(@"Error updating strategies from URL (%@): %@", absPath, [error localizedDescription]);
        return NO;
    }

    for (NSString *fileName in elements)
    {
        if ([fileName isEqualToString:@"versions.plist"])
            continue;

        NSURL *filePath = [[NSURL alloc] initWithString:fileName relativeToURL:path];
        [self updateCacheWithURL:filePath];
    }
    return YES;
}

@end
