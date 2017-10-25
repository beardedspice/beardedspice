//
//  TidalTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.05.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "NativeAppTabAdapter.h"
#import "BSVolumeControlProtocol.h"

@interface TidalTabAdapter : NativeAppTabAdapter <BSVolumeControlProtocol>

@end
