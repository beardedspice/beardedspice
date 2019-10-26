//
//  BSShortcutView.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 09.08.15.
//  Copyright (c) 2015  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "MASShortcutView.h"

@class MASShortcut;

@interface BSShortcutView : MASShortcutView{
    
    BOOL _firstResponder;
    MASShortcut *_savedShortcut;
}

@end
