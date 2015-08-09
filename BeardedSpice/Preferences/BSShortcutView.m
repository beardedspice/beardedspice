//
//  BSShortcutView.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 09.08.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BSShortcutView.h"
#import "MASShortcutValidator.h"

#pragma mark -

@interface MASShortcutView () // Private accessors

@property (nonatomic, getter = isHinting) BOOL hinting;
@property (nonatomic, copy) NSString *shortcutPlaceholder;

- (void)activateResignObserver:(BOOL)shouldActivate;

@end

#pragma mark -

@implementation BSShortcutView

- (id)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _firstResponder = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder{

    self = [super initWithCoder:coder];
    if (self) {
        _firstResponder = NO;
    }
    return self;
}

#pragma mark - Draw

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - Focus ring

- (NSRect)focusRingMaskBounds {
    return [self bounds];
}

- (void)drawFocusRingMask {
    
    if (self.focusRingType != NSFocusRingTypeNone) {
        NSRectFill([self bounds]);
    }
}

- (BOOL)acceptsFirstResponder{
    if (self.enabled) {
        return YES;
    }
    return NO;
}

- (BOOL)becomeFirstResponder{
    
//    self.recording = YES;
    _firstResponder = YES;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder{
    
    self.recording = NO;
    _firstResponder = NO;
    return [super resignFirstResponder];
}

#pragma mark - Event monitoring

- (void)activateEventMonitoring:(BOOL)shouldActivate
{
    static BOOL isActive = NO;
    if (isActive == shouldActivate) return;
    isActive = shouldActivate;
    
    static id eventMonitor = nil;
    if (shouldActivate) {
        __unsafe_unretained BSShortcutView *weakSelf = self;
        NSEventMask eventMask = (NSKeyDownMask | NSFlagsChangedMask);
        eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *event) {
            
            // Create a shortcut from the event
            MASShortcut *shortcut = [MASShortcut shortcutWithEvent:event];

            // Tab key must pass through.
            if (shortcut.keyCode == kVK_Tab){
                return event;
            }
            // If the shortcut is a plain Delete or Backspace, clear the current shortcut and cancel recording
            if (!shortcut.modifierFlags && ((shortcut.keyCode == kVK_Delete) || (shortcut.keyCode == kVK_ForwardDelete))) {
                weakSelf.shortcutValue = nil;
                weakSelf.recording = NO;
                event = nil;
            }
            
            // If the shortcut is a plain Esc, cancel recording
            else if (!shortcut.modifierFlags && shortcut.keyCode == kVK_Escape) {
                weakSelf.recording = NO;
                event = nil;
            }
            
            // If the shortcut is Cmd-W or Cmd-Q, cancel recording and pass the event through
            else if ((shortcut.modifierFlags == NSCommandKeyMask) && (shortcut.keyCode == kVK_ANSI_W || shortcut.keyCode == kVK_ANSI_Q)) {
                weakSelf.recording = NO;
            }
            else {
                // Verify possible shortcut
                if (shortcut.keyCodeString.length > 0) {
                    if ([self.shortcutValidator isShortcutValid:shortcut]) {
                        // Verify that shortcut is not used
                        NSString *explanation = nil;
                        if ([self.shortcutValidator isShortcutAlreadyTakenBySystem:shortcut explanation:&explanation]) {
                            // Prevent cancel of recording when Alert window is key
                            [weakSelf activateResignObserver:NO];
                            [weakSelf activateEventMonitoring:NO];
                            NSString *format = NSLocalizedString(@"The key combination %@ cannot be used",
                                                                 @"Title for alert when shortcut is already used");
                            NSAlert* alert = [[NSAlert alloc]init];
                            alert.alertStyle = NSCriticalAlertStyle;
                            alert.informativeText = explanation;
                            alert.messageText = [NSString stringWithFormat:format, shortcut];
                            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Alert button when shortcut is already used")];
                            
                            [alert runModal];
                            weakSelf.shortcutPlaceholder = nil;
                            [weakSelf activateResignObserver:YES];
                            [weakSelf activateEventMonitoring:YES];
                        }
                        else {
                            weakSelf.shortcutValue = shortcut;
                            weakSelf.recording = NO;
                        }
                    }
                    else {
                        // Key press with or without SHIFT is not valid input
                        NSBeep();
                    }
                }
                else {
                    // User is playing with modifier keys
                    weakSelf.shortcutPlaceholder = shortcut.modifierFlagsString;
                }
                event = nil;
            }
            return event;
        }];
    }
    else {
        [NSEvent removeMonitor:eventMonitor];
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    
    if (_firstResponder) {
        @autoreleasepool {
            // Create a shortcut from the event
            MASShortcut *shortcut = [MASShortcut shortcutWithEvent:theEvent];
            
            // If the shortcut is a plain Delete or Backspace, clear the current
            // shortcut and cancel recording
            if (!shortcut.modifierFlags &&
                ((shortcut.keyCode == kVK_Delete) ||
                 (shortcut.keyCode == kVK_ForwardDelete))) {
                    self.shortcutValue = nil;
                    return YES;
                }
            if (!shortcut.modifierFlags && (shortcut.keyCode == kVK_Return ||
                                            shortcut.keyCode == kVK_Space)) {
                
                self.recording = YES;
                return YES;
            }
        }
    }
    
    return NO;
}  


@end
