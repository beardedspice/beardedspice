//
//  EHCenteredTextField.m
//  EightHours
//
//  Created by Roman Sokolov on 19.06.16.
//  Copyright © 2016 Roman Sokolov. All rights reserved.
//

#import "EHVerticalCenteredTextField.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - Cell Class

@interface EHCell : NSTextFieldCell

@end

@implementation EHCell


-(void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    
    [super drawInteriorWithFrame:[self titleRectForBounds:cellFrame] inView:controlView];
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    /* get the standard text content rectangle */
    NSRect titleFrame = [super titleRectForBounds:theRect];
    
    /* find out how big the rendered text will be */
    NSAttributedString *attrString = self.attributedStringValue;
    NSRect textRect = [attrString boundingRectWithSize: titleFrame.size
                                               options: NSStringDrawingUsesLineFragmentOrigin ];
    
    /* If the height of the rendered text is less then the available height,
     * we modify the titleRect to center the text vertically */
    if (textRect.size.height < titleFrame.size.height) {
        titleFrame.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) / 2.0;
        titleFrame.size.height = textRect.size.height;
    }
    return titleFrame;
}

@end

/////////////////////////////////////////////////////////////////////
#pragma mark - EHCenteredTextField

@implementation EHVerticalCenteredTextField

- (id)init{
    
    self = [super init];
    if (self) {
        
        [self setCell:[[EHCell alloc] init]];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setCell:[[EHCell alloc] initWithCoder:aDecoder]];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect{
    
    self = [super initWithFrame:frameRect];
    if (self) {
        
        [self setCell:[[EHCell alloc] init]];
    }
    
    return self;
}
@end
