//
//  LUIButton.m
//  Scanner
//
//  Created by Artem Shimanski on 11.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "LUIButton.h"

@implementation LUIButton

- (void) awakeFromNib {
	UIControlState states[] = {UIControlStateNormal, UIControlStateHighlighted, UIControlStateDisabled, UIControlStateSelected};
	for (int i = 0; i < 3; i++) {
		NSString* title = [self titleForState:states[i]];
		if (title.length > 0)
			[self setTitle:[[NSBundle mainBundle] localizedStringForKey:title value:@"" table:@"xib"] forState:states[i]];
	}
}

@end
