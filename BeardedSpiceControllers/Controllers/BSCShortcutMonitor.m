//
//  BSCShortcutMonitor.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.03.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "BSCShortcutMonitor.h"
#import "MASHotKey.h"

@implementation BSCShortcutMonitor{
    
    NSMutableDictionary <MASShortcut *, MASHotKey *> *_hotKeys;
    
    CFMachPortRef _eventPort;
    CFRunLoopSourceRef _eventPortSource;
    CFRunLoopRef _tapThreadRL;
}

static CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon);

#pragma mark Initialization

- (instancetype) init
{
    self = [super init];
    if (self) {
        _hotKeys = [NSMutableDictionary dictionary];

        // Add an event tap to intercept the system defined media key events
        _eventPort = CGEventTapCreate(kCGSessionEventTap,
                                      kCGHeadInsertEventTap,
                                      kCGEventTapOptionDefault,
                                      CGEventMaskBit(kCGEventKeyDown),
                                      tapEventCallback,
                                      (__bridge void*)self);
        if (_eventPort) {
            
            _eventPortSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, _eventPort, 0);
            assert(_eventPortSource != NULL);
            
            [NSThread detachNewThreadSelector:@selector(eventTapThread) toTarget:self withObject:nil];
        }
    }
    
    return self;
}

- (void) dealloc{
    
    if (_tapThreadRL) {
        CFRunLoopStop(_tapThreadRL);
        _tapThreadRL = nil;
    }
    
    if (_eventPort) {
        CFMachPortInvalidate(_eventPort);
        CFRelease(_eventPort);
        _eventPort = nil;
    }
    
    if (_eventPortSource) {
        CFRelease(_eventPortSource);
        _eventPortSource = nil;
    }
}

+ (instancetype) sharedMonitor
{
    static dispatch_once_t once;
    static BSCShortcutMonitor *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Registration

- (BOOL) registerShortcut: (MASShortcut*) shortcut withAction: (dispatch_block_t) action
{
    MASHotKey *hotKey = [MASHotKey registeredHotKeyWithShortcut:shortcut];
    if (hotKey) {
        [hotKey setAction:action];
        _hotKeys[shortcut] = hotKey;
        return YES;
    } else {
        return NO;
    }
}

- (void) unregisterShortcut: (MASShortcut*) shortcut
{
    if (shortcut) {
        [_hotKeys removeObjectForKey:shortcut];
    }
}

- (void) unregisterAllShortcuts
{
    [_hotKeys removeAllObjects];
}

#pragma mark Event Handling

- (void)eventTapThread;
{
    @synchronized(self) {
        if (_eventPortSource) {
            _tapThreadRL = CFRunLoopGetCurrent();
            
            if (_tapThreadRL) {
                CFRunLoopAddSource(_tapThreadRL, _eventPortSource,
                                   kCFRunLoopCommonModes);
            }
        }
    }
    CFRunLoopRun();
}

- (CGEventRef)handleEvent:(CGEventRef)event type:(CGEventType)type{
    
    if(type == kCGEventTapDisabledByTimeout) {
        NSLog(@"Shortcuts event tap was disabled by timeout");
        @synchronized(self){
            if (_eventPort) {
                CGEventTapEnable(_eventPort, TRUE);
            }
        }
        return event;
    }
    
    if (type != kCGEventKeyDown)
        return event;
    
    NSEvent *nsEvent = nil;
    MASShortcut *shortcut;
    @try {
        nsEvent = [NSEvent eventWithCGEvent:event];
        shortcut = [MASShortcut shortcutWithEvent:nsEvent];
    }
    @catch (NSException * e) {
        NSLog(@"Strange CGEventType: %d: %@", type, e);
        assert(0);
        return event;
    }
    __block BOOL find = NO;
    [_hotKeys enumerateKeysAndObjectsUsingBlock:^(MASShortcut *_shortcut, MASHotKey *hotKey, BOOL *stop) {
        if ([_shortcut isEqual:shortcut]) {
            if ([hotKey action]) {
                dispatch_async(dispatch_get_main_queue(), [hotKey action]);
            }
            *stop = YES;
            find = YES;
        }
    }];
    
    if (find) {
        
        return NULL;
    }
    
    return event;

}

@end


static CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    BSCShortcutMonitor *monitor = (__bridge id)refcon;
    
    return [monitor handleEvent:event type:type];
}

