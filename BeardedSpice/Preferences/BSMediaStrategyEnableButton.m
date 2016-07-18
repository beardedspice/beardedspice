//
//  BSMediaStrategyEnableButton.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.08.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BSMediaStrategyEnableButton.h"

@implementation BSMediaStrategyEnableButton

- (id)initWithTableView:(NSTableView *)tableView{
    if (!tableView) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        _tableView = tableView;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)acceptsFirstResponder{
    
    if (_tableView) {
        
        NSInteger row = [_tableView rowForView:self];
        NSInteger selectedRow = [_tableView selectedRow];
        if (row > -1 && selectedRow > -1) {
            return (row == selectedRow);
        }
    }
    
    return NO;
}


- (void)mouseDown:(NSEvent *)theEvent{
    
    [super mouseDown:theEvent];
}

@end
