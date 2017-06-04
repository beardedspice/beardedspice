//
//  BSVolumeWindowController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.05.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

typedef NS_ENUM(Byte, BSVWType) {
    
    BSVWUnavailable,
    BSVWUp,
    BSVWDown,
    BSVWMute,
    BSVWUnmute
};

@interface BSVolumeWindowController : NSWindowController

+ (BSVolumeWindowController *)singleton;

@property (weak) IBOutlet NSVisualEffectView *backView;

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSLayoutConstraint *maxWithForText;
@property (weak) IBOutlet NSLayoutConstraint *maxHeightForText;


- (void)showWithType:(BSVWType)type title:(NSString *)aTitle;

@end
