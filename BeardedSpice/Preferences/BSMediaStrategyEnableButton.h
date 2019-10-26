//
//  BSMediaStrategyEnableButton.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.08.15.
//  Copyright (c) 2015  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Cocoa/Cocoa.h>

@interface BSMediaStrategyEnableButton : NSButton{
    
    __weak NSTableView *_tableView;
}

- (id)initWithTableView:(NSTableView *)tableView;
@end
