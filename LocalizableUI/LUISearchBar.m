//
//  LUISearchBar.m
//  Scanner
//
//  Created by Artem Shimanski on 11.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "LUISearchBar.h"

@implementation LUISearchBar

- (void) awakeFromNib {
	[super awakeFromNib];
	if (self.text.length > 0)
		self.text = [[NSBundle mainBundle] localizedStringForKey:self.text value:@"" table:@"xib"];
	if (self.placeholder.length > 0)
		self.placeholder = [[NSBundle mainBundle] localizedStringForKey:self.placeholder value:@"" table:@"xib"];
	if (self.prompt.length > 0)
		self.prompt = [[NSBundle mainBundle] localizedStringForKey:self.prompt value:@"" table:@"xib"];
}

@end
