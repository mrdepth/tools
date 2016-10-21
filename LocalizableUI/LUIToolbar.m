//
//  LUIToolbar.m
//  Scanner
//
//  Created by Artem Shimanski on 11.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "LUIToolbar.h"

@implementation LUIToolbar

- (void) awakeFromNib {
	[super awakeFromNib];
	for (UIBarButtonItem* item in self.items) {
		if (item.title.length > 0)
			item.title = [[NSBundle mainBundle] localizedStringForKey:item.title value:@"" table:@"xib"];
	}
}

@end
