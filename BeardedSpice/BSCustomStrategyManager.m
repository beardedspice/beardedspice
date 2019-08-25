//
//  BSCustomStrategyManager.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 25.06.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "BSCustomStrategyManager.h"
#import "BSMediaStrategy.h"
#import "AppDelegate.h"
#import "NSURL+Utils.h"
#import "MediaStrategyRegistry.h"
#import "BSStrategyCache.h"

NSString *BSCStrategyChangedNotification = @"BSCStrategyChangedNotification";

@implementation BSCustomStrategyManager

static BSCustomStrategyManager *singletonCustomStrategyManager;

/////////////////////////////////////////////////////////////////////
#pragma mark - Initialize

+ (BSCustomStrategyManager *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonCustomStrategyManager = [BSCustomStrategyManager alloc];
        singletonCustomStrategyManager = [singletonCustomStrategyManager init];
    });
    
    return singletonCustomStrategyManager;
    
}

- (id)init{
    
    if (singletonCustomStrategyManager != self) {
        return nil;
    }
    self = [super init];
    
    return self;
}

/////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

- (BOOL)importFromPath:(NSString *)path{
    
    return [self importFromUrl:[NSURL fileURLWithPath:path]];
}

- (BOOL)importFromUrl:(NSURL *)url{
    
    if (!url) {
        return NO;
    }
    
    NSError *error = nil;
    BSMediaStrategy *strategy = [BSMediaStrategy mediaStrategyWithURL:url error:&error];
    if (strategy) {
        
        error = nil; // reset the local error
        
        NSURL *pathToFile = [NSURL URLForCustomStrategies];
        pathToFile = [pathToFile URLByAppendingPathComponent:strategy.fileName];
        [strategy.strategyJsBody writeToURL:pathToFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Error saving strategy %@: %@", strategy, [error localizedDescription]);
        }
        else{
            
            MediaStrategyRegistry *registry = [MediaStrategyRegistry singleton];
            error = [registry.strategyCache updateStrategyWithURL:pathToFile];
            
            if (error.code == BSSC_ERROR_STRATEGY_NOTFOUND) {
                
                BSMediaStrategy *newStrategy = [registry.strategyCache addStrategyWithURL:pathToFile];
                if (newStrategy) {
                    
                    [registry addAvailableMediaStrategy:newStrategy];
                    error = nil;
                }
            };

            if (!error) {
                // Good
                dispatch_async(dispatch_get_main_queue(), ^{

                  [self notifyThatChanged];
                  NSAlert *alert = [NSAlert new];
                  NSString *strategyName =
                      [strategy.fileName stringByDeletingPathExtension];
                    alert.alertStyle = NSAlertStyleInformational;
                  alert.informativeText = [strategy description];
                  alert.messageText = [NSString
                      stringWithFormat:
                          NSLocalizedString(
                              @"Strategy \"%@\" imported successfuly.",
                              @"(BSCustomStrategyManager) Title on message, "
                              @"when strategy import error occured."),
                          strategyName];
                  [alert addButtonWithTitle:NSLocalizedString(@"Ok",
                                                              @"Ok button")];

                  [APPDELEGATE windowWillBeVisible:alert];

                  [alert runModal];

                  [APPDELEGATE removeWindow:alert];
                });
                return YES;
            }
        }
        

    }

    dispatch_async(dispatch_get_main_queue(), ^{

      NSAlert *alert = [NSAlert new];
      NSString *strategyName =
          [[url lastPathComponent] stringByDeletingPathExtension];
        alert.alertStyle = NSAlertStyleCritical;
      alert.informativeText = error.localizedDescription;
      alert.messageText = [NSString
          stringWithFormat:NSLocalizedString(@"Can't import \"%@\" strategy.",
                                             @"(BSCustomStrategyManager) Title "
                                             @"on message, when strategy "
                                             @"import error occured."),
                           strategyName];
      [alert addButtonWithTitle:NSLocalizedString(@"Ok", @"Ok button")];

      [APPDELEGATE windowWillBeVisible:alert];

      [alert runModal];

      [APPDELEGATE removeWindow:alert];
    });

    return NO;
}

