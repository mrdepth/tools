//
//  LUILabel.m
//  Scanner
//
//  Created by Artem Shimanski on 11.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "LUILabel.h"

@implementation LUILabel

- (void) awakeFromNib {
	if (self.text.length > 0)
		self.text = [[NSBundle mainBundle] localizedStringForKey:self.text value:self.text table:@"Xib"];
}

@end
