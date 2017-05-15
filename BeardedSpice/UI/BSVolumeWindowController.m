//
//  BSVolumeWindowController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.05.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSVolumeWindowController.h"

#define BASE_FONT_NAME              @"HelveticaNeue-Medium"
#define BASE_FONT_SIZE              36.0f

@implementation BSVolumeWindowController {
    NSTimer *_hideTimer;
}


static BSVolumeWindowController *singletonBSVolumeWindowController;

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods
/////////////////////////////////////////////////////////////////////

+ (BSVolumeWindowController *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSVolumeWindowController = [[BSVolumeWindowController alloc] initWithWindowNibName:@"BSVolumeWindowController"];
    });
    
    return singletonBSVolumeWindowController;
}


- (void)windowDidLoad {
    [super windowDidLoad];

    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setOpaque:NO];
    [self.window setStyleMask:NSBorderlessWindowMask];
    self.window.ignoresMouseEvents = YES;
    self.window.level = NSFloatingWindowLevel;
    
    NSVisualEffectView *visualEffectView = self.window.contentView;
    visualEffectView.maskImage = [self maskImageWithCornerRadius:20.0f];
    visualEffectView.state = NSVisualEffectStateActive;
    visualEffectView.material = NSVisualEffectMaterialMediumLight;
}

- (void)showWithType:(BSVWType)type title:(NSString *)title {
    
    if (self.window == nil) { //this needs for load of the window
        
        return;
    }
    
    if (title == nil) {
        title = @"BeardedSpice";
    }
    
    NSSize maxSize = NSMakeSize(self.maxWithForText.constant, self.maxHeightForText.constant);
    NSFont *testFont = [NSFont fontWithName:BASE_FONT_NAME size:BASE_FONT_SIZE];
    NSAttributedString *testString = [[NSAttributedString alloc]
                                      initWithString:title attributes:@{
                                                                        NSFontAttributeName: testFont
                                                                        }];
    
    CGFloat realFontSize = MIN((maxSize.width * BASE_FONT_SIZE / testString.size.width), (maxSize.height * BASE_FONT_SIZE / testString.size.height));
    
    self.textField.font = [NSFont fontWithName:BASE_FONT_NAME size:realFontSize];
    self.textField.stringValue = title;
    
    switch (type) {
            
        case BSVWMute:
            
            self.imageView.image = [NSImage imageNamed:@"volumeMute"];
            break;
            
        case BSVWUnmute:
            
            self.imageView.image = [NSImage imageNamed:@"volumeUnmute"];
            break;
            
        case BSVWUp:
            
            self.imageView.image = [NSImage imageNamed:@"volumeUp"];
            break;
            
        case BSVWDown:
            
            self.imageView.image = [NSImage imageNamed:@"volumeDown"];
            break;
            
        case BSVWUnavailable:
        default:
            
            self.imageView.image = [NSImage imageNamed:@"volumeUnavailable"];
            break;
    }
    
    @synchronized (self) {

        [_hideTimer invalidate];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.01];
        [[self.window animator] setAlphaValue:1];
        [NSAnimationContext endGrouping];
        
        [self.window orderFront:self];
        
        _hideTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
           
            
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                
                context.duration = 1.0f;
                [[self.window animator] setAlphaValue:0.0f];
            } completionHandler:^{
                [self.window orderOut:self];
                self.window.alphaValue = 1.0f;
            }];
        }];
    }
}

/////////////////////////////////////////////////////////////////////
#pragma mark -  Private Methoda

- (NSImage *)maskImageWithCornerRadius:(CGFloat)cornerRadius {
    
    CGFloat edgeLength = 2.0 * cornerRadius + 1.0;
    NSImage *maskImage = [NSImage imageWithSize:NSMakeSize(edgeLength, edgeLength) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
       
        NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:dstRect xRadius:cornerRadius yRadius:cornerRadius];
        NSColor *color = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:1];
        [color setFill];
        [bezierPath fill];
        return YES;
    }];
    
    maskImage.capInsets = NSEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius);
    maskImage.resizingMode = NSImageResizingModeStretch;
    
    return maskImage;
}

@end