- (BOOL)exportStrategy:(BSMediaStrategy *)strategy toFolder:(NSURL *)folderURL{

    if (!(strategy && folderURL)) {
        return NO;
    }

    NSError *error = nil;
    NSString *fileName = [[strategy.fileName stringByDeletingPathExtension]
        stringByAppendingString:@"." BS_STRATEGY_EXTENSION];
    NSURL *pathToFile = [folderURL URLByAppendingPathComponent:fileName];

    if ([pathToFile checkResourceIsReachableAndReturnError:nil]) {

        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSAlertStyleInformational;
//        alert.informativeText = [strategy description];
        alert.messageText = [NSString
            stringWithFormat:NSLocalizedString(
                                 @"File \"%@\" exists.\nDo you want overwrite?",
                                 @"(BSCustomStrategyManager) Title on message, "
                                 @"when file exists."),
                             fileName];
        [alert
            addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];

        [alert addButtonWithTitle:NSLocalizedString(@"Overwrite",
                                                    @"Overwrite button")];
        [APPDELEGATE windowWillBeVisible:alert];

        NSInteger result = [alert runModal];

        [APPDELEGATE removeWindow:alert];
        if (result == NSAlertFirstButtonReturn) {
            return NO;
        };
    }

    [strategy.strategyJsBody writeToURL:pathToFile
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:&error];
    
    if (error) {
        NSLog(@"Error saving strategy %@: %@", strategy,
              [error localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{

          NSAlert *alert = [NSAlert new];
            alert.alertStyle = NSAlertStyleCritical;
          alert.informativeText = error.localizedDescription;
          alert.messageText =
              [NSString stringWithFormat:
                            NSLocalizedString(
                                @"Can't export \"%@\" strategy.",
                                @"(BSCustomStrategyManager) Title on message, "
                                @"when strategy export error occured."),
                            strategy.displayName];
          [alert addButtonWithTitle:NSLocalizedString(@"Ok", @"Ok button")];

          [APPDELEGATE windowWillBeVisible:alert];

          [alert runModal];

          [APPDELEGATE removeWindow:alert];
        });

        return NO;
    }

    [[NSWorkspace sharedWorkspace]
        activateFileViewerSelectingURLs:@[ pathToFile ]];
    return YES;
}

- (BOOL)removeStrategy:(BSMediaStrategy *)strategy{
    
    if (!strategy.custom) {
        return NO;
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:strategy.strategyURL error:&error];
    if (error)
    {
        NSLog(@"Error removing strategy %@: %@", strategy, [error localizedDescription]);
    }
    else{
        
        BSStrategyCache *cache = [[MediaStrategyRegistry singleton] strategyCache];
        
        [[MediaStrategyRegistry singleton] removeAvailableMediaStrategy:strategy];
        [cache removeStrategyFromCache:strategy.fileName];

        NSURL *alternativeURL = [[NSURL URLForSavedStrategies] URLByAppendingPathComponent:strategy.fileName];
        BSMediaStrategy *newStrategy = [cache addStrategyWithURL:alternativeURL];
        if (!newStrategy) {
            alternativeURL = [[NSURL URLForBundleStrategies] URLByAppendingPathComponent:strategy.fileName];
            newStrategy = [cache addStrategyWithURL:alternativeURL];
        }
        
        if (newStrategy) {
            
            [[MediaStrategyRegistry singleton] addAvailableMediaStrategy:newStrategy];
        }
        
        // Good
        dispatch_async(dispatch_get_main_queue(), ^{

          [self notifyThatChanged];

          NSAlert *alert = [NSAlert new];
            alert.alertStyle = NSAlertStyleInformational;
          alert.informativeText = [strategy description];
          alert.messageText =
              [NSString stringWithFormat:
                            NSLocalizedString(
                                @"Strategy \"%@\" removed successfuly.",
                                @"(BSCustomStrategyManager) Title on message, "
                                @"when strategy import error occured."),
                            strategy.displayName];
          [alert addButtonWithTitle:NSLocalizedString(@"Ok", @"Ok button")];

          [APPDELEGATE windowWillBeVisible:alert];

          [alert runModal];

          [APPDELEGATE removeWindow:alert];
        });
        return YES;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

      NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSAlertStyleCritical;
      alert.informativeText = error.localizedDescription;
      alert.messageText =
          [NSString stringWithFormat:NSLocalizedString(
                                         @"Can't remove \"%@\" strategy.",
                                         @"(BSCustomStrategyManager) Title "
                                         @"on message, when strategy remove "
                                         @"error occured."),
                                     strategy.displayName];
      [alert addButtonWithTitle:NSLocalizedString(@"Ok", @"Ok button")];

      [APPDELEGATE windowWillBeVisible:alert];

      [alert runModal];

      [APPDELEGATE removeWindow:alert];
    });

    return NO;
}

/////////////////////////////////////////////////////////////////////
#pragma mark - Helper Methods

- (void)notifyThatChanged{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSCStrategyChangedNotification
         object:self];
    });
}

@end
