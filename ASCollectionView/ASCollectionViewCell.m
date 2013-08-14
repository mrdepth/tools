//
//  ASCollectionViewCell.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewCell.h"

@implementation ASCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setSelected:(BOOL)selected {
	[self setSelected:selected animated:NO];
}

- (void) setHighlighted:(BOOL)highlighted {
	[self setHighlighted:highlighted animated:NO];
}

- (void) setEditing:(BOOL)editing {
	[self setEditing:editing animated:NO];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
	_selected = selected;
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	_highlighted = highlighted;
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
	_editing = editing;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setHighlighted:YES animated:YES];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setHighlighted:NO animated:YES];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setHighlighted:NO animated:YES];
}

@end
