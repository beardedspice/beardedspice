//
//  BSVolumeWindowController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.05.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    
    BSVWUnavailable = 0,
    BSVWUp,
    BSVWDown,
    BSVWMute,
    BSVWUnmute
} BSVWType;

@interface BSVolumeWindowController : NSWindowController

+ (BSVolumeWindowController *)singleton;

@property (weak) IBOutlet NSVisualEffectView *backView;

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSLayoutConstraint *maxWithForText;
@property (weak) IBOutlet NSLayoutConstraint *maxHeightForText;


- (void)showWithType:(BSVWType)type title:(NSString *)aTitle;

@end
