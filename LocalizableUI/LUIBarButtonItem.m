//
//  LUIBarButtonItem.m
//  Scanner
//
//  Created by Artem Shimanski on 11.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "LUIBarButtonItem.h"

@implementation LUIBarButtonItem

- (void) awakeFromNib {
	if (self.title.length > 0)
		self.title = [[NSBundle mainBundle] localizedStringForKey:self.title value:@"" table:@"xib"];
}

@end
