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
