//
//  BSNativeAppTabsController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 09.11.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSNativeAppTabsController.h"
#import "runningSBApplication.h"
#import "NativeAppTabRegistry.h"
#import "NativeAppTabAdapter.h"
#import "BSTimeout.h"
#import "BSSharedDefaults.h"

@implementation BSNativeAppTabsController {
    
    NSArray <NativeAppTabAdapter *> *_tabs;
    dispatch_queue_t _workQueue;
    NSOperationQueue *_oQueue;
    id _observer;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

static BSNativeAppTabsController *singletonBSNativeAppTabsController;

+ (BSNativeAppTabsController *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSNativeAppTabsController = [BSNativeAppTabsController alloc];
        singletonBSNativeAppTabsController = [singletonBSNativeAppTabsController init];
    });
    
    return singletonBSNativeAppTabsController;
}

- (id)init{
    
    if (singletonBSNativeAppTabsController != self) {
        return nil;
    }
    self = [super init];
    if (self) {
        _workQueue = dispatch_queue_create("NativeAppTabsController", DISPATCH_QUEUE_SERIAL);
        _tabs = [NSArray new];
        
        [self fillCache];
        [[NSWorkspace sharedWorkspace] addObserver:self
                                        forKeyPath:@"runningApplications"
                                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                                           context:NULL];
        
        _oQueue = [NSOperationQueue new];
        _oQueue.underlyingQueue = _workQueue;
        _observer = [[NSNotificationCenter defaultCenter]
                     addObserverForName:BSNativeAppTabRegistryChangedNotification
                     object:nil queue:_oQueue usingBlock:^(NSNotification * _Nonnull note) {
                         [self fillCache];
                     }];
    }
    
    return self;
}

- (void)dealloc{
    
    @try {
        
        [[NSWorkspace sharedWorkspace] removeObserver:self forKeyPath:@"runningApplications"];
    }
    @catch (NSException *exception) {
        // Silent approach.
    }
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}
/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

- (NSArray <NativeAppTabAdapter *> *)tabs {
    @synchronized (self) {
        return [_tabs copy];
    }
}
/////////////////////////////////////////////////////////////////////
#pragma mark Private class

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"runningApplications"]) {
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        if (indexes) {
            [self fillCache];
        }
    }
}

- (void)fillCache{
    dispatch_async(_workQueue, ^{
        @autoreleasepool {
            NSMutableArray *tabs = [NSMutableArray new];
            BSTimeout *timeout = [BSTimeout timeoutWithInterval:COMMAND_EXEC_TIMEOUT];
            for (Class nativeApp in [[NativeAppTabRegistry singleton] enabledNativeAppClasses]) {
                runningSBApplication *app = [runningSBApplication sharedApplicationForBundleIdentifier:[nativeApp bundleId]];
                if (app) {
                    NativeAppTabAdapter *tab = [nativeApp tabAdapterWithApplication:app];
                    if (tab) {
                        [tabs addObject:tab];
                    }
                }
                if (timeout.reached) {
                    break;
                }
            }
            @synchronized(self) {
                _tabs = [tabs copy];
            }
        }
    });
}

@end

