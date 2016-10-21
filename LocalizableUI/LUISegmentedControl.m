//
//  LUISegmentedControl.m
//  Scanner
//
//  Created by Artem Shimanski on 11.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "LUISegmentedControl.h"

@implementation LUISegmentedControl

- (void) awakeFromNib {
	[super awakeFromNib];
	NSUInteger n = self.numberOfSegments;
	for (int i = 0; i < n; i++) {
		NSString* title = [self titleForSegmentAtIndex:i];
		if (title.length > 0)
			[self setTitle:[[NSBundle mainBundle] localizedStringForKey:title value:@"" table:@"xib"] forSegmentAtIndex:i];
	}
}

@end
