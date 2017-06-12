//
//  BSVolumeControlProtocol.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 15.05.17.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#ifndef BSVolumeControlProtocol_h
#define BSVolumeControlProtocol_h

typedef NS_ENUM(Byte, BSVolumeControlResult) {
    
    BSVolumeControlNotSupported,
    BSVolumeControlUnavailable,
    BSVolumeControlUp,
    BSVolumeControlDown,
    BSVolumeControlMute,
    BSVolumeControlUnmute
};

@protocol BSVolumeControlProtocol <NSObject>

- (BSVolumeControlResult)volumeUp;
- (BSVolumeControlResult)volumeDown;
- (BSVolumeControlResult)volumeMute;

@end

#endif /* BSVolumeControlProtocol_h */
