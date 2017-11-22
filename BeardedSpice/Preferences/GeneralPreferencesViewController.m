//
//  GeneralPreferencesViewController.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GeneralPreferencesViewController.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabRegistry.h"
#import "MediaControllerObject.h"
#import "BSLaunchAtLogin.h"
#import "BSMediaStrategyEnableButton.h"
#import "BSMediaStrategy.h"
#import "BSStrategyCache.h"
#import "BSStrategyVersionManager.h"
#import "EHVerticalCenteredTextField.h"
#import "BSCustomStrategyManager.h"
#import "AppDelegate.h"
#import "EHExecuteBlockDelayed.h"
#import "BSBrowserExtensionsController.h"

#define RELAXING_TIMEOUT                   3 //seconds

NSString *const GeneralPreferencesAutoPauseChangedNoticiation = @"GeneralPreferencesAutoPauseChangedNoticiation";
NSString *const GeneralPreferencesUsingAppleRemoteChangedNoticiation = @"GeneralPreferencesUsingAppleRemoteChangedNoticiation";
NSString *const GeneralPreferencesWebSocketServerPortChangedNoticiation = @"GeneralPreferencesWebSocketServerPortChangedNoticiation";
NSString *const GeneralPreferencesWebSocketServerEnabledChangedNoticiation = @"GeneralPreferencesWebSocketServerEnabledChangedNoticiation";

NSString *const BeardedSpiceAlwaysShowNotification = @"BeardedSpiceAlwaysShowNotification";
NSString *const BeardedSpiceRemoveHeadphonesAutopause = @"BeardedSpiceRemoveHeadphonesAutopause";
NSString *const BeardedSpiceUsingAppleRemote = @"BeardedSpiceUsingAppleRemote";
NSString *const BeardedSpiceLaunchAtLogin = @"BeardedSpiceLaunchAtLogin";
NSString *const BeardedSpiceUpdateAtLaunch = @"BeardedSpiceUpdateAtLaunch";
NSString *const BeardedSpiceShowProgress = @"BeardedSpiceShowProgress";
NSString *const BeardedSpiceCustomVolumeControl = @"BeardedSpiceCustomVolumeControl";

NSString *const BSWebSocketServerPort = @"BSWebSocketServerPort";
NSString *const BSWebSocketServerEnabled = @"BSWebSocketServerEnabled";

@implementation GeneralPreferencesViewController

- (id)init{

    self = [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
    if (self) {

    }
    return self;
}

- (void)dealloc{

}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (void)viewWillAppear{

    [self repairLaunchAtLogin];
    self.enableBrowserExtensions.state = [[NSUserDefaults standardUserDefaults] boolForKey:BSWebSocketServerEnabled] ? NSOnState : NSOffState;
}

- (NSView *)initialKeyView{

    return self.firstResponderView;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (IBAction)toggleLaunchAtStartup:(id)sender{

    BOOL shouldBeLaunchAtLogin = [[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceLaunchAtLogin];
    // We launch Controller of the "Launch at Login" in concurrent queue,
    //because probability exists of hanging app on obtaining list of the login items.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        [BSLaunchAtLogin launchAtStartup:shouldBeLaunchAtLogin];
    });
}

- (IBAction)toggleAutoPause:(id)sender {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:GeneralPreferencesAutoPauseChangedNoticiation
         object:self];
    });

}

- (IBAction)toggleUseRemote:(id)sender {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:GeneralPreferencesUsingAppleRemoteChangedNoticiation
         object:self];
    });
}

- (IBAction)toggleWebSocketServer:(id)sender {
    static EHExecuteBlockDelayed *sendNotification;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sendNotification = [[EHExecuteBlockDelayed alloc]
                            initWithTimeout:RELAXING_TIMEOUT
                            leeway:RELAXING_TIMEOUT
                            queue:dispatch_get_main_queue()
                            block:^{
                                [[NSNotificationCenter defaultCenter]
                                 postNotificationName:GeneralPreferencesWebSocketServerEnabledChangedNoticiation
                                 object:self];
                            }];
    });
    NSButton *button = sender;
    [[NSUserDefaults standardUserDefaults] setBool:(button.state == NSOnState) forKey:BSWebSocketServerEnabled];
    [sendNotification executeOnceAfterCalm];
}

- (IBAction)clickGetExtensions:(id)sender {
    [[BSBrowserExtensionsController singleton] openGetExtensions];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods

// Repairs user defaults from login items.
- (void)repairLaunchAtLogin{

    // We launch Controller of the "Launch at Login" in concurrent queue,
    //because probability exists of hanging app on obtaining list of the login items.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL val = [BSLaunchAtLogin isLaunchAtStartup];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setBool:val forKey:BeardedSpiceLaunchAtLogin];

        });
    });
}

- (void)controlTextDidChange:(NSNotification *)notification {

    static EHExecuteBlockDelayed *sendNotification;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sendNotification = [[EHExecuteBlockDelayed alloc]
                            initWithTimeout:RELAXING_TIMEOUT
                            leeway:RELAXING_TIMEOUT
                            queue:dispatch_get_main_queue()
                            block:^{
                                [[NSNotificationCenter defaultCenter]
                                 postNotificationName:GeneralPreferencesWebSocketServerPortChangedNoticiation
                                 object:self];
                            }];
    });
    if ([notification.object isEqual:self.webSocketPortField]) {
        [sendNotification executeOnceAfterCalm];
    }
}

@end
